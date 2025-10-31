from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List
from uuid import UUID

from app.database import get_db
from app.schemas.expense import ExpenseCreate, ExpenseResponse
from app.models.expense import Expense
from app.models.trip import Trip
from app.models.user import User
from app.dependencies.auth import get_current_user

router = APIRouter()


# --- Expense Endpoints ---


@router.get("/{trip_id}/expenses", response_model=List[ExpenseResponse])
async def get_trip_expenses(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get all expenses for a trip"""
    # Verify trip ownership for security
    trip = (
        db.query(Trip)
        .filter(Trip.id == trip_id, Trip.user_id == current_user.id)
        .first()
    )

    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found"
        )

    expenses = (
        db.query(Expense)
        .filter(Expense.trip_id == trip_id)
        .order_by(Expense.date.desc())
        .all()
    )

    return expenses


@router.post(
    "/{trip_id}/expenses",
    response_model=ExpenseResponse,
    status_code=status.HTTP_201_CREATED,
)
async def add_expense(
    trip_id: UUID,
    expense: ExpenseCreate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Add an expense to a trip"""
    # Verify trip ownership
    trip = (
        db.query(Trip)
        .filter(Trip.id == trip_id, Trip.user_id == current_user.id)
        .first()
    )

    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found"
        )

    db_expense = Expense(
        trip_id=trip_id,
        category=expense.category,
        amount=expense.amount,
        currency=expense.currency,
        date=expense.date,
        description=expense.description,
    )

    db.add(db_expense)
    db.commit()
    db.refresh(db_expense)

    return db_expense


@router.delete(
    "/{trip_id}/expenses/{expense_id}", status_code=status.HTTP_204_NO_CONTENT
)
async def delete_expense(
    trip_id: UUID,
    expense_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Delete an expense"""
    # Verify trip ownership
    trip = (
        db.query(Trip)
        .filter(Trip.id == trip_id, Trip.user_id == current_user.id)
        .first()
    )

    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found"
        )

    # Find the specific expense under that trip
    expense = (
        db.query(Expense)
        .filter(Expense.id == expense_id, Expense.trip_id == trip_id)
        .first()
    )

    if not expense:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Expense not found"
        )

    db.delete(expense)
    db.commit()

    return None


@router.get("/{trip_id}/expenses/summary", response_model=dict)
async def get_expense_summary(
    trip_id: UUID,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Get expense summary for a trip (total spent, category breakdown)"""
    # Verify trip ownership
    trip = (
        db.query(Trip)
        .filter(Trip.id == trip_id, Trip.user_id == current_user.id)
        .first()
    )

    if not trip:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Trip not found"
        )

    expenses = db.query(Expense).filter(Expense.trip_id == trip_id).all()

    # Calculate totals by category
    category_totals = {}
    total_spent = 0.0

    for expense in expenses:
        # Convert Decimal to float for calculations
        amount = float(expense.amount)  # type: ignore
        total_spent += amount

        if expense.category in category_totals:  # type: ignore
            category_totals[expense.category] += amount  # type: ignore
        else:
            category_totals[expense.category] = amount  # type: ignore

    budget = float(trip.budget) if trip.budget else 0.0  # type: ignore
    remaining = budget - total_spent

    return {
        "trip_id": str(trip.id),
        "budget": budget,
        "total_spent": total_spent,
        "remaining": remaining,
        "percentage_used": (total_spent / budget * 100) if budget > 0 else 0,
        "by_category": category_totals,
    }
