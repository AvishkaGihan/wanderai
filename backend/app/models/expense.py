from sqlalchemy import Column, String, Date, DateTime, DECIMAL, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
from app.database import Base


def utcnow():
    return datetime.now(timezone.utc)


class Expense(Base):
    __tablename__ = "expenses"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(UUID(as_uuid=True), ForeignKey("trips.id", ondelete="CASCADE"), nullable=False)
    category = Column(String, nullable=False)
    amount = Column(DECIMAL(10, 2), nullable=False)
    currency = Column(String, default="USD")
    date = Column(Date, nullable=False)
    description = Column(Text)
    created_at = Column(DateTime, default=utcnow)

    # Relationships
    trip = relationship("Trip", back_populates="expenses")
