from fastapi import APIRouter, Depends, Query, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database import get_db
from app.models.destination import Destination
from app.schemas.destination import DestinationResponse

router = APIRouter()


@router.get("/", response_model=List[DestinationResponse])
async def search_destinations(
    query: Optional[str] = Query(
        None, description="Search query for name, country, or description"
    ),
    limit: int = Query(20, le=100),
    db: Session = Depends(get_db),
):
    """Search and filter destinations"""
    destinations_query = db.query(Destination)

    # Apply case-insensitive search filter if a query is provided
    if query:
        # Use SQL LIKE operator for flexible text search
        search_filter = f"%{query}%"
        destinations_query = destinations_query.filter(
            (Destination.name.ilike(search_filter))
            | (Destination.country.ilike(search_filter))
            | (Destination.description.ilike(search_filter))
        )

    destinations = destinations_query.limit(limit).all()
    return destinations


@router.get("/{destination_id}", response_model=DestinationResponse)
async def get_destination(destination_id: str, db: Session = Depends(get_db)):
    """Get specific destination details by ID"""
    destination = db.query(Destination).filter(Destination.id == destination_id).first()

    if not destination:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Destination not found"
        )

    return destination
