import pytest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from app.dependencies.auth import get_current_user
from app.database import Base, engine, SessionLocal
from app.models.user import User
from unittest.mock import Mock, patch


# Create a consistent test user ID for use across tests
TEST_USER_ID = uuid.uuid4()


# Create a mock user for testing with the consistent ID
def mock_current_user_func():
    mock_user = Mock(spec=User)
    mock_user.id = TEST_USER_ID
    mock_user.email = "test@example.com"
    mock_user.firebase_uid = "test-firebase-uid"
    return mock_user


# Setup: Create all database tables before running tests
@pytest.fixture(scope="session", autouse=True)
def setup_database():
    """Create all database tables for testing"""
    Base.metadata.create_all(bind=engine)
    yield
    # Optionally drop tables after tests
    # Base.metadata.drop_all(bind=engine)


@pytest.fixture
def test_client():
    """Create a test client with mocked auth and database"""
    # Create a test user in the database
    db = SessionLocal()
    try:
        # Check if test user already exists
        existing_user = db.query(User).filter(User.id == TEST_USER_ID).first()
        if not existing_user:
            test_user = User(
                id=TEST_USER_ID,
                firebase_uid="test-firebase-uid",
                email="test@example.com",
                display_name="Test User",
            )
            db.add(test_user)
            db.commit()
    finally:
        db.close()

    # Override auth dependency
    app.dependency_overrides[get_current_user] = mock_current_user_func

    # Mock external services to avoid API calls during testing
    with patch(
        "app.services.pexels_service.PexelsService.get_destination_image", return_value=None
    ):
        client = TestClient(app)
        yield client

    # Clean up
    app.dependency_overrides.clear()


def test_create_trip(test_client):
    """Test trip creation endpoint with mocked authentication"""
    trip_data = {
        "title": "Tokyo Adventure",
        "destination": "Tokyo",
        "start_date": "2025-12-01",
        "end_date": "2025-12-07",
        "budget": 2000.0,
        "status": "draft",
    }

    # Send request with mocked auth
    response = test_client.post(
        "/v1/trips/", json=trip_data, headers={"Authorization": "Bearer test-token"}
    )

    # Accept both 200 and 201, depending on endpoint implementation
    assert response.status_code in [200, 201], f"Got {response.status_code}: {response.text}"
    response_data = response.json()
    assert response_data["title"] == "Tokyo Adventure"
    assert response_data["destination"] == "Tokyo"
