#!/bin/sh
# Writes the extension as the Raycast Store gets it into a raycast/extensions checkout:
#   scripts/export-for-store.sh <raycast/extensions checkout>/extensions/digup-search
# That is this repository's last commit without what only matters here: docs/, tests/, scripts/, the test and smoke
# scripts with tsx (which only they use), and the README's "Install from source" part. See docs/DEVELOPMENT.md.
set -eu

dest=${1:?usage: scripts/export-for-store.sh <raycast/extensions checkout>/extensions/digup-search}
# The folder is replaced, so make sure it is the extension's folder in that checkout and nothing else.
case "$dest" in
*/extensions/digup-search | */extensions/digup-search/) ;;
*)
  echo "not an extensions/digup-search folder: $dest" >&2
  exit 1
  ;;
esac
repo=$(git -C "$(dirname "$0")" rev-parse --show-toplevel)

rm -rf "$dest"
mkdir -p "$dest"
git -C "$repo" archive HEAD | tar -x -C "$dest"
cd "$dest"
rm -rf docs tests scripts

node - <<'EOF'
const fs = require("node:fs");

const edit = (file, change) => fs.writeFileSync(file, change(fs.readFileSync(file, "utf8")));

// Line by line, so the rest of package.json stays as written.
edit("package.json", (text) => {
  const kept = text
    .split("\n")
    .filter((line) => !/^ {4}"(test|smoke|tsx)": /.test(line))
    .join("\n");
  const manifest = JSON.parse(kept);
  if ("test" in manifest.scripts || "smoke" in manifest.scripts || "tsx" in manifest.devDependencies) {
    throw new Error("package.json still has the test tooling");
  }
  return kept;
});

edit("tsconfig.json", (text) => {
  const kept = text.replace(', "tests/**/*", "scripts/**/*"', "");
  if (kept === text) throw new Error("tsconfig.json: the include list has changed; update this script");
  return kept;
});

edit("README.md", (text) => {
  const kept = text.replace(/<!-- Not in the Raycast Store copy[^]*?<!-- End of the part not in the Store copy\. -->\n\n/, "");
  if (kept === text || kept.includes("Store copy")) throw new Error("README.md: the part to leave out wasn't found");
  return kept;
});
EOF

# The lock file follows package.json (tsx and what it brings go).
npm install --package-lock-only --no-audit --no-fund >/dev/null
echo "exported $(git -C "$repo" log -1 --format=%h) to $dest"
