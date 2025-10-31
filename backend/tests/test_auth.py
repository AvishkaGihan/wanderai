from fastapi.testclient import TestClient
from app.main import app

# Create a test client pointing to your main app instance
client = TestClient(app)


def test_health_check():
    """Test health check endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


def test_root_endpoint():
    """Test root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    assert "message" in response.json()
    # Note: Full authentication tests require mocking Firebase, which is more complex.
