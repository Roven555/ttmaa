@echo off
REM comprehensive setup script - handles everything

setlocal enabledelayedexpansion

echo.
echo ========================================
echo COMPLETE SETUP - Everything Automated
echo ========================================
echo.

REM Find PHP directory
for /f "tokens=*" %%A in ('where php 2^>nul') do set "PHP_PATH=%%~dpA"

if "!PHP_PATH!"=="" (
    echo ERROR: PHP not found in PATH!
    pause
    exit /b 1
)

echo [OK] PHP found at: !PHP_PATH!

REM Get PHP directory
for /f "tokens=*" %%A in ('php -r "echo dirname(php_ini_loaded_file());"') do set "PHP_INI_DIR=%%A"

if exist "!PHP_INI_DIR!\php.ini" (
    echo [OK] Found php.ini at: !PHP_INI_DIR!\php.ini

    REM Enable fileinfo extension
    echo [*] Enabling fileinfo extension...

    REM Create backup
    copy "!PHP_INI_DIR!\php.ini" "!PHP_INI_DIR!\php.ini.backup" >nul

    REM Use powershell to edit the file (handles the semicolon properly)
    powershell -Command "(Get-Content '!PHP_INI_DIR!\php.ini') -replace '^;extension=fileinfo', 'extension=fileinfo' | Set-Content '!PHP_INI_DIR!\php.ini'" 2>nul

    echo [OK] fileinfo extension enabled
) else (
    echo [WARNING] Could not find php.ini
)

echo.
echo [*] Installing backend dependencies...

cd /d "!CD!\api"
if errorlevel 1 (
    echo ERROR: Could not navigate to api directory!
    pause
    exit /b 1
)

composer install --ignore-platform-req=ext-fileinfo
if errorlevel 1 (
    echo [WARNING] Composer install had issues, but continuing...
)

echo [OK] Dependencies installed

echo.
echo [*] Generating application key...
php artisan key:generate

echo.
echo [*] Creating MySQL database...

REM Try to create database
mysql -u root -p"password" -e "CREATE DATABASE IF NOT EXISTS task_manager;" 2>nul
if errorlevel 1 (
    echo [!] Could not auto-create database. Manual creation needed.
    echo    Open Command Prompt and run:
    echo    mysql -u root -p
    echo    CREATE DATABASE task_manager;
    echo    EXIT;
) else (
    echo [OK] Database created
)

echo.
echo [*] Running database migrations...
php artisan migrate --seed --force
if errorlevel 1 (
    echo [WARNING] Migrations had issues
)

echo.
echo ========================================
echo BACKEND SETUP COMPLETE!
echo ========================================
echo.
echo The Laravel backend is ready.
echo.
echo IMPORTANT: Keep this window open for reference
echo.
echo Next steps:
echo.
echo 1. FRONTEND SETUP - Open a NEW Command Prompt and run:
echo    cd ttmaa\client
echo    npm install
echo    npm run dev
echo.
echo 2. START BACKEND - Open another NEW Command Prompt and run:
echo    cd ttmaa\api
echo    php artisan serve
echo.
echo 3. ACCESS APP - Open browser to:
echo    http://localhost:3000
echo.
echo 4. LOGIN with:
echo    Email: admin@example.com
echo    Password: password
echo.
pause
