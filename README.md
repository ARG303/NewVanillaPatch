# Red Alert 3 — 60 FPS Patch

Runtime repository for the Red Alert 3 60 FPS launcher.

## Runtime files

- `runtime/xinput1_3.dll` — XInput proxy that installs the FPS patch when RA3 1.12 starts.
- `runtime/fps_patch.ini` — patch configuration file.
- `manifest.json` — machine-readable update manifest consumed by the launcher.
- `PATCH_VERSION` — current patch version.

## Updating the patch

1. Replace `runtime/xinput1_3.dll` and/or `runtime/fps_patch.ini`.
2. Increase the version in `PATCH_VERSION`.
3. Commit and push to `main`.
4. GitHub Actions recalculates SHA-256 hashes and updates `manifest.json` automatically.
5. Launchers will see the new manifest on the next update check and download only changed runtime files.

## Launcher manifest URL

`https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/manifest.json`

## Optional GitHub Release

Open **Actions → Publish patch release → Run workflow**, enter the same version as `PATCH_VERSION`, and GitHub will create a release containing the DLL, INI, and manifest.
