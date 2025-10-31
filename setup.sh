#!/bin/bash
# Quick setup script for local development
# Usage: bash setup.sh

set -e

echo "🚀 WanderAI Development Setup"
echo "=============================="
echo ""

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.11+"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Setup backend
echo "⚙️  Setting up backend..."
cd backend

# Create virtual environment
if [ ! -d "venv" ]; then
    echo "  Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
echo "  Installing dependencies..."
pip install -q -r requirements.txt

# Copy .env.example to .env if it doesn't exist
if [ ! -f ".env" ]; then
    echo "  Creating .env file..."
    cp .env.example .env
    echo "  ⚠️  Please update .env with your API keys!"
fi

cd ..
echo "✅ Backend setup complete"
echo ""

# Setup mobile
echo "⚙️  Setting up mobile..."
cd mobile

if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found. Skipping mobile setup."
    echo "    Install from: https://flutter.dev/docs/get-started/install"
else
    echo "  Getting Flutter dependencies..."
    flutter pub get -q
    echo "✅ Mobile setup complete"
fi

cd ..
echo ""

# Start services
echo "🐳 Starting Docker services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready (30 seconds)..."
sleep 30

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Backend:"
echo "   cd backend"
echo "   source venv/bin/activate"
echo "   uvicorn app.main:app --reload"
echo "   API: http://localhost:8000"
echo "   Docs: http://localhost:8000/docs"
echo ""
echo "2. Mobile (in new terminal):"
echo "   cd mobile"
echo "   flutter run -d <device>"
echo "   Options: emulator, ios, web, chrome"
echo ""
echo "3. View services:"
echo "   docker-compose ps"
echo ""
echo "4. View logs:"
echo "   docker-compose logs -f"
echo ""
echo "5. Stop services:"
echo "   docker-compose down"
echo ""
echo "📚 Documentation:"
echo "   - Backend API: http://localhost:8000/docs"
echo "   - README: https://github.com/AvishkaGihan/wanderai"
echo "   - Contributing: CONTRIBUTING.md"
echo ""
echo "✨ Happy coding!"
