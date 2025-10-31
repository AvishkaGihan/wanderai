from google import genai
from google.genai import types
from app.config import settings
import logging
from typing import Optional

logger = logging.getLogger(__name__)


class GeminiService:
    def __init__(self):
        # Initialize the client with API key
        self.client = genai.Client(api_key=settings.GEMINI_API_KEY)

    async def generate_response(self, prompt: str, context: Optional[list] = None) -> str:
        """Generate AI response for travel queries"""
        try:
            # Build conversation contents
            contents = []
            if context:
                for msg in context:
                    # Map 'assistant' role to 'model' for Gemini API
                    gemini_role = "model" if msg["role"] == "assistant" else msg["role"]
                    contents.append(
                        types.Content(
                            role=gemini_role,
                            parts=[types.Part(text=msg["content"])],
                        )
                    )
            # Add the current prompt
            contents.append(
                types.Content(
                    role="user",
                    parts=[types.Part(text=prompt)],
                )
            )

            # Generate response
            response = await self.client.aio.models.generate_content(
                model=settings.GEMINI_MODEL, contents=contents
            )
            return (
                response.text
                or "I apologize, but I'm having trouble processing your request right now. Please try again."
            )

        except Exception as e:
            logger.error(f"Gemini API error: {str(e)}")
            return "I apologize, but I'm having trouble processing your request right now. Please try again."
