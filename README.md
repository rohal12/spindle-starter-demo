# Spindle Starter Demo

A small story built from [spindle-starter](https://github.com/rohal12/spindle-starter), used to test the template's builds and to show what it produces.

- **Play in the browser:** https://rohal12.github.io/spindle-starter-demo/
- **Downloads** (Windows, macOS, Linux, Android, JoiPlay): [Releases](https://github.com/rohal12/spindle-starter-demo/releases)

The macOS app is unsigned: right-click it and choose **Open** the first time. The Android APK is a debug build for sideloading unless the repo has the `KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS` and `KEY_PASSWORD` secrets, in which case it's a signed release build.

## How it works

This repo doesn't contain a copy of the template. `overlay/` holds only the demo story, assets and `vite.demo.config.ts` (the starter's config plus `spindlePack`). CI runs `scripts/assemble.sh <ref> work`, which fetches spindle-starter at `<ref>` (like `npx degit`), replaces `src/story/` and copies the overlay on top. It then lints, builds, checks the output (`scripts/check-dist.sh`) and packs every target.

| Trigger | Starter ref | Deploys Pages | Creates release |
|---|---|---|---|
| spindle-starter push to `main` | that commit | yes | no |
| spindle-starter release | the release tag | yes | yes, same tag |
| Push to this repo's `main` | `main` | yes | no |
| Manual run (Actions → Build demo) | input `ref` | no | no |

## Local build

    scripts/assemble.sh main work
    cd work && npm install && npm run lint && npm run build
    ../scripts/check-dist.sh .
    # pack one target:
    NODE_ENV=production SPINDLE_PACK_TARGETS=joiplay npx vite build -c vite.demo.config.ts

## Tests

    tests/assemble.test.sh && tests/demo-version.test.sh && tests/check-dist.test.sh

## Credits

Lora font by The Lora Project Authors, SIL Open Font License 1.1 (`overlay/src/assets/fonts/OFL.txt`).
