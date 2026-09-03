# NewVanilla Patch — Godot launcher branch

Version: **1.0.0-alpha**  
Target engine: **Godot 4.7.2 Standard**

This branch intentionally changes the launcher architecture instead of merely rewriting the old Go UI in Godot.

## Main goals

- Never patch or replace `Data/ra3_1.12.game` during normal launching.
- Never create or run `NewVanilla.game`.
- Never scan processes, inspect modules, inject DLLs, or manipulate RA3BattleNet.
- RA3BattleNet is passive: start its client first, then start RA3 from this launcher.
- No embedded FPS DLL in the launcher/PCK.
- No self-updating launcher executable.
- Network access occurs only after the user explicitly clicks **INSTALL 60 FPS RUNTIME**.
- Downloaded runtime files are verified with hard-coded SHA-256 before installation.
- `add-config CommunityPatch\RA3_.SkuDef` is added to the selected real SkuDef only once (with a one-time text backup), not temporarily edited on every launch.
- Both `RA3_*_1.12.SkuDef` and `RA3_*_1.12.8.SkuDef`/other `RA3_*_1.12*.SkuDef` names are supported and selectable.

## 30 vs 60 FPS in this alpha

The existing FPS Patch v7 is compile-time fixed to 60 FPS. Therefore the clean launcher does **not** rename/remove the DLL automatically on every launch.

- To play **60 FPS**, explicitly install/enable the verified runtime.
- To play true **30 FPS**, explicitly disable the verified runtime first.

This makes the state visible and user-driven, and avoids hidden file manipulation during every Play action.

The next runtime milestone is a multi-build FPS DLL that supports the original RA3 builds directly. That will eliminate the old `.game` compatibility conversion system entirely.

## Runtime SHA-256

`xinput1_3.dll`

```
781b9ec9cc24b6fd495747dd8434073e8abe60784aeb9fbfc4641b47af1560ff
```

`fps_patch.ini`

```
6b02e5da7af03490a28a76ef11e754a4a65f0dc0ce651ce1bdca23cb4fa7a360
```

## Build

1. Install Godot 4.7.2 Standard and its export templates.
2. Open `project.godot`.
3. Test the project in the editor.
4. Export using the included `Windows Desktop` preset.

Command line after export templates are installed:

```
godot --path . --export-release "Windows Desktop" build/NewVanillaPatch.exe
```

A second `Windows Desktop x86` preset is included for testing on older 32-bit Windows environments.

## Important antivirus note

Moving the UI to Godot does not guarantee that Defender/SmartScreen will trust an unsigned program. The security improvement in this branch comes primarily from removing suspicious behavior: no RA3 executable replacement, no injection, no process scanning, no embedded runtime DLL, and no silent self-update.

For public distribution, Authenticode signing is still recommended.
