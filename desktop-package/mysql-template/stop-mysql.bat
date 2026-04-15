@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0\.."

set "MYSQL_HOME=%CD%\mysql"
set "MYSQLADMIN=%MYSQL_HOME%\bin\mysqladmin.exe"

if not exist "%MYSQLADMIN%" (
  echo [INFO] Portable MySQL binaries were not found. Nothing to stop.
  exit /b 0
)

echo [INFO] Stopping portable MySQL...
"%MYSQLADMIN%" --host=127.0.0.1 --port=13306 --user=root shutdown >nul 2>nul
if errorlevel 1 (
  echo [WARN] mysqladmin shutdown failed. Please check whether MySQL is running.
  exit /b 1
)

echo [INFO] MySQL stopped.
exit /b 0
