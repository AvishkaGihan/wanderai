from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID
from datetime import timedelta
import logging

from app.database import get_db
from app.schemas.trip import (
    TripCreate,
    TripUpdate,
    TripResponse,
    ItineraryGenerateRequest,
    ActivityCreate,
    ActivityUpdate,
    ActivityResponse,
)
from app.models.trip import Trip, Day, Activity
from app.models.chat_message import ChatMessage
from app.models.user import User
from app.dependencies.auth import get_current_user
from app.services.itinerary_service import ItineraryService
from app.services.pexels_service import PexelsService

router = APIRouter()
logger = logging.getLogger(__name__)


@router.get("/", response_model=List[TripResponse])
async def get_trips(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get all trips for current user"""
    trips = db.query(Trip).filter(Trip.user_id == current_user.id).all()
    return trips


@router.post("/", response_model=TripResponse, status_code=status.HTTP_201_CREATED)
async def create_trip(
    trip: TripCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a new trip with destination image from Pexels"""
    db_trip = Trip(
        user_id=current_user.id,
        title=trip.title,
        destination=trip.destination,
        start_date=trip.start_date,
        end_date=trip.end_date,
        budget=trip.budget,
        status=trip.status,
    )

    # Fetch image from Pexels if destination is provided
    if trip.destination:
        try:
            pexels_service = PexelsService()
            image_data = await pexels_service.get_destination_image(trip.destination)

            if image_data:
                db_trip.image_url = image_data["image_url"]  # type: ignore
                db_trip.photographer = image_data["photographer"]  # type: ignore
                db_trip.photographer_url = image_data["photographer_url"]  # type: ignore
                logger.info(f"Fetched image for destination: {trip.destination}")
            else:
                logger.warning(f"No image found for destination: {trip.destination}")
        except Exception as e:
            # Don't fail trip creation if image fetch fails
            logger.error(f"Error fetching Pexels image: {e}")

    db.add(db_trip)
    db.commit()
    db.refresh(db_trip)
    return db_trip


@router.get("/{trip_id}", response_model=TripResponse)
async def get_trip(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get specific trip details"""
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()

    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    return trip


@router.put("/{trip_id}", response_model=TripResponse)
async def update_trip(
    trip_id: UUID,
    trip_update: TripUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update a trip"""
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()

    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    # Update fields only if they are provided in the request
    update_data = trip_update.model_dump(exclude_unset=True)

    # If destination changed, fetch new image
    if "destination" in update_data and update_data["destination"] != trip.destination:
        try:
            pexels_service = PexelsService()
            image_data = await pexels_service.get_destination_image(update_data["destination"])

            if image_data:
                update_data["image_url"] = image_data["image_url"]
                update_data["photographer"] = image_data["photographer"]
                update_data["photographer_url"] = image_data["photographer_url"]
                logger.info(f"Updated image for destination: {update_data['destination']}")
        except Exception as e:
            logger.error(f"Error fetching Pexels image on update: {e}")

    for field, value in update_data.items():
        setattr(trip, field, value)

    db.commit()
    db.refresh(trip)
    return trip


@router.delete("/{trip_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_trip(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete a trip"""
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()

    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    db.delete(trip)
    db.commit()
    return None


@router.get("/{trip_id}/itinerary", response_model=dict)
async def get_trip_itinerary(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get trip itinerary with days and activities"""
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()

    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    # Get all days and activities related to the trip
    days = db.query(Day).filter(Day.trip_id == trip_id).order_by(Day.order).all()

    # Manually serialize the complex structure for the API response
    return {
        "trip_id": str(trip.id),
        "days": [
            {
                "id": str(day.id),
                "date": day.date.isoformat(),
                "title": day.title,
                "order": day.order,
                "activities": [
                    {
                        "id": str(activity.id),
                        "title": activity.title,
                        "description": activity.description,
                        "time": str(activity.time) if activity.time else None,
                        "duration": activity.duration,
                        "cost": float(activity.cost) if activity.cost else None,
                        "category": activity.category,
                        "location": activity.location,
                    }
                    for activity in day.activities
                ],
            }
            for day in days
        ],
    }


@router.post("/{trip_id}/itinerary", status_code=status.HTTP_201_CREATED)
async def generate_itinerary(
    trip_id: UUID,
    request: ItineraryGenerateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Generate itinerary from chat context, save to database, and return status"""
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()

    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    # 1. Get chat context for detailed AI instructions
    chat_messages = (
        db.query(ChatMessage)
        .filter(
            ChatMessage.user_id == current_user.id,
            ChatMessage.session_id == request.chat_session_id,
        )
        .order_by(ChatMessage.timestamp.asc())
        .all()
    )

    # Concatenate all messages into a single context string
    chat_context = " ".join([msg.content for msg in chat_messages])  # type: ignore

    # 2. Extract user preferences from profile
    interests = current_user.preferences.get("interests", [])  # type: ignore

    # 3. Generate structured itinerary using the service
    itinerary_service = ItineraryService()
    itinerary_data = await itinerary_service.generate_itinerary(
        destination=trip.destination or "Unknown",  # type: ignore
        start_date=trip.start_date.isoformat() if trip.start_date else None,  # type: ignore
        end_date=trip.end_date.isoformat() if trip.end_date else None,  # type: ignore
        budget=float(trip.budget) if trip.budget else 1000.0,  # type: ignore
        interests=interests,
        chat_context=chat_context,
    )

    # 4. Save generated itinerary to database
    current_date = trip.start_date
    for order, day_data in enumerate(itinerary_data["days"], start=1):
        # Create Day object
        day = Day(trip_id=trip.id, date=current_date, title=day_data["title"], order=order)
        db.add(day)
        db.flush()  # Ensures the Day object gets its UUID for the foreign key

        # Add activities for the day
        for activity_data in day_data["activities"]:
            activity = Activity(
                day_id=day.id,
                title=activity_data["title"],
                description=activity_data["description"],
                time=activity_data.get("time"),
                duration=activity_data.get("duration"),
                cost=activity_data.get("cost"),
                category=activity_data.get("category"),
                location=activity_data.get("location"),
            )
            db.add(activity)

        # Move to next day (important for multi-day trips)
        if current_date:  # type: ignore
            current_date += timedelta(days=1)

    db.commit()

    return {"message": "Itinerary generated successfully", "trip_id": str(trip.id)}


@router.get("/{trip_id}/activities", response_model=List[ActivityResponse])
async def get_trip_activities(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all activities for a trip"""
    # Verify trip ownership
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    activities = db.query(Activity).join(Day).filter(Day.trip_id == trip_id).all()
    return activities


@router.post(
    "/{trip_id}/days/{day_id}/activities",
    response_model=ActivityResponse,
    status_code=status.HTTP_201_CREATED,
)
async def create_activity(
    trip_id: UUID,
    day_id: UUID,
    activity: ActivityCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Create a new activity for a specific day"""
    # Verify trip ownership
    trip = db.query(Trip).filter(Trip.id == trip_id, Trip.user_id == current_user.id).first()
    if not trip:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found")

    # Verify day belongs to trip
    day = db.query(Day).filter(Day.id == day_id, Day.trip_id == trip_id).first()
    if not day:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Day not found")

    db_activity = Activity(
        day_id=day_id,
        title=activity.title,
        description=activity.description,
        time=activity.time,
        duration=activity.duration,
        cost=activity.cost,
        category=activity.category,
        location=activity.location,
    )
    db.add(db_activity)
    db.commit()
    db.refresh(db_activity)
    return db_activity


@router.put("/{trip_id}/activities/{activity_id}", response_model=ActivityResponse)
async def update_activity(
    trip_id: UUID,
    activity_id: UUID,
    activity_update: ActivityUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update an activity"""
    # Verify trip ownership and get activity
    activity = (
        db.query(Activity)
        .join(Day)
        .join(Trip)
        .filter(
            Activity.id == activity_id,
            Trip.id == trip_id,
            Trip.user_id == current_user.id,
        )
        .first()
    )
    if not activity:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Activity not found")

    # Update fields if provided
    update_data = activity_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(activity, field, value)

    db.commit()
    db.refresh(activity)
    return activity


@router.delete("/{trip_id}/activities/{activity_id}")
async def delete_activity(
    trip_id: UUID,
    activity_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete an activity"""
    # Verify trip ownership and get activity
    activity = (
        db.query(Activity)
        .join(Day)
        .join(Trip)
        .filter(
            Activity.id == activity_id,
            Trip.id == trip_id,
            Trip.user_id == current_user.id,
        )
        .first()
    )
    if not activity:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Activity not found")

    db.delete(activity)
    db.commit()
    return {"message": "Activity deleted successfully"}
