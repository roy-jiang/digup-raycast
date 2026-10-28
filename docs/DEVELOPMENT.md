# Working on DigUp Search

Install it from source first (see the README), with Node.js 22.22.2 or newer.

```bash
npm test          # unit tests
npm run lint      # Raycast's checks, ESLint and Prettier
npm run build     # a distribution build, with type checking; it also replaces the copy installed in Raycast
npm run smoke     # the real helper against your own DigUp index; prints counts, never file names
```

## A test index

In development mode (`npm run dev`) the extension reads `~/.config/digup-raycast/dev-settings.json`, if it exists,
to search another index instead of DigUp's own, for example a small folder indexed just for testing:

```json
{ "indexDir": "~/Samples-index", "roots": ["~/Samples"], "codeRoots": ["~/Samples/code"] }
```

DigUp's helper builds such an index:
`/Applications/DigUp.app/Contents/Helpers/digup index ~/Samples --index ~/Samples-index` (add `--code` for the code
folder). The distribution build ignores the file; `npm run smoke` reads it too.

The helper's protocol is described at the top of DigUp's
[`SearchService.swift`](https://github.com/ARahim3/DigUp/blob/main/Sources/digup/SearchService.swift).

## The Raycast Store copy

The Store gets this repository without what only matters here: `docs/`, `tests/`, `scripts/`, the `test` and `smoke`
scripts with `tsx`, and the README's "Install from source" part. `scripts/export-for-store.sh` writes that copy into
a checkout of [raycast/extensions](https://github.com/raycast/extensions):

```bash
scripts/export-for-store.sh ../extensions/extensions/digup-search
```

It exports the last commit, so commit first. Then run `npm ci`, `npm run lint` and `npm run build` in that folder
before committing there.
