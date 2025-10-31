from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.prompts import ChatPromptTemplate
from pydantic import BaseModel, Field
from typing import List
from app.config import settings
import logging

logger = logging.getLogger(__name__)


# Pydantic Schemas for LangChain structured output
class ActivityPlan(BaseModel):
    title: str = Field(description="Activity title")
    description: str = Field(description="Activity description")
    time: str = Field(description="Activity time in HH:MM format")
    duration: int = Field(description="Duration in minutes")
    cost: float = Field(description="Estimated cost")
    category: str = Field(description="Category: sightseeing, food, transport, etc.")
    location: str = Field(description="Location or address")


class DayPlan(BaseModel):
    title: str = Field(description="Day title")
    activities: List[ActivityPlan] = Field(description="List of activities")


class ItineraryPlan(BaseModel):
    days: List[DayPlan] = Field(description="List of days")


class ItineraryService:
    def __init__(self):
        self.llm = ChatGoogleGenerativeAI(
            model="gemini-2.0-flash", google_api_key=settings.GEMINI_API_KEY, temperature=0.7
        )

    async def generate_itinerary(
        self,
        destination: str,
        start_date: str,
        end_date: str,
        budget: float,
        interests: List[str],
        chat_context: str = "",
    ) -> dict:
        """Generate detailed itinerary based on parameters"""
        try:
            # Use the modern with_structured_output() method for better type safety
            structured_llm = self.llm.with_structured_output(ItineraryPlan)

            # Define the prompt template for the AI
            prompt = ChatPromptTemplate.from_template(
                """You are an expert travel planner. Create a detailed day-by-day itinerary.

Destination: {destination}
Dates: {start_date} to {end_date}
Budget: ${budget}
Interests: {interests}
Additional Context: {chat_context}

Create a realistic itinerary with specific activities, times, costs, and locations.
Include breakfast, lunch, dinner, and activities.
Ensure the total cost stays within budget.
Ensure the total cost of all activities stays within the budget."""
            )

            # Create the LangChain chain using LCEL (LangChain Expression Language)
            chain = prompt | structured_llm

            # Use ainvoke() instead of invoke() for async operations
            result = await chain.ainvoke(
                {
                    "destination": destination,
                    "start_date": start_date,
                    "end_date": end_date,
                    "budget": budget,
                    "interests": (", ".join(interests) if interests else "general sightseeing"),
                    "chat_context": chat_context or "No additional preferences",
                }
            )

            # Result is an ItineraryPlan Pydantic model, convert to dict
            if isinstance(result, dict):
                return result
            else:
                return result.model_dump()

        except Exception as e:
            logger.error(f"Itinerary generation error: {str(e)}")
            # Return a basic fallback itinerary
            return self._generate_fallback_itinerary(destination)

    def _generate_fallback_itinerary(self, destination: str) -> dict:
        """Generate a simple fallback itinerary"""
        return {
            "days": [
                {
                    "title": "Day 1: Arrival & Exploration",
                    "activities": [
                        {
                            "title": "Breakfast at hotel",
                            "description": "Start your day with a hearty meal",
                            "time": "08:00",
                            "duration": 60,
                            "cost": 15.0,
                            "category": "food",
                            "location": "Hotel",
                        },
                        {
                            "title": f"City tour of {destination}",
                            "description": "Explore the main attractions",
                            "time": "10:00",
                            "duration": 240,
                            "cost": 50.0,
                            "category": "sightseeing",
                            "location": f"{destination} City Center",
                        },
                    ],
                }
            ]
        }
