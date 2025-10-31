import pytest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from app.dependencies.auth import get_current_user
from unittest.mock import Mock
from app.models.user import User


# Create a mock user for testing
def mock_current_user_func():
    mock_user = Mock(spec=User)
    mock_user.id = uuid.uuid4()
    mock_user.email = "test@example.com"
    mock_user.firebase_uid = "test-firebase-uid"
    return mock_user


# Override the dependency at app level
app.dependency_overrides[get_current_user] = mock_current_user_func

client = TestClient(app)


@pytest.fixture
def mock_auth():
    """Mock authentication dependency to bypass Firebase check during tests"""
    # The dependency override is set above, this fixture ensures it's active
    yield
    # Clean up after test
    if get_current_user in app.dependency_overrides:
        del app.dependency_overrides[get_current_user]


def test_create_trip(mock_auth):
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
    response = client.post(
        "/v1/trips/", json=trip_data, headers={"Authorization": "Bearer test-token"}
    )

    assert response.status_code == 201
    assert response.json()["title"] == "Tokyo Adventure"
    # Additional assertions would check the database directly in a real setup
