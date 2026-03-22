@echo off
REM All-in-One Setup and Start Script

setlocal enabledelayedexpansion

echo.
echo ================================================
echo Complete Setup and Start - Everything Automatic
echo ================================================
echo.

REM Step 1: Enable PHP Extension
echo [1/5] Configuring PHP...

for /f "tokens=*" %%A in ('php -r "echo dirname(php_ini_loaded_file());"') do set "PHP_INI_DIR=%%A"

if exist "!PHP_INI_DIR!\php.ini" (
    powershell -Command "(Get-Content '!PHP_INI_DIR!\php.ini') -replace '^;extension=fileinfo', 'extension=fileinfo' | Set-Content '!PHP_INI_DIR!\php.ini'" 2>nul
)

REM Step 2: Backend Setup
echo [2/5] Setting up backend...

cd /d "!CD!\api"
composer install --ignore-platform-req=ext-fileinfo 2>nul
php artisan key:generate 2>nul
mysql -u root -p"password" -e "CREATE DATABASE IF NOT EXISTS task_manager;" 2>nul
php artisan migrate --seed --force 2>nul

echo [OK] Backend ready

REM Step 3: Frontend Setup
echo [3/5] Setting up frontend...

cd /d "!CD!\client"
call npm install 2>nul

echo [OK] Frontend ready

REM Step 4: Start Backend
echo [4/5] Starting backend server...

start cmd /k "cd /d !CD!\api && php artisan serve"
timeout /t 3 /nobreak

REM Step 5: Start Frontend
echo [5/5] Starting frontend server...

start cmd /k "cd /d !CD!\client && npm run dev"

echo.
echo ================================================
echo ALL DONE - Servers Starting!
echo ================================================
echo.
echo Two new windows will open:
echo 1. Laravel backend on http://localhost:8000
echo 2. Vue frontend on http://localhost:3000
echo.
echo Waiting for servers to start (30 seconds)...
echo.

timeout /t 5 /nobreak

echo.
echo Opening http://localhost:3000 in browser...
start http://localhost:3000

echo.
echo ================================================
echo READY TO USE!
echo ================================================
echo.
echo Login with:
echo   Email: admin@example.com
echo   Password: password
echo.
echo The app is running at: http://localhost:3000
echo.
pause
