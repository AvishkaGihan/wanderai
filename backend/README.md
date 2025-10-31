# WanderAI Backend API

AI-powered travel planning API built with FastAPI, PostgreSQL, and Google Gemini.

## 🌟 Features

- 🔐 **Firebase Authentication** - Secure user authentication with Firebase Auth
- 💬 **AI Chat** - Interactive travel planning with Google Gemini AI
- 🗺️ **Itinerary Generation** - Smart itinerary creation using AI
- 💰 **Expense Tracking** - Budget management and expense tracking
- 📍 **Destination Search** - Browse and search travel destinations
- 🗄️ **PostgreSQL Database** - Robust data persistence with SQLAlchemy ORM
- 📚 **Auto-generated API Docs** - Interactive Swagger/OpenAPI documentation
- 🖼️ **Image Integration** - Pexels API integration for destination images

## 🛠️ Tech Stack

- **Framework**: FastAPI 0.120.0
- **Database**: PostgreSQL with SQLAlchemy
- **Migrations**: Alembic
- **Authentication**: Firebase Admin SDK
- **AI**: Google Gemini API
- **Image API**: Pexels API
- **Testing**: Pytest
- **Code Quality**: Black, isort, mypy, flake8
- **ASGI Server**: Uvicorn

## 📋 Prerequisites

- Python 3.11+
- PostgreSQL 12+ (or 18+ recommended)
- Git
- Firebase project with credentials
- Google Gemini API key
- Pexels API key (optional, for destination images)

## 🚀 Quick Start

### 1. Installation

```bash
# Navigate to the backend folder
cd backend

# Create virtual environment
python -m venv venv

# Activate virtual environment
# Windows (CMD):
venv\Scripts\activate
# Windows (PowerShell):
venv\Scripts\Activate.ps1
# macOS/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Environment Configuration

Create a `.env` file in the backend root directory:

```env
# Database
DATABASE_URL=postgresql://username:password@localhost:5432/wanderai

# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Private-Key\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token
FIREBASE_AUTH_PROVIDER_CERT_URL=https://www.googleapis.com/oauth2/v1/certs
FIREBASE_CLIENT_CERT_URL=https://www.googleapis.com/robot/v1/metadata/x509/your-service-account%40project.iam.gserviceaccount.com

# Google Gemini AI
GEMINI_API_KEY=your-gemini-api-key

# Pexels API (optional)
PEXELS_API_KEY=your-pexels-api-key

# CORS Settings
CORS_ORIGINS=["http://localhost:3000", "http://localhost:8080", "*"]

# Application Settings
SECRET_KEY=your-secret-key-here
DEBUG=True
ENVIRONMENT=development
```

> **Note**: Place your `firebase-service-account-key.json` file in the backend directory for Firebase authentication.

### 3. Database Setup

```bash
# Initialize database tables
python scripts/init_db.py

# Run migrations
alembic upgrade head

# Seed sample destinations (optional)
python scripts/seed_destinations.py
```

### 4. Running the Application

```bash
# Ensure virtual environment is activated
# Windows (CMD): venv\Scripts\activate
# Windows (PowerShell): venv\Scripts\Activate.ps1
# macOS/Linux: source venv/bin/activate

# Run the development server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`.

### 5. Access API Documentation

Once the server is running, visit:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI Schema**: http://localhost:8000/openapi.json

## 📁 Project Structure

```
backend/
├── alembic/                    # Database migrations
│   ├── versions/              # Migration files
│   └── env.py                 # Alembic environment
├── app/
│   ├── __init__.py
│   ├── main.py                # FastAPI app entry point
│   ├── config.py              # Configuration settings
│   ├── database.py            # Database connection & session
│   ├── dependencies/          # Dependency injection
│   │   └── auth.py           # Authentication dependencies
│   ├── middleware/            # Custom middleware
│   │   ├── error_handler.py  # Global error handling
│   │   └── request_id.py     # Request ID tracking
│   ├── models/                # SQLAlchemy ORM models
│   │   ├── user.py
│   │   ├── trip.py
│   │   ├── destination.py
│   │   ├── expense.py
│   │   └── chat_message.py
│   ├── routes/                # API route handlers
│   │   ├── auth.py
│   │   ├── trips.py
│   │   ├── destinations.py
│   │   ├── expenses.py
│   │   └── chat.py
│   ├── schemas/               # Pydantic schemas (request/response)
│   │   ├── user.py
│   │   ├── trip.py
│   │   ├── destination.py
│   │   ├── expense.py
│   │   └── chat.py
│   ├── services/              # Business logic layer
│   │   ├── firebase_service.py
│   │   ├── gemini_service.py
│   │   └── pexels_service.py
│   └── utils/                 # Utility functions
├── scripts/                    # Database & utility scripts
│   ├── init_db.py             # Database initialization
│   └── seed_destinations.py   # Seed sample data
├── tests/                      # Test suite
│   ├── test_auth.py
│   ├── test_trips.py
│   └── test_gemini.py
├── alembic.ini                 # Alembic configuration
├── pyproject.toml             # Python project metadata
├── pytest.ini                 # Pytest configuration
├── requirements.txt           # Python dependencies
├── Dockerfile                 # Docker configuration
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## 🗄️ Database Management

## 🗄️ Database Management

### Alembic Migrations

This project uses Alembic for database schema migrations.

```bash
# Create a new migration after model changes
alembic revision --autogenerate -m "Description of changes"

