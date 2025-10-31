from pydantic import BaseModel
from typing import Optional
from datetime import datetime
from uuid import UUID


class ChatMessageRequest(BaseModel):
    message: str
    session_id: Optional[str] = None


class ChatMessageResponse(BaseModel):
    response: str
    session_id: str
    timestamp: datetime


class ChatHistoryResponse(BaseModel):
    id: UUID
    role: str
    content: str
    timestamp: datetime

    class Config:
        from_attributes = True
