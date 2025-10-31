from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime
from uuid import UUID


class ExpenseBase(BaseModel):
    category: str
    amount: float
    currency: str = "USD"
    date: date
    description: Optional[str] = None


class ExpenseCreate(ExpenseBase):
    pass


class ExpenseResponse(ExpenseBase):
    id: UUID
    trip_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True
