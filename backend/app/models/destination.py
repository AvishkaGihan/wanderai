from sqlalchemy import Column, String, Text, DECIMAL, JSON, DateTime
from sqlalchemy.dialects.postgresql import UUID
from datetime import datetime, timezone
import uuid
from app.database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Destination(Base):
    __tablename__ = "destinations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, nullable=False, index=True)
    country = Column(String)
    description = Column(Text)
    budget = Column(DECIMAL(10, 2))
    attractions = Column(JSON, default=[])
    image_url = Column(String)
    created_at = Column(DateTime, default=utcnow)
