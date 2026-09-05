@echo off
setlocal
cd /d "%~dp0"

set "EXE=%~1"
if "%EXE%"=="" set "EXE=FPS.exe"

if not exist "%EXE%" (
  echo [ERROR] FPS.exe not found.
  echo.
  echo Export the Godot project as FPS.exe, then either:
  echo   1. Put FPS.exe next to this BAT and run it, or
  echo   2. Drag FPS.exe onto this BAT file.
  echo.
  pause
  exit /b 1
)

if not exist "UPLOAD_TO_GITHUB" mkdir "UPLOAD_TO_GITHUB"
copy /Y "%EXE%" "UPLOAD_TO_GITHUB\FPS.exe" >nul

for /f "usebackq delims=" %%H in (`powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath 'UPLOAD_TO_GITHUB\FPS.exe').Hash.ToLower()"`) do set "SHA=%%H"

powershell -NoProfile -Command ^
  "$m=[ordered]@{launcher=[ordered]@{version='1.0.0-alpha43';url='https://raw.githubusercontent.com/ARG303/NewVanillaPatch/main/FPS.exe';sha256='%SHA%'}}; $m ^| ConvertTo-Json -Depth 4 ^| Set-Content -LiteralPath 'UPLOAD_TO_GITHUB\manifest.json' -Encoding UTF8"

if errorlevel 1 (
  echo [ERROR] Could not generate manifest.json
  pause
  exit /b 1
)

echo.
echo READY FOR GITHUB
echo ----------------
echo File: UPLOAD_TO_GITHUB\FPS.exe
echo SHA-256: %SHA%
echo File: UPLOAD_TO_GITHUB\manifest.json
echo.
echo Upload BOTH files to the ROOT of the main branch of:
echo https://github.com/ARG303/NewVanillaPatch

echo.
pause
