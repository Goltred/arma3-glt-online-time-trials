# Online Operational Trials (Standalone)

This folder is an independent build/package scaffold for the Time Trials addon.

## Layout

- `addons/GLT_Trials` - copied addon source
- `SConstruct` - scons build script
- `tools/build.json` - standalone build targets
- `tools/buildExtIncludes.txt` - addon builder include extensions
- `mod.cpp` / `meta.cpp` - mod metadata

## Build

From this folder:

1. Configure `tools/build.json` if needed (especially `outputFolder`).
2. Run `scons` to build all pbos.
3. Optional: run `scons symlinks` to link into Arma 3 dev drive.

## Notes

- This scaffold intentionally keeps the addon folder/prefix as `GLT_Trials`
  so behavior remains identical to current source.
- Next migration step (optional): rename addon/prefix and patch IDs for a fully
  new namespace.
