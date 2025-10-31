from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database import get_db
from app.schemas.user import UserResponse, UserUpdate
from app.dependencies.auth import get_current_user
from app.models.user import User

router = APIRouter()


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(current_user: User = Depends(get_current_user)):
    """Get current authenticated user profile"""
    # get_current_user returns the ORM object, which FastAPI converts to UserResponse
    return current_user


@router.put("/me", response_model=UserResponse)
async def update_user_profile(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update current user profile"""
    # Check for optional fields and update them
    if user_update.display_name is not None:
        current_user.display_name = user_update.display_name  # type: ignore

    if user_update.preferences is not None:
        current_user.preferences = user_update.preferences  # type: ignore

    # Commit changes to the database
    db.commit()
    db.refresh(current_user)
    return current_user
