from pydantic import BaseModel, EmailStr
from typing import Optional, Dict, Any
from datetime import datetime
from uuid import UUID


class UserBase(BaseModel):
    email: EmailStr
    display_name: Optional[str] = None
    preferences: Optional[Dict[str, Any]] = {}


class UserCreate(UserBase):
    firebase_uid: str


class UserUpdate(BaseModel):
    display_name: Optional[str] = None
    preferences: Optional[Dict[str, Any]] = None


class UserResponse(UserBase):
    id: UUID
    firebase_uid: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
