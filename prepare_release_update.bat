@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

set "TAG=v1.0.0-alpha43"
set "VERSION=1.0.0-alpha43"
set "EXE=%~1"
if "%EXE%"=="" set "EXE=FPS.exe"

if not exist "%EXE%" (
  echo [ERROR] FPS.exe not found.
  echo.
  echo Export the Godot project as FPS.exe and either:
  echo   1. Put FPS.exe next to this BAT, or
  echo   2. Drag FPS.exe onto this BAT.
  pause
  exit /b 1
)

if not exist "RELEASE_ASSET" mkdir "RELEASE_ASSET"
if not exist "UPLOAD_MANIFEST_TO_REPO" mkdir "UPLOAD_MANIFEST_TO_REPO"

copy /Y "%EXE%" "RELEASE_ASSET\FPS.exe" >nul
for /f "usebackq delims=" %%H in (`powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -LiteralPath 'RELEASE_ASSET\FPS.exe').Hash.ToLower()"`) do set "SHA=%%H"

set "URL=https://github.com/ARG303/NewVanillaPatch/releases/download/%TAG%/FPS.exe"

powershell -NoProfile -Command ^
  "$m=[ordered]@{launcher=[ordered]@{version='%VERSION%';url='%URL%';sha256='%SHA%'}};" ^
  "$j=$m ^| ConvertTo-Json -Depth 4;" ^
  "$enc=New-Object System.Text.UTF8Encoding($false);" ^
  "[System.IO.File]::WriteAllText((Join-Path (Get-Location) 'UPLOAD_MANIFEST_TO_REPO\manifest.json'), $j, $enc)"

if errorlevel 1 (
  echo [ERROR] Could not generate manifest.json
  pause
  exit /b 1
)

echo.
echo READY.
echo.
echo 1. Create GitHub Release tag: %TAG%
echo 2. Attach: RELEASE_ASSET\FPS.exe
echo 3. Publish the Release.
echo 4. Upload UPLOAD_MANIFEST_TO_REPO\manifest.json to the ROOT of branch main.
echo.
echo SHA256: %SHA%
echo URL: %URL%
echo.
pause
