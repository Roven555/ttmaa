@echo off
REM Task Manager Application - Frontend Setup Script for Windows

echo.
echo ========================================
echo Task Manager - Frontend Setup
echo ========================================
echo.

REM Check if Node is installed
node -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js not found! Make sure Node.js is installed and in PATH.
    pause
    exit /b 1
)
echo [OK] Node.js found:
node -v

REM Check if npm is installed
npm -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: npm not found!
    pause
    exit /b 1
)
echo [OK] npm found:
npm -v

REM Navigate to client directory
cd client
if errorlevel 1 (
    echo ERROR: Could not find client directory!
    pause
    exit /b 1
)
echo [OK] In client directory

REM Verify .env.local exists
if not exist .env.local (
    echo Creating .env.local...
    echo VITE_API_URL=http://localhost:8000/api > .env.local
    echo [OK] .env.local created
) else (
    echo [INFO] .env.local already exists
)

REM Install npm dependencies
echo.
echo Installing npm dependencies...
echo This may take a few minutes...
echo.
npm install
if errorlevel 1 (
    echo ERROR: npm install failed!
    pause
    exit /b 1
)
echo [OK] Dependencies installed

echo.
echo ========================================
echo Frontend Setup Complete!
echo ========================================
echo.
echo Ready to start the development server!
echo.
echo To run frontend:
echo   npm run dev
echo.
echo Frontend will be available at: http://localhost:3000
echo.
pause