# Apply all pending migrations
alembic upgrade head

# Downgrade to previous migration
alembic downgrade -1

# View migration history
alembic history

# Check current migration version
alembic current
```

### Seeding Data

```bash
# Seed destinations with sample data
python scripts/seed_destinations.py
```

## 🧪 Testing

```bash
# Run all tests
pytest

# Run with coverage report
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py

# Run with verbose output
pytest -v

# Run tests matching a pattern
pytest -k "test_trip"
```

View coverage report: Open `htmlcov/index.html` in your browser after running tests with coverage.

## 🔌 API Endpoints

### Authentication

- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - User login
- `GET /api/auth/me` - Get current user profile

### Trips

- `GET /api/trips` - List all user trips
- `POST /api/trips` - Create new trip
- `GET /api/trips/{trip_id}` - Get trip details
- `PUT /api/trips/{trip_id}` - Update trip
- `DELETE /api/trips/{trip_id}` - Delete trip

### Destinations

- `GET /api/destinations` - List destinations
- `GET /api/destinations/{destination_id}` - Get destination details
- `GET /api/destinations/search` - Search destinations

### Expenses

- `GET /api/trips/{trip_id}/expenses` - List trip expenses
- `POST /api/trips/{trip_id}/expenses` - Add expense
- `PUT /api/expenses/{expense_id}` - Update expense
- `DELETE /api/expenses/{expense_id}` - Delete expense

### Chat

- `POST /api/chat` - Send message to AI assistant
- `GET /api/chat/history/{trip_id}` - Get chat history for trip

## 🐳 Docker Support

```bash
# Build Docker image
docker build -t wanderai-backend .

# Run container
docker run -p 8000:8000 --env-file .env wanderai-backend
```

## 🔧 Development

### Code Quality Tools

```bash
# Format code with Black
black .

# Sort imports with isort
isort .

# Type checking with mypy
mypy app/

# Linting with flake8
flake8 app/

# Run all quality checks
black . && isort . && mypy app/ && flake8 app/
```

### Development Workflow

1. Create a feature branch
2. Make your changes
3. Run tests and quality checks
4. Create a pull request

## ⚙️ Configuration

Key configuration files:

- **`alembic.ini`**: Alembic migration settings
- **`pyproject.toml`**: Python project metadata and tool configs
- **`pytest.ini`**: Pytest configuration
- **`.env`**: Environment variables (not in version control)

## 📝 Environment Variables Reference

| Variable                | Description                  | Required | Default |
| ----------------------- | ---------------------------- | -------- | ------- |
| `DATABASE_URL`          | PostgreSQL connection string | Yes      | -       |
| `GEMINI_API_KEY`        | Google Gemini API key        | Yes      | -       |
| `FIREBASE_PROJECT_ID`   | Firebase project ID          | Yes      | -       |
| `FIREBASE_PRIVATE_KEY`  | Firebase private key         | Yes      | -       |
| `FIREBASE_CLIENT_EMAIL` | Firebase client email        | Yes      | -       |
| `PEXELS_API_KEY`        | Pexels API key for images    | No       | -       |
| `SECRET_KEY`            | Application secret key       | Yes      | -       |
| `DEBUG`                 | Enable debug mode            | No       | `False` |
| `CORS_ORIGINS`          | Allowed CORS origins         | No       | `["*"]` |

## 🚨 Troubleshooting

### Database Connection Issues

```bash
# Verify PostgreSQL is running
# Windows:
sc query postgresql-x64-12

# Check if database exists
psql -U postgres -l
```

### Firebase Authentication Errors

- Ensure `firebase-service-account-key.json` is in the backend directory
- Verify all Firebase environment variables are set correctly
- Check Firebase console for project configuration

### Migration Issues

```bash
# Reset database (WARNING: Deletes all data)
alembic downgrade base
alembic upgrade head

# Or reinitialize
python scripts/init_db.py
```

## 📚 Additional Resources

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy ORM](https://docs.sqlalchemy.org/)
- [Alembic Migrations](https://alembic.sqlalchemy.org/)
- [Google Gemini API](https://ai.google.dev/docs)
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Contribution Guidelines

- Follow PEP 8 style guidelines
- Write tests for new features
- Update documentation as needed
- Run all quality checks before submitting PR

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## 👥 Authors

WanderAI Development Team

## 📧 Support

For questions, issues, or feature requests:

- Open an issue on GitHub
- Contact the development team
- Check the documentation

---

**Happy Coding! 🚀**
