import pytest
from fastapi.testclient import TestClient
from app.main import app
from unittest.mock import Mock, patch
from sqlalchemy.orm import Session
import uuid

client = TestClient(app)


@pytest.fixture
def mock_current_user():
    """Mock current user fixture"""
    user = Mock()
    user.id = str(uuid.uuid4())
    user.email = "test@example.com"
    user.uid = "firebase-uid-123"
    return user


@pytest.fixture
def mock_db_session():
    """Mock database session"""
    return Mock(spec=Session)


# ==================== Auth Tests ====================
class TestAuthRoutes:
    """Tests for authentication endpoints"""

    @patch("app.dependencies.auth.get_current_user")
    def test_get_current_user_success(self, mock_auth):
        """Test getting current user info"""
        mock_user = Mock()
        mock_user.id = str(uuid.uuid4())
        mock_user.email = "user@example.com"
        mock_auth.return_value = mock_user

        response = client.get("/v1/auth/me", headers={"Authorization": "Bearer test-token"})
        assert response.status_code == 200
        assert "email" in response.json()

    def test_get_current_user_no_token(self):
        """Test getting current user without token"""
        response = client.get("/v1/auth/me")
        assert response.status_code in [401, 403]


# ==================== Trips Tests ====================
class TestTripsRoutes:
    """Tests for trip management endpoints"""

    @patch("app.dependencies.auth.get_current_user")
    @patch("app.routes.trips.db.session")
    def test_create_trip(self, mock_db, mock_auth, mock_current_user):
        """Test creating a new trip"""
        mock_auth.return_value = mock_current_user

        trip_data = {
            "title": "Paris Getaway",
            "destination": "Paris",
            "start_date": "2025-12-01",
            "end_date": "2025-12-07",
            "budget": 3000.0,
            "status": "draft",
        }

        response = client.post(
            "/v1/trips/", json=trip_data, headers={"Authorization": "Bearer test-token"}
        )

        assert response.status_code in [200, 201]
        assert response.json()["title"] == "Paris Getaway"

    @patch("app.dependencies.auth.get_current_user")
    def test_get_trips_list(self, mock_auth, mock_current_user):
        """Test getting user's trips"""
        mock_auth.return_value = mock_current_user

        response = client.get("/v1/trips/", headers={"Authorization": "Bearer test-token"})

        assert response.status_code == 200
        assert isinstance(response.json(), list)

    @patch("app.dependencies.auth.get_current_user")
    def test_get_trip_by_id(self, mock_auth, mock_current_user):
        """Test getting a specific trip"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        response = client.get(
            f"/v1/trips/{trip_id}", headers={"Authorization": "Bearer test-token"}
        )

        # Response may be 404 if trip doesn't exist, but endpoint should exist
        assert response.status_code in [200, 404]

    @patch("app.dependencies.auth.get_current_user")
    def test_update_trip(self, mock_auth, mock_current_user):
        """Test updating a trip"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        update_data = {
            "title": "Updated Paris Trip",
            "budget": 3500.0,
        }

        response = client.put(
            f"/v1/trips/{trip_id}",
            json=update_data,
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 404]

    @patch("app.dependencies.auth.get_current_user")
    def test_delete_trip(self, mock_auth, mock_current_user):
        """Test deleting a trip"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        response = client.delete(
            f"/v1/trips/{trip_id}",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 404]


# ==================== Chat Tests ====================
class TestChatRoutes:
    """Tests for chat endpoints"""

    @patch("app.dependencies.auth.get_current_user")
    @patch("app.services.gemini_service.GeminiService.generate_itinerary")
    def test_send_chat_message(self, mock_gemini, mock_auth, mock_current_user):
        """Test sending a chat message"""
        mock_auth.return_value = mock_current_user
        mock_gemini.return_value = "Here's your suggested itinerary..."

        message_data = {
            "content": "Plan a 5-day trip to Tokyo",
            "trip_id": str(uuid.uuid4()),
        }

        response = client.post(
            "/v1/chat/message",
            json=message_data,
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 201, 400]
        if response.status_code in [200, 201]:
            assert "content" in response.json() or "message" in response.json()

    @patch("app.dependencies.auth.get_current_user")
    def test_get_chat_history(self, mock_auth, mock_current_user):
        """Test retrieving chat history"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        response = client.get(
            f"/v1/chat/history/{trip_id}",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 404]
        if response.status_code == 200:
            assert isinstance(response.json(), list)


