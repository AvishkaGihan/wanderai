from __future__ import annotations

from sqlalchemy import (
    Column,
    String,
    Date,
    DateTime,
    DECIMAL,
    ForeignKey,
    Integer,
    Text,
    Time,
)
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime, timezone
import uuid
from app.database import Base


class Trip(Base):
    __tablename__ = "trips"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    destination = Column(String)
    start_date = Column(Date)
    end_date = Column(Date)
    budget = Column(DECIMAL(10, 2))
    status = Column(String, default="draft")

    # Pexels image fields
    image_url = Column(Text, nullable=True)
    photographer = Column(String, nullable=True)
    photographer_url = Column(Text, nullable=True)

    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    updated_at = Column(
        DateTime,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )

    # Relationships
    days = relationship("Day", back_populates="trip", cascade="all, delete-orphan")
    expenses = relationship("Expense", back_populates="trip", cascade="all, delete-orphan")


class Day(Base):
    __tablename__ = "days"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    trip_id = Column(UUID(as_uuid=True), ForeignKey("trips.id", ondelete="CASCADE"), nullable=False)
    date = Column(Date, nullable=False)
    title = Column(String)
    order = Column(Integer, nullable=False)

    # Relationships
    trip = relationship("Trip", back_populates="days")
    activities = relationship(
        "Activity", back_populates="day", cascade="all, delete-orphan", lazy="select"
    )


class Activity(Base):
    __tablename__ = "activities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    day_id = Column(UUID(as_uuid=True), ForeignKey("days.id", ondelete="CASCADE"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text)
    time = Column(Time)
    duration = Column(Integer)  # minutes
    cost = Column(DECIMAL(10, 2))
    category = Column(String)
    location = Column(String)

    # Relationships
    day = relationship("Day", back_populates="activities")
