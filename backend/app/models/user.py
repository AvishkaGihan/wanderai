from sqlalchemy import Column, String, DateTime, JSON
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timezone
import uuid
from app.database import Base


def utcnow():
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    firebase_uid = Column(String, unique=True, nullable=False, index=True)
    email = Column(String, unique=True, nullable=False)
    display_name = Column(String)
    preferences = Column(JSON, default={})
    created_at = Column(DateTime, default=utcnow)
    updated_at = Column(DateTime, default=utcnow, onupdate=utcnow)
