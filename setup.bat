@echo off
REM Quick setup script for local development on Windows
REM Usage: setup.bat

setlocal enabledelayedexpansion

echo.
echo 🚀 WanderAI Development Setup
echo ==============================
echo.

REM Check prerequisites
echo 📋 Checking prerequisites...

where python >nul 2>nul
if errorlevel 1 (
    echo ❌ Python not found. Please install Python 3.11+
    exit /b 1
)

where docker >nul 2>nul
if errorlevel 1 (
    echo ❌ Docker not found. Please install Docker
    exit /b 1
)

echo ✅ Prerequisites OK
echo.

REM Setup backend
echo ⚙️  Setting up backend...
cd backend

if not exist "venv" (
    echo   Creating virtual environment...
    python -m venv venv
)

echo   Activating virtual environment...
call venv\Scripts\activate.bat

echo   Installing dependencies...
pip install -q -r requirements.txt

if not exist ".env" (
    echo   Creating .env file...
    copy .env.example .env
    echo   ⚠️  Please update .env with your API keys!
)

cd ..
echo ✅ Backend setup complete
echo.

REM Setup mobile
echo ⚙️  Setting up mobile...
cd mobile

where flutter >nul 2>nul
if errorlevel 1 (
    echo ⚠️  Flutter not found. Skipping mobile setup.
    echo    Install from: https://flutter.dev/docs/get-started/install
) else (
    echo   Getting Flutter dependencies...
    flutter pub get -q
    echo ✅ Mobile setup complete
)

cd ..
echo.

REM Start services
echo 🐳 Starting Docker services...
docker-compose up -d

REM Wait for services
echo ⏳ Waiting for services to be ready (30 seconds)...
timeout /t 30 /nobreak

echo.
echo 🎉 Setup Complete!
echo.
echo 📝 Next steps:
echo.
echo 1. Backend:
echo    cd backend
echo    venv\Scripts\activate.bat
echo    uvicorn app.main:app --reload
echo    API: http://localhost:8000
echo    Docs: http://localhost:8000/docs
echo.
echo 2. Mobile (in new terminal):
echo    cd mobile
echo    flutter run -d ^<device^>
echo    Options: emulator, ios, web, chrome
echo.
echo 3. View services:
echo    docker-compose ps
echo.
echo 4. View logs:
echo    docker-compose logs -f
echo.
echo 5. Stop services:
echo    docker-compose down
echo.
echo 📚 Documentation:
echo    - Backend API: http://localhost:8000/docs
echo    - README: https://github.com/AvishkaGihan/wanderai
echo    - Contributing: CONTRIBUTING.md
echo.
echo ✨ Happy coding!
echo.

pause
