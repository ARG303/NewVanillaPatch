# NewVanillaPatch

Runtime files and auto-update metadata for the Red Alert 3 60 FPS launcher.

## Current versions

- FPS patch package: **7.0.1**
- Launcher: **0.3.0**
- Target game: **Red Alert 3 1.12**
- Target FPS: **60**

## Repository layout

```text
manifest.json
PATCH_VERSION
LAUNCHER_VERSION
runtime/
  xinput1_3.dll
  fps_patch.ini
launcher/
  RA3FPSLauncher.exe
.github/workflows/
  update-manifest.yml
  release-patch.yml
```

`manifest.json` is read by the launcher at:

```text
https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/manifest.json
```

The launcher downloads runtime files and its own update only after SHA-256 verification.

## Updating the FPS patch

1. Replace `runtime/xinput1_3.dll` and/or `runtime/fps_patch.ini`.
2. Change `PATCH_VERSION`.
3. Commit and push.
4. `Update manifests` recalculates hashes and updates `manifest.json`.

## Updating the launcher

1. Replace `launcher/RA3FPSLauncher.exe`.
2. Change `LAUNCHER_VERSION`.
3. Commit and push.
4. The workflow recalculates the launcher SHA-256 in `manifest.json`.

Launcher **0.2.7+** can download a newer launcher, verify SHA-256, close itself, replace its own executable, and restart.
