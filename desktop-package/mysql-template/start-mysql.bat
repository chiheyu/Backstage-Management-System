@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0\.."

set "MYSQL_HOME=%CD%\mysql"
set "MYSQL_BIN=%MYSQL_HOME%\bin"
set "MYSQLD=%MYSQL_BIN%\mysqld.exe"
set "MYSQLADMIN=%MYSQL_BIN%\mysqladmin.exe"
set "MYSQL=%MYSQL_BIN%\mysql.exe"
set "MY_INI=%CD%\my.ini"
set "DATA_DIR=%CD%\data"
set "LOG_DIR=%CD%\logs"

if not exist "%MYSQLD%" (
  echo [ERROR] Please unpack the official MySQL ZIP package into:
  echo         %MYSQL_HOME%
  exit /b 1
)

if not exist "%DATA_DIR%\mysql" (
  echo [INFO] Initializing MySQL data directory...
  "%MYSQLD%" --defaults-file="%MY_INI%" --initialize-insecure --console
  if errorlevel 1 exit /b 1
)

echo [INFO] Starting portable MySQL...
start "" /min "%MYSQLD%" --defaults-file="%MY_INI%" --console

for /l %%i in (1,1,30) do (
  "%MYSQLADMIN%" --host=127.0.0.1 --port=13306 --user=root ping >nul 2>nul
  if not errorlevel 1 goto :mysql_ready
  timeout /t 1 >nul
)

echo [ERROR] MySQL did not become ready in time.
exit /b 1

:mysql_ready
echo [INFO] MySQL is ready on 127.0.0.1:13306
echo [INFO] If this is the first run, import portable-mysql\scripts\init-database.sql once.
exit /b 0
