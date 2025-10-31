# Contributing to WanderAI

Thank you for your interest in contributing to WanderAI! This guide will help you get started.

## Development Setup

### Backend Development

```bash
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy environment file
cp .env.example .env

# Run development server with auto-reload
uvicorn app.main:app --reload

# API will be available at http://localhost:8000
# API Docs: http://localhost:8000/docs
```

### Mobile Development

```bash
cd mobile

# Get dependencies
flutter pub get

# Run on desired platform
flutter run -d emulator     # Android emulator
flutter run -d ios          # iOS simulator
flutter run -d web          # Web browser
```

## Running Tests

### Backend Tests

```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_auth.py -v

# Run tests matching pattern
pytest -k "test_create_trip" -v

# Run with markers
pytest -m "not slow" -v
```

### Mobile Tests

```bash
cd mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/models/trip_model_test.dart

# Generate coverage
flutter test --coverage
```

## Code Quality

### Backend Code Style

We use:

- **Black** for formatting
- **isort** for import sorting
- **flake8** for linting
- **mypy** for type checking

```bash
cd backend

# Format code with black
black app

# Sort imports
isort app

# Check style
flake8 app

# Type checking
mypy app
```

### Mobile Code Style

```bash
cd mobile

# Analyze code
dart analyze

# Format code
dart format lib

# Run linter
flutter analyze
```

## Making Changes

### 1. Fork and Clone

```bash
# Fork on GitHub, then
git clone https://github.com/YOUR_USERNAME/wanderai.git
cd wanderai
```

### 2. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

Branch naming convention:

- `feature/add-something` - New feature
- `fix/bug-description` - Bug fix
- `docs/update-readme` - Documentation
- `refactor/component-name` - Code refactoring

### 3. Make Changes

- Follow existing code style
- Add tests for new functionality
- Update documentation as needed
- Keep commits atomic and well-described

### 4. Test Your Changes

```bash
# Backend
cd backend
pytest --cov=app

# Mobile
cd mobile
flutter test

# Both should pass without errors
```

### 5. Commit with Meaningful Messages

```bash
git add .
git commit -m "feat: add trip sharing feature"
```

Commit types:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a PR on GitHub with:

- Clear title describing changes
- Description of what changed and why
- Reference to any related issues (#123)
- Screenshots for UI changes (mobile)

## PR Requirements

For a PR to be merged:

- ✅ All tests pass
- ✅ Code style checks pass (Black, flake8, mypy)
- ✅ >80% code coverage for new code
- ✅ No merge conflicts
- ✅ Meaningful commit messages
- ✅ PR description is clear
- ✅ Documentation updated if needed

## Project Structure

### Backend (`backend/app/`)

```
app/
├── routes/          # API endpoint handlers
├── models/          # SQLAlchemy ORM models
├── schemas/         # Pydantic request/response schemas
├── services/        # Business logic (Gemini, Firebase, Pexels)
├── middleware/      # Error handling, rate limiting
├── dependencies/    # Authentication, dependency injection
├── database.py      # Database configuration
├── config.py        # Application settings
└── main.py          # FastAPI app initialization
```

### Mobile (`mobile/lib/`)

```
lib/
├── models/          # Data models
├── providers/       # Riverpod state management
├── screens/         # UI screens
├── services/        # API client, Firebase, local storage
├── widgets/         # Reusable UI components
├── utils/           # Helper functions
├── config/          # App configuration
└── main.dart        # App entry point
```

## Adding New Features

### Backend: Adding a New API Endpoint

1. Create schema in `app/schemas/`:

```python
# app/schemas/new_feature.py
from pydantic import BaseModel

class NewFeatureCreate(BaseModel):
    name: str
    description: str

class NewFeatureResponse(BaseModel):
    id: str
    name: str
    description: str
```

2. Create model in `app/models/`:

```python
# app/models/new_feature.py
from sqlalchemy import Column, String, DateTime
from app.database import Base

class NewFeature(Base):
    __tablename__ = "new_features"

    id = Column(String, primary_key=True)
    name = Column(String, index=True)
    description = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
```

3. Create route in `app/routes/`:

```python
# app/routes/new_feature.py
from fastapi import APIRouter, Depends, HTTPException
from app.dependencies.auth import get_current_user
from app.schemas.new_feature import NewFeatureCreate, NewFeatureResponse

router = APIRouter()

@router.post("/", response_model=NewFeatureResponse)
async def create_new_feature(
    data: NewFeatureCreate,
    current_user = Depends(get_current_user),
):
    # Implementation here
    pass
```

4. Add tests in `backend/tests/`:

```python
# backend/tests/test_new_feature.py
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_create_new_feature():
    response = client.post(
        "/v1/new_feature/",
        json={"name": "Test", "description": "Test feature"}
    )
    assert response.status_code == 201
```

### Mobile: Adding a New Screen

1. Create model in `lib/models/`:

```dart
class NewFeatureModel {
  final String id;
  final String name;
  final String description;

  NewFeatureModel({
    required this.id,
    required this.name,
    required this.description,
  });
}
```

2. Create provider in `lib/providers/`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final newFeatureProvider = FutureProvider<List<NewFeatureModel>>((ref) async {
  // Fetch data using API client
  return [];
});
```

3. Create screen in `lib/screens/`:

```dart
class NewFeatureScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final features = ref.watch(newFeatureProvider);

    return Scaffold(
      appBar: AppBar(title: Text('New Feature')),
      body: features.when(
        data: (data) => ListView(children: []),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      ),
    );
  }
}
```

4. Add tests in `mobile/test/`:

```dart
void main() {
  group('NewFeatureScreen', () {
    testWidgets('displays features', (WidgetTester tester) async {
      // Test implementation
    });
  });
}
```

## CI/CD Pipeline

GitHub Actions automatically runs:

1. **Backend Tests** - Python linting, pytest, coverage
2. **Flutter Analysis** - Dart analysis, tests
3. **Docker Build** - Build and push Docker image (on main branch)

All must pass for PR to be merged.

## Documentation

### Backend Documentation

- Update `backend/README.md` for API changes
- Add docstrings to new functions
- Update `.env.example` for new environment variables

### Mobile Documentation

- Update `mobile/README.md` for new screens
- Add comments to complex business logic
- Update feature documentation

### Project Documentation

- Update `README.md` for project-level changes
- Update `DEPLOYMENT.md` for deployment changes
- Add CHANGELOG entries for releases

## Reporting Issues

When reporting a bug:

1. Check if issue already exists
2. Include:
   - Steps to reproduce
   - Expected behavior
   - Actual behavior
   - Screenshots/logs if applicable
   - Environment (Python version, Flutter version, OS)
3. Use clear title describing the issue

## Questions?

- Open an issue for questions
- Check existing issues and documentation first
- Ask in PR comments if needed

## Code of Conduct

- Be respectful and inclusive
- No harassment or discrimination
- Follow project guidelines
- Report violations to maintainers

---

Thank you for contributing to WanderAI! 🙏
