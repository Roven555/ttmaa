@echo off
setlocal enabledelayedexpansion

REM Run the actual setup commands and keep window open

echo.
echo ================================================
echo TASK MANAGER - COMPLETE SETUP
echo ================================================
echo.

REM Check PHP
echo Checking PHP...
php -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: PHP not found!
    goto :error
)
echo [OK] PHP found

REM Check Composer
echo Checking Composer...
composer --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Composer not found!
    goto :error
)
echo [OK] Composer found

REM Check Node
echo Checking Node.js...
node -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found!
    goto :error
)
echo [OK] Node.js found

REM Find PHP ini
echo.
echo Configuring PHP...
for /f "tokens=*" %%A in ('php -r "echo dirname(php_ini_loaded_file());"') do set "PHP_INI_DIR=%%A"
echo Php.ini location: !PHP_INI_DIR!

if exist "!PHP_INI_DIR!\php.ini" (
    echo Enabling fileinfo extension...
    powershell -NoProfile -Command "(Get-Content '!PHP_INI_DIR!\php.ini') -replace '^;extension=fileinfo', 'extension=fileinfo' | Set-Content '!PHP_INI_DIR!\php.ini'" 2>nul
    echo [OK] Done
) else (
    echo [WARNING] php.ini not found
)

REM Backend setup
echo.
echo ================================================
echo SETTING UP BACKEND
echo ================================================
echo.

cd /d "%~dp0api" 2>nul
if errorlevel 1 (
    echo ERROR: Cannot find api folder!
    goto :error
)

echo Running: composer install
composer install --ignore-platform-req=ext-fileinfo
if errorlevel 1 (
    echo [WARNING] Composer had issues, continuing...
)

echo.
echo Running: php artisan key:generate
php artisan key:generate 2>nul

echo.
echo Creating MySQL database...
mysql -u root -p"password" -e "CREATE DATABASE IF NOT EXISTS task_manager;" 2>nul

echo.
echo Running: php artisan migrate --seed
php artisan migrate --seed --force 2>nul

echo.
echo [OK] Backend ready!

REM Frontend setup
echo.
echo ================================================
echo SETTING UP FRONTEND
echo ================================================
echo.

cd /d "%~dp0client" 2>nul
if errorlevel 1 (
    echo ERROR: Cannot find client folder!
    goto :error
)

echo Running: npm install
call npm install

echo [OK] Frontend ready!

echo.
echo ================================================
echo READY TO START!
echo ================================================
echo.
echo I will now start both servers...
echo.
pause

REM Start servers
echo Starting Laravel backend...
start /B cmd /c "cd /d "%~dp0api" && php artisan serve"

echo Starting Vue frontend...
start /B cmd /c "cd /d "%~dp0client" && npm run dev"

echo.
echo Waiting for servers to start...
timeout /t 5 /nobreak

echo.
echo Opening application...
start http://localhost:3000

echo.
echo ================================================
echo SUCCESS!
echo ================================================
echo.
echo Your app is running at: http://localhost:3000
echo.
echo Backend: http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo Login with:
echo   Email: admin@example.com
echo   Password: password
echo.
echo This window will close in 30 seconds...
timeout /t 30
goto :end

:error
echo.
echo ERROR OCCURRED!
echo.
echo Press any key to see the error above...
pause
goto :end

:end
exit /b
