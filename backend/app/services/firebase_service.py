import firebase_admin
from firebase_admin import auth, credentials
import logging
from app.config import settings

logger = logging.getLogger(__name__)


class FirebaseService:
    _initialized = False

    def __init__(self):
        # We only want to initialize Firebase Admin SDK once
        if not FirebaseService._initialized:
            try:
                # Initialize Firebase Admin SDK with service account credentials
                cred = credentials.Certificate("firebase-service-account-key.json")
                firebase_admin.initialize_app(cred, {"projectId": settings.FIREBASE_PROJECT_ID})
                FirebaseService._initialized = True
                logger.info("Firebase initialized successfully")
            except Exception as e:
                logger.error(f"Firebase initialization failed: {str(e)}")
                raise

    def verify_token(self, token: str) -> dict:
        """Verify Firebase ID token"""
        try:
            # This calls the Firebase Auth API to verify the JWT token
            decoded_token = auth.verify_id_token(token)
            return decoded_token
        except Exception as e:
            logger.error(f"Token verification failed: {str(e)}")
            raise ValueError("Invalid token")
