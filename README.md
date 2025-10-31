# WanderAI

![Tests](https://github.com/AvishkaGihan/wanderai/actions/workflows/backend-tests.yml/badge.svg)
![Flutter Analysis](https://github.com/AvishkaGihan/wanderai/actions/workflows/flutter-tests.yml/badge.svg)
![Docker Build](https://github.com/AvishkaGihan/wanderai/actions/workflows/docker-build.yml/badge.svg)

WanderAI is a cross-platform, AI-powered travel planning application combining a Python FastAPI backend with a Flutter mobile app. It helps users plan trips, manage budgets, and get AI-powered itinerary recommendations using Google Gemini.

## ✨ Key Features

- 🤖 **AI-Powered Planning** - Get personalized itineraries using Google Gemini
- 💬 **Interactive Chat** - Real-time travel planning discussions with AI
- 🗺️ **Destination Insights** - Browse destinations with images and information
- 💰 **Expense Tracking** - Manage trip budgets and expenses
- 🔐 **Secure Authentication** - Firebase Authentication with JWT tokens
- 📱 **Cross-Platform** - iOS and Android support via Flutter
- 🚀 **Production Ready** - Docker, CI/CD, Sentry monitoring

## 🛠️ Tech Stack

### Backend

- **Framework**: FastAPI 0.120.0
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Cache**: Redis
- **AI**: Google Gemini API
- **Authentication**: Firebase Admin SDK
- **Monitoring**: Sentry
- **Server**: Uvicorn
- **Testing**: Pytest with >60% coverage
- **CI/CD**: GitHub Actions

### Mobile

- **Framework**: Flutter (Dart 3.9+)
- **State Management**: Riverpod
- **API Client**: Dio with pretty logging
- **Firebase**: Auth, Firestore
- **Local Storage**: Hive, SQLite, SharedPreferences
- **UI**: Material Design, Lottie animations

## 📋 Prerequisites

- **Python** 3.11+
- **Flutter** 3.9+
- **Docker** & **Docker Compose** (recommended)
- **PostgreSQL** 16+ (or use Docker)
- **Redis** (or use Docker)
- **Firebase** project with credentials
- **Google Gemini API** key
- **Pexels API** key (optional)

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended)

The easiest way to run the entire stack locally:

```bash
# 1. Clone the repository
git clone https://github.com/AvishkaGihan/wanderai.git
cd wanderai

# 2. Copy environment template
cp backend/.env.example backend/.env

# 3. Update .env with your API keys (Firebase, Gemini, etc.)
# Edit backend/.env and add your credentials

# 4. Start all services
docker-compose up -d

# 5. Access the API
# API: http://localhost:8000
# Docs: http://localhost:8000/docs
# Health: http://localhost:8000/health
```

### Option 2: Local Development Setup

#### Backend Setup

```bash
# Navigate to backend
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Setup environment variables
cp .env.example .env
# Edit .env with your credentials

# Initialize database
python scripts/init_db.py

# Run development server
uvicorn app.main:app --reload
```

#### Mobile Setup

```bash
# Navigate to mobile
cd mobile

# Get dependencies
flutter pub get

# Run on Android emulator/device
flutter run -d android

# Run on iOS simulator/device
flutter run -d ios

# Run on web
flutter run -d web
```

## 📚 API Documentation

Interactive API documentation is available at:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI Schema**: `http://localhost:8000/openapi.json`

### Main Endpoints

- **Auth**: `/v1/auth/` - User authentication
- **Chat**: `/v1/chat/` - AI conversation & itinerary generation
- **Trips**: `/v1/trips/` - Trip management
- **Destinations**: `/v1/destinations/` - Destination information
- **Expenses**: `/v1/expenses/` - Budget tracking

See [backend/README.md](./backend/README.md) for detailed API documentation.

## 🧪 Testing

### Backend Tests

```bash
cd backend

# Run all tests with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py -v

# Run with markers
pytest -m "not slow" -v
```

### Mobile Tests

```bash
cd mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/services/api_service_test.dart

# Generate coverage report
flutter test --coverage
```

## 📦 Environment Configuration

Create a `.env` file in the backend directory:

```env
# Development
ENVIRONMENT=development
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/wanderai_dev
SECRET_KEY=your-dev-secret-key-change-for-production

# Firebase (get from Firebase Console)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_WEB_API_KEY=your-api-key

# Google Gemini (get from https://aistudio.google.com)
GEMINI_API_KEY=your-gemini-api-key

# Optional
PEXELS_API_KEY=your-pexels-key
SENTRY_DSN=your-sentry-dsn

# CORS (for development)
CORS_ORIGINS=http://localhost:3000,http://localhost:8000
```

See [.env.example](./backend/.env.example) for all available options.

## 🔒 Security

- ✅ No hardcoded credentials in code
- ✅ Environment-based configuration
- ✅ CORS restricted in production
- ✅ Rate limiting on API endpoints (100 req/min)
- ✅ Error handling with Sentry monitoring
- ✅ Secure password hashing with bcrypt
- ✅ JWT token authentication
- ✅ Non-root Docker user

## 🐳 Docker Commands

```bash
# Build and start services
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop services
docker-compose down

# Remove volumes (caution: deletes data)
docker-compose down -v

# Production deployment
docker-compose -f docker-compose.prod.yml up -d
```

## 📊 CI/CD Pipeline

GitHub Actions workflows:

1. **Backend Tests** - Linting, testing, coverage
2. **Flutter Analysis** - Code analysis and tests
3. **Docker Build** - Build and push Docker images to registry

View CI/CD status: https://github.com/AvishkaGihan/wanderai/actions

## 🚢 Deployment

### Production Checklist

- [ ] Set `ENVIRONMENT=production`
- [ ] Update `SECRET_KEY` with strong random key
- [ ] Configure production database
- [ ] Set proper `CORS_ORIGINS` (no wildcard)
- [ ] Configure Sentry for error tracking
- [ ] Use managed PostgreSQL and Redis
- [ ] Enable HTTPS/TLS
- [ ] Configure Firebase production credentials

### Cloud Deployment Options

- **Google Cloud Run** - Serverless container deployment
- **AWS ECS/Fargate** - Container orchestration
- **DigitalOcean App Platform** - PaaS
- **Heroku** - Platform as a service

## 📁 Project Structure

```
wanderai/
├── backend/
│   ├── app/
│   │   ├── routes/           # API endpoints
│   │   ├── models/           # SQLAlchemy models
│   │   ├── schemas/          # Pydantic schemas
│   │   ├── services/         # Business logic (Gemini, Firebase)
│   │   ├── middleware/       # Error handling, rate limiting
│   │   ├── dependencies/     # Authentication, dependency injection
│   │   └── main.py          # FastAPI app setup
│   ├── tests/                # Test suite
│   ├── scripts/              # Database initialization
│   ├── Dockerfile            # Multi-stage production Docker image
│   └── requirements.txt       # Python dependencies
├── mobile/
│   ├── lib/
│   │   ├── models/           # Data models
│   │   ├── providers/        # Riverpod providers
│   │   ├── screens/          # UI screens
│   │   ├── services/         # API client, Firebase
│   │   ├── widgets/          # Reusable widgets
│   │   └── main.dart         # App entry point
│   └── pubspec.yaml          # Flutter dependencies
├── .github/
│   └── workflows/            # GitHub Actions CI/CD
├── docker-compose.yml        # Development services
├── docker-compose.prod.yml   # Production services
└── README.md                 # This file
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is open source. See LICENSE file for details.

## 🙋 Support

For questions or issues:

- Open an [GitHub Issue](https://github.com/AvishkaGihan/wanderai/issues)
- Check existing documentation in [backend/README.md](./backend/README.md)
- Review API docs at `/docs` endpoint

## 📧 Contact

- Author: Avishka Gihan
- GitHub: [@AvishkaGihan](https://github.com/AvishkaGihan)

---

**Built with ❤️ for travel enthusiasts who love AI**

3. Configure Firebase:

   - Copy your Firebase configuration files to the appropriate directories
   - Update `lib/firebase_options.dart` with your Firebase project details

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

### Backend API

The backend provides RESTful APIs for:

- User management
- Travel planning
- AI recommendations
- Data storage and retrieval

API documentation available at `http://localhost:8000/docs` when running with FastAPI.

### Mobile App

The Flutter app provides:

- User authentication
- Travel itinerary creation
- AI-powered suggestions
- Offline functionality
- Cross-platform compatibility (iOS/Android)

## Project Structure

```
wanderai/
├── apps/
│   ├── backend/          # Python FastAPI backend
│   │   ├── app/
│   │   │   ├── main.py
│   │   │   ├── models/
│   │   │   ├── routes/
│   │   │   ├── schemas/
│   │   │   ├── services/
│   │   │   └── utils/
│   │   └── requirements.txt
│   └── mobile/           # Flutter mobile app
│       ├── lib/
│       ├── android/
│       ├── ios/
│       └── pubspec.yaml
├── docs/                 # Documentation
├── infrastructure/       # Infrastructure as Code
├── packages/
│   └── shared/          # Shared code/packages
├── .env.example         # Environment variables template
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Development

### Running Tests

#### Backend

```bash
cd apps/backend
pytest
```

#### Mobile

```bash
cd apps/mobile
flutter test
```

### Code Quality

- Use `black` for Python code formatting
- Use `flake8` for Python linting
- Follow Flutter's recommended code style

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Environment Variables

Copy `.env.example` to `.env` and fill in your values:

- `DATABASE_URL`: PostgreSQL connection string
- `REDIS_URL`: Redis connection URL
- `SECRET_KEY`: JWT secret key
- `API_BASE_URL`: Backend API URL for mobile app
- `FLUTTER_APP_ENV`: Environment (development/production)

## Deployment

### Backend

- Use Docker for containerization
- Deploy to cloud platforms (AWS, GCP, Azure)
- Set up CI/CD pipelines

### Mobile

- Build APKs for Android
- Build IPAs for iOS
- Publish to app stores

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, email support@wanderai.com or create an issue in this repository.

## Roadmap

- [ ] AI-powered travel recommendations
- [ ] Offline itinerary management
- [ ] Social features for trip sharing
- [ ] Integration with booking APIs
- [ ] Multi-language support
- [ ] Advanced analytics dashboard
