@echo off
REM Diagnostic script to check system setup

echo.
echo ================================================
echo DIAGNOSTIC CHECK
echo ================================================
echo.

echo Checking PHP...
php -v
if errorlevel 1 echo ERROR: PHP not working
echo.

echo Checking Composer...
composer --version
if errorlevel 1 echo ERROR: Composer not working
echo.

echo Checking Node...
node -v
if errorlevel 1 echo ERROR: Node not working
echo.

echo Checking npm...
npm -v
if errorlevel 1 echo ERROR: npm not working
echo.

echo Checking MySQL...
mysql -u root -p"password" -e "SELECT 1;" 2>nul
if errorlevel 1 echo ERROR: MySQL not working or wrong password
if not errorlevel 1 echo [OK] MySQL is working
echo.

echo Checking project structure...
if exist "api" (
    echo [OK] Found api folder
    if exist "api\composer.json" echo [OK] Found api\composer.json
    if exist "api\artisan" echo [OK] Found api\artisan - Laravel installed
    if not exist "api\artisan" echo [!] Missing api\artisan - run: cd api && composer install
) else (
    echo ERROR: api folder not found
)
echo.

if exist "client" (
    echo [OK] Found client folder
    if exist "client\package.json" echo [OK] Found client\package.json
) else (
    echo ERROR: client folder not found
)
echo.

echo ================================================
echo Diagnostic complete
echo ================================================
echo.
pause
