@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "APP_HOME=%~dp0"
set "PID_FILE=%APP_HOME%data\run\ruoyi.pid"

if not exist "%PID_FILE%" (
  echo [INFO] No PID file was found. If the window is still open, please close it from the desktop panel.
  exit /b 0
)

set /p APP_PID=<"%PID_FILE%"
if "%APP_PID%"=="" (
  echo [WARN] PID file is empty, cleaning it up.
  del /f /q "%PID_FILE%" >nul 2>nul
  exit /b 0
)

echo [INFO] Stopping process %APP_PID% ...
taskkill /PID %APP_PID% /T >nul 2>nul
if errorlevel 1 (
  taskkill /PID %APP_PID% /T /F >nul 2>nul
)

del /f /q "%PID_FILE%" >nul 2>nul
echo [INFO] Stop completed.
exit /b 0
