from pydantic import BaseModel
from typing import Optional, List
from datetime import date, datetime
from uuid import UUID


class ActivityBase(BaseModel):
    title: str
    description: Optional[str] = None
    time: Optional[str] = None
    duration: Optional[int] = None
    cost: Optional[float] = None
    category: Optional[str] = None
    location: Optional[str] = None


class ActivityCreate(ActivityBase):
    pass


class ActivityResponse(ActivityBase):
    id: UUID
    day_id: UUID

    class Config:
        from_attributes = True


class ActivityUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    time: Optional[str] = None
    duration: Optional[int] = None
    cost: Optional[float] = None
    category: Optional[str] = None
    location: Optional[str] = None


class DayBase(BaseModel):
    date: date
    title: Optional[str] = None
    order: int


class DayCreate(DayBase):
    activities: List[ActivityCreate] = []


class DayResponse(DayBase):
    id: UUID
    trip_id: UUID
    activities: List[ActivityResponse] = []

    class Config:
        from_attributes = True


class TripBase(BaseModel):
    title: str
    destination: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    budget: Optional[float] = None
    status: Optional[str] = "draft"


class TripCreate(TripBase):
    pass


class TripUpdate(BaseModel):
    title: Optional[str] = None
    destination: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    budget: Optional[float] = None
    status: Optional[str] = None


class TripResponse(TripBase):
    id: UUID
    user_id: UUID
    created_at: datetime
    updated_at: datetime

    # Pexels image fields
    image_url: Optional[str] = None
    photographer: Optional[str] = None
    photographer_url: Optional[str] = None

    days: List[DayResponse] = []

    class Config:
        from_attributes = True


class ItineraryGenerateRequest(BaseModel):
    chat_session_id: str
