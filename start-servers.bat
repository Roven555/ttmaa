@echo off
REM Task Manager Application - Start Both Servers
REM This script will start both Laravel and Vue development servers

echo.
echo ========================================
echo Task Manager - Starting Both Servers
echo ========================================
echo.

echo This will open two Command Prompt windows:
echo 1. Laravel server (Backend) on http://localhost:8000
echo 2. Vue dev server (Frontend) on http://localhost:3000
echo.
echo Press any key to continue...
pause >nul

REM Start Laravel in one window
echo Starting Laravel backend...
start cmd /k "cd api && php artisan serve"

REM Wait a moment for Laravel to start
timeout /t 3 /nobreak

REM Start Vue in another window
echo Starting Vue frontend...
start cmd /k "cd client && npm run dev"

echo.
echo Both servers are starting. Two new Command Prompt windows should open.
echo.
echo When ready, open your browser to: http://localhost:3000
echo.
echo Login with:
echo   Email: admin@example.com
echo   Password: password
echo.
echo To stop servers, close the Command Prompt windows.
echo.
pause
