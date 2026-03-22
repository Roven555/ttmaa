@echo off
REM Simple Backend Setup Only

setlocal enabledelayedexpansion

echo.
echo ========================================
echo Backend Setup (Fixing PHP and Composer)
echo ========================================
echo.

REM Find and configure PHP
echo [*] Fixing PHP configuration...

for /f "tokens=*" %%A in ('php -r "echo dirname(php_ini_loaded_file());"') do set "PHP_INI_DIR=%%A"

if exist "!PHP_INI_DIR!\php.ini" (
    echo [*] Found php.ini at: !PHP_INI_DIR!\php.ini
    echo [*] Enabling fileinfo extension...

    REM Backup php.ini
    if not exist "!PHP_INI_DIR!\php.ini.backup" (
        copy "!PHP_INI_DIR!\php.ini" "!PHP_INI_DIR!\php.ini.backup" >nul
    )

    REM Enable extension using PowerShell
    powershell -NoProfile -Command "(Get-Content '!PHP_INI_DIR!\php.ini') -replace '^;extension=fileinfo', 'extension=fileinfo' | Set-Content '!PHP_INI_DIR!\php.ini'" 2>nul

    if errorlevel 1 (
        echo [WARNING] Could not automatically enable extension
    ) else (
        echo [OK] Extension enabled
    )
) else (
    echo [WARNING] Could not locate php.ini
)

REM Navigate to api
cd /d "%~dp0api" 2>nul
if errorlevel 1 (
    cd /d "%CD%\api" 2>nul
)

if not exist "composer.json" (
    echo ERROR: Could not find api directory!
    pause
    exit /b 1
)

echo.
echo [*] Installing Composer dependencies...
composer install
if errorlevel 1 (
    echo [!] Trying with ignore-platform-req flag...
    composer install --ignore-platform-req=ext-fileinfo
)

echo [OK] Composer install complete

echo.
echo [*] Generating Laravel key...
php artisan key:generate

echo.
echo [*] Creating database...
mysql -u root -p"password" -e "CREATE DATABASE IF NOT EXISTS task_manager;" 2>nul

echo.
echo [*] Running migrations...
php artisan migrate --seed --force

echo.
echo ========================================
echo Backend Setup Complete!
echo ========================================
echo.
echo Next: Start the backend server
echo.
echo Run this command:
echo   cd api
echo   php artisan serve
echo.
echo Then start frontend in ANOTHER window:
echo   cd client
echo   npm install
echo   npm run dev
echo.
pause
