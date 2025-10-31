import pytest
import uuid
from fastapi.testclient import TestClient
from app.main import app
from unittest.mock import Mock, patch

client = TestClient(app)


@pytest.fixture
def mock_auth():
    """Mock authentication dependency to bypass Firebase check during tests"""
    with patch("app.dependencies.auth.get_current_user") as mock:
        # Set up a mock user that the route will receive
        mock_user = Mock()
        # Use a consistent UUID structure for testing purposes
        mock_user.id = uuid.uuid4()
        mock_user.email = "test@example.com"
        mock.return_value = mock_user
        yield mock


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

    # We send a dummy Authorization header, but the mock_auth fixture handles the actual check
    response = client.post(
        "/v1/trips/", json=trip_data, headers={"Authorization": "Bearer test-token"}
    )

    assert response.status_code == 201
    assert response.json()["title"] == "Tokyo Adventure"
    # Additional assertions would check the database directly in a real setup
