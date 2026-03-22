@echo off
REM Task Manager Application - Automated Setup Script for Windows

echo.
echo ========================================
echo Task Manager - Backend Setup
echo ========================================
echo.

REM Check if PHP is installed
php -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: PHP not found! Make sure PHP is installed and in PATH.
    pause
    exit /b 1
)
echo [OK] PHP found

REM Check if Composer is installed
composer --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Composer not found! Make sure Composer is installed and in PATH.
    pause
    exit /b 1
)
echo [OK] Composer found

REM Navigate to api directory
cd api
if errorlevel 1 (
    echo ERROR: Could not find api directory!
    pause
    exit /b 1
)
echo [OK] In api directory

REM Copy environment file
echo.
echo Installing dependencies...
if exist .env (
    echo [INFO] .env already exists, skipping copy
) else (
    copy .env.example .env >nul
    echo [OK] Copied .env.example to .env
)

REM Install Composer dependencies
composer install
if errorlevel 1 (
    echo ERROR: Composer install failed!
    pause
    exit /b 1
)
echo [OK] Dependencies installed

REM Generate application key
echo.
echo Generating application key...
php artisan key:generate
if errorlevel 1 (
    echo ERROR: Key generation failed!
    pause
    exit /b 1
)
echo [OK] Application key generated

REM Create MySQL database
echo.
echo Creating MySQL database...
echo.
echo IMPORTANT: If this fails, you need to create the database manually:
echo   1. Open MySQL Command Line
echo   2. Login with: mysql -u root -p
echo   3. Enter password: password
echo   4. Run: CREATE DATABASE task_manager;
echo   5. Run: EXIT;
echo.

REM Try to create database (this might fail if MySQL not running)
mysql -u root -p"password" -e "CREATE DATABASE IF NOT EXISTS task_manager;" 2>nul
if errorlevel 1 (
    echo [WARNING] Could not connect to MySQL. Make sure MySQL is running!
    echo Database creation was skipped.
) else (
    echo [OK] Database created/verified
)

REM Run migrations
echo.
echo Running database migrations...
php artisan migrate --seed
if errorlevel 1 (
    echo ERROR: Migration failed!
    echo Make sure the task_manager database exists and MySQL is running.
    pause
    exit /b 1
)
echo [OK] Migrations completed

echo.
echo ========================================
echo Backend Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Keep this window open for reference
echo 2. Open a NEW Command Prompt window
echo 3. Navigate to the api folder: cd ttmaa\api
echo 4. Start Laravel server: php artisan serve
echo 5. Laravel will start on: http://localhost:8000
echo.
echo Open another Command Prompt and setup frontend:
echo 1. Navigate to client: cd ttmaa\client
echo 2. Install dependencies: npm install
echo 3. Start dev server: npm run dev
echo 4. Frontend will be on: http://localhost:3000
echo.
pause
