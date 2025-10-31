from pydantic import BaseModel
from typing import List, Optional
from uuid import UUID
from datetime import datetime


class DestinationResponse(BaseModel):
    id: UUID
    name: str
    country: Optional[str] = None
    description: Optional[str] = None
    budget: Optional[float] = None
    attractions: List[str] = []
    image_url: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True
