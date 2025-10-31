from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List
from datetime import datetime, timezone
import uuid

from app.database import get_db
from app.schemas.chat import (
    ChatMessageRequest,
    ChatMessageResponse,
    ChatHistoryResponse,
)
from app.models.chat_message import ChatMessage
from app.models.user import User
from app.dependencies.auth import get_current_user
from app.services.gemini_service import GeminiService

router = APIRouter()


@router.post("/", response_model=ChatMessageResponse)
async def send_chat_message(
    request: ChatMessageRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Send a message to AI and get response"""
    # Generate or use existing session ID
    session_id = request.session_id or str(uuid.uuid4())

    # 1. Save user message to the database
    user_message = ChatMessage(
        user_id=current_user.id,
        session_id=session_id,
        role="user",
        content=request.message,
        timestamp=datetime.now(timezone.utc),
    )
    db.add(user_message)

    # 2. Get recent chat history for context (up to last 10 messages)
    # The history is crucial for the AI to maintain context in the conversation
    recent_messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == current_user.id, ChatMessage.session_id == session_id)
        .order_by(ChatMessage.timestamp.desc())
        .limit(10)
        .all()
    )

    # Reverse the order to feed chronological history to the AI service
    context = [{"role": msg.role, "content": msg.content} for msg in reversed(recent_messages)]

    # 3. Generate AI response
    gemini_service = GeminiService()
    ai_response = await gemini_service.generate_response(request.message, context)

    # 4. Save AI response to the database
    timestamp = datetime.now(timezone.utc)
    assistant_message = ChatMessage(
        user_id=current_user.id,
        session_id=session_id,
        role="assistant",
        content=ai_response,
        timestamp=timestamp,
    )
    db.add(assistant_message)
    db.commit()  # Commit both user and assistant messages

    return ChatMessageResponse(
        response=ai_response,
        session_id=session_id,
        timestamp=timestamp,
    )


@router.get("/history/{session_id}", response_model=List[ChatHistoryResponse])
async def get_chat_history(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get chat history for a session"""
    messages = (
        db.query(ChatMessage)
        .filter(ChatMessage.user_id == current_user.id, ChatMessage.session_id == session_id)
        .order_by(ChatMessage.timestamp.asc())
        .all()
    )

    return messages


@router.get("/sessions", response_model=List[dict])
async def get_chat_sessions(
    current_user: User = Depends(get_current_user), db: Session = Depends(get_db)
):
    """Get all chat sessions for current user (limited to 20 most recent)"""
    # This query groups messages by session_id and takes the timestamp of the last message
    sessions = (
        db.query(ChatMessage.session_id, ChatMessage.timestamp)
        .filter(ChatMessage.user_id == current_user.id)
        .group_by(ChatMessage.session_id, ChatMessage.timestamp)
        .order_by(ChatMessage.timestamp.desc())
        .limit(20)
        .all()
    )

    return [{"session_id": s.session_id, "last_activity": s.timestamp} for s in sessions]