# ==================== Destinations Tests ====================
class TestDestinationsRoutes:
    """Tests for destination endpoints"""

    @patch("app.dependencies.auth.get_current_user")
    def test_get_destinations(self, mock_auth, mock_current_user):
        """Test getting destinations list"""
        mock_auth.return_value = mock_current_user

        response = client.get("/v1/destinations/", headers={"Authorization": "Bearer test-token"})

        assert response.status_code == 200
        assert isinstance(response.json(), list)

    @patch("app.dependencies.auth.get_current_user")
    def test_search_destinations(self, mock_auth, mock_current_user):
        """Test searching destinations"""
        mock_auth.return_value = mock_current_user

        response = client.get(
            "/v1/destinations/search?query=Paris",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 400]
        if response.status_code == 200:
            assert isinstance(response.json(), list)

    @patch("app.dependencies.auth.get_current_user")
    def test_get_destination_by_id(self, mock_auth, mock_current_user):
        """Test getting destination details"""
        mock_auth.return_value = mock_current_user
        dest_id = str(uuid.uuid4())

        response = client.get(
            f"/v1/destinations/{dest_id}",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 404]


# ==================== Expenses Tests ====================
class TestExpensesRoutes:
    """Tests for expense tracking endpoints"""

    @patch("app.dependencies.auth.get_current_user")
    def test_add_expense(self, mock_auth, mock_current_user):
        """Test adding an expense"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        expense_data = {
            "trip_id": trip_id,
            "description": "Hotel booking",
            "amount": 150.0,
            "category": "accommodation",
        }

        response = client.post(
            "/v1/expenses/",
            json=expense_data,
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 201, 400]

    @patch("app.dependencies.auth.get_current_user")
    def test_get_expenses(self, mock_auth, mock_current_user):
        """Test getting trip expenses"""
        mock_auth.return_value = mock_current_user
        trip_id = str(uuid.uuid4())

        response = client.get(
            f"/v1/expenses/?trip_id={trip_id}",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code == 200
        assert isinstance(response.json(), list)

    @patch("app.dependencies.auth.get_current_user")
    def test_update_expense(self, mock_auth, mock_current_user):
        """Test updating an expense"""
        mock_auth.return_value = mock_current_user
        expense_id = str(uuid.uuid4())

        update_data = {"amount": 200.0}

        response = client.put(
            f"/v1/expenses/{expense_id}",
            json=update_data,
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 404]

    @patch("app.dependencies.auth.get_current_user")
    def test_delete_expense(self, mock_auth, mock_current_user):
        """Test deleting an expense"""
        mock_auth.return_value = mock_current_user
        expense_id = str(uuid.uuid4())

        response = client.delete(
            f"/v1/expenses/{expense_id}",
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [200, 204, 404]


# ==================== Health & System Tests ====================
class TestHealthAndSystem:
    """Tests for system endpoints"""

    def test_health_check(self):
        """Test health check endpoint"""
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "healthy"

    def test_root_endpoint(self):
        """Test root endpoint"""
        response = client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert "message" in data
        assert "version" in data

    def test_api_docs(self):
        """Test API documentation endpoint"""
        response = client.get("/docs")
        assert response.status_code == 200

    def test_openapi_schema(self):
        """Test OpenAPI schema endpoint"""
        response = client.get("/openapi.json")
        assert response.status_code == 200
        assert response.json()["info"]["title"] == "WanderAI API"


# ==================== Error Handling Tests ====================
class TestErrorHandling:
    """Tests for error handling and validation"""

    @patch("app.dependencies.auth.get_current_user")
    def test_invalid_trip_data(self, mock_auth, mock_current_user):
        """Test validation of invalid trip data"""
        mock_auth.return_value = mock_current_user

        invalid_trip_data = {
            "title": "",  # Invalid: empty title
            "destination": "",
            "budget": -100,  # Invalid: negative budget
        }

        response = client.post(
            "/v1/trips/",
            json=invalid_trip_data,
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code == 422  # Validation error

    def test_invalid_json_payload(self):
        """Test handling of invalid JSON payload"""
        response = client.post(
            "/v1/trips/",
            content="invalid json",
            headers={
                "Authorization": "Bearer test-token",
                "Content-Type": "application/json",
            },
        )

        assert response.status_code in [400, 422]

    def test_missing_required_fields(self):
        """Test handling of missing required fields"""
        response = client.post(
            "/v1/trips/",
            json={},
            headers={"Authorization": "Bearer test-token"},
        )

        assert response.status_code in [400, 422]
