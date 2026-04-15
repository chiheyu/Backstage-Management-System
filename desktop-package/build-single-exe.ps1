param(
    [switch]$RebuildPortable
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Command not found: $Name"
    }
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$portableRoot = Join-Path $scriptRoot 'dist\Hanzhong-AfterSale-Desktop'
$releaseRoot = Join-Path $scriptRoot 'dist\single-exe'
$zipPath = Join-Path $releaseRoot 'Hanzhong-AfterSale-Desktop.zip'
$bootstrapPath = Join-Path $releaseRoot 'bootstrap.cmd'
$sedPath = Join-Path $releaseRoot 'single-exe.sed'
$targetExe = Join-Path $releaseRoot 'Hanzhong-AfterSale-Desktop-SFX.exe'

Require-Command iexpress

if ($RebuildPortable -or -not (Test-Path -LiteralPath $portableRoot)) {
    & (Join-Path $scriptRoot 'build-standalone.ps1')
}

if (-not (Test-Path -LiteralPath $portableRoot)) {
    throw "Portable directory not found: $portableRoot"
}

if (Test-Path -LiteralPath $releaseRoot) {
    Remove-Item -LiteralPath $releaseRoot -Recurse -Force
}
New-Item -ItemType Directory -Path $releaseRoot -Force | Out-Null

Compress-Archive -Path (Join-Path $portableRoot '*') -DestinationPath $zipPath -Force

$bootstrap = @'
@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "TARGET_DIR=%~dp0Hanzhong-AfterSale-Desktop"
if exist "%TARGET_DIR%" rd /s /q "%TARGET_DIR%"
mkdir "%TARGET_DIR%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -LiteralPath '%~dp0Hanzhong-AfterSale-Desktop.zip' -DestinationPath '%TARGET_DIR%' -Force"
if errorlevel 1 exit /b 1

start "" "%TARGET_DIR%\start-app.bat"
exit /b 0
'@
Set-Content -LiteralPath $bootstrapPath -Value $bootstrap -Encoding ASCII

$sed = @"
[Version]
Class=IEXPRESS
SEDVersion=3
[Options]
PackagePurpose=InstallApp
ShowInstallProgramWindow=0
HideExtractAnimation=1
UseLongFileName=1
InsideCompressed=0
CAB_FixedSize=0
CAB_ResvCodeSigning=0
RebootMode=N
InstallPrompt=
DisplayLicense=
FinishMessage=
TargetName=$targetExe
FriendlyName=Hanzhong After-Sale Desktop
AppLaunched=bootstrap.cmd
PostInstallCmd=<None>
AdminQuietInstCmd=
UserQuietInstCmd=
SourceFiles=SourceFiles
[Strings]
FILE0=Hanzhong-AfterSale-Desktop.zip
FILE1=bootstrap.cmd
[SourceFiles]
SourceFiles0=$releaseRoot
[SourceFiles0]
%FILE0%=
%FILE1%=
"@
Set-Content -LiteralPath $sedPath -Value $sed -Encoding ASCII

Start-Process -FilePath 'iexpress.exe' -ArgumentList '/N', $sedPath -Wait -NoNewWindow

Write-Host ''
Write-Host 'Single-file release package completed.'
Write-Host "Output: $targetExe"
Write-Host 'Note: this EXE is a self-extracting release wrapper for distribution.'
