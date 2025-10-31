from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.user import User
from app.services.firebase_service import FirebaseService
import logging

logger = logging.getLogger(__name__)

# Use the HTTPBearer scheme for extracting the token from the Authorization header
security = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db),
) -> User:
    """Verify Firebase JWT token and return current user"""
    try:
        # Verify token with Firebase
        firebase_service = FirebaseService()
        decoded_token = firebase_service.verify_token(credentials.credentials)

        firebase_uid = decoded_token.get("uid")
        if not firebase_uid:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication token",
            )

        # Get or create user in our local PostgreSQL database
        user = db.query(User).filter(User.firebase_uid == firebase_uid).first()
        if not user:
            # Create new user from Firebase data if they don't exist
            user = User(
                firebase_uid=firebase_uid,
                email=decoded_token.get("email"),
                display_name=decoded_token.get("name"),
            )
            db.add(user)
            db.commit()
            db.refresh(user)

        return user

    except Exception as e:
        logger.error(f"Authentication error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
        )
