@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "APP_HOME=%CD%"
set "JAVA_BIN=%APP_HOME%\jre\bin\java.exe"
if not exist "%JAVA_BIN%" set "JAVA_BIN=%APP_HOME%\jre\bin\javaw.exe"
set "PID_FILE=%APP_HOME%\data\run\ruoyi.pid"
set "MYSQL_START=%APP_HOME%\portable-mysql\scripts\start-mysql.bat"

if not exist "%JAVA_BIN%" (
  echo [ERROR] Embedded Java runtime was not found: "%JAVA_BIN%"
  pause
  exit /b 1
)

if not exist "%MYSQL_START%" (
  echo [ERROR] MySQL fallback template was not found.
  pause
  exit /b 1
)

call "%MYSQL_START%"
if errorlevel 1 (
  echo [ERROR] Portable MySQL failed to start.
  pause
  exit /b 1
)

if exist "%PID_FILE%" (
  del /f /q "%PID_FILE%" >nul 2>nul
)

echo [INFO] Starting desktop app with standalone-mysql profile...
start "" /MIN "%JAVA_BIN%" ^
  "-Dfile.encoding=UTF-8" ^
  "-Dsun.jnu.encoding=UTF-8" ^
  "-Dapp.home=%APP_HOME%" ^
  "-DPIDFILE=%PID_FILE%" ^
  "-Dspring.pid.file=%PID_FILE%" ^
  -jar "%APP_HOME%\app\ruoyi-admin.jar" ^
  standalone ^
  --spring.profiles.active=standalone-mysql ^
  --app.desktop.auto-open-browser=true

echo [INFO] Start signal sent. Browser will open after the application is ready.
exit /b 0
