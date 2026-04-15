@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "APP_HOME=%CD%"
set "JAVA_BIN=%APP_HOME%\jre\bin\java.exe"
if not exist "%JAVA_BIN%" set "JAVA_BIN=%APP_HOME%\jre\bin\javaw.exe"
set "PID_FILE=%APP_HOME%\data\run\ruoyi.pid"

if not exist "%JAVA_BIN%" (
  echo [ERROR] Embedded Java runtime was not found: "%JAVA_BIN%"
  pause
  exit /b 1
)

if exist "%PID_FILE%" (
  set /p APP_PID=<"%PID_FILE%"
  if not "%APP_PID%"=="" (
    tasklist /FI "PID eq %APP_PID%" | findstr /R /C:" %APP_PID% " >nul
    if not errorlevel 1 (
      echo [INFO] Desktop app is already running. PID=%APP_PID%
      exit /b 0
    )
  )
  del /f /q "%PID_FILE%" >nul 2>nul
)

echo [INFO] Starting portable desktop app...
start "" /MIN "%JAVA_BIN%" ^
  "-Dfile.encoding=UTF-8" ^
  "-Dsun.jnu.encoding=UTF-8" ^
  "-Dapp.home=%APP_HOME%" ^
  "-DPIDFILE=%PID_FILE%" ^
  "-Dspring.pid.file=%PID_FILE%" ^
  -jar "%APP_HOME%\app\ruoyi-admin.jar" ^
  standalone ^
  --spring.profiles.active=standalone ^
  --app.desktop.auto-open-browser=true

echo [INFO] Start signal sent. The browser will open automatically after boot.
exit /b 0
