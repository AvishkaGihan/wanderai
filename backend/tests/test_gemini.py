import pytest
from google import genai
from google.genai import types
from app.config import settings
import asyncio


@pytest.mark.asyncio
async def test_gemini():
    """Test Gemini API connection by asking a simple question"""
    # Initialize the client with API key
    client = genai.Client(api_key=settings.GEMINI_API_KEY)

    print("Testing Gemini API...")
    print("-" * 50)

    prompt = "Tell me about Tokyo in 2 sentences."

    try:
        # Build content for the new API
        contents = [
            types.Content(
                role="user",
                parts=[types.Part(text=prompt)],
            )
        ]

        # Use the new API to generate content
        response = await client.aio.models.generate_content(
            model=settings.GEMINI_MODEL, contents=contents
        )

        print(f"Prompt: {prompt}")
        response_text = response.text or "No response text received"
        print(f"Response: {response_text.strip()}")
        print("-" * 50)
        print("✅ Gemini API is working!")

    except Exception as e:
        print(f"❌ Gemini API Test Failed: {e}")
        print("Please check your GEMINI_API_KEY in the .env file.")


if __name__ == "__main__":
    # Since the service uses asyncio, we use asyncio.run to execute the async function
    asyncio.run(test_gemini())
