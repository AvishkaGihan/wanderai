"""
Pexels API Service
Handles interaction with Pexels API for fetching destination images
"""

import httpx
import logging
from typing import Optional, Dict, Any
from app.config import settings

logger = logging.getLogger(__name__)


class PexelsService:
    """Service for interacting with Pexels API"""

    def __init__(self):
        self.api_key = settings.PEXELS_API_KEY
        self.base_url = settings.PEXELS_BASE_URL
        self.per_page = settings.PEXELS_PHOTOS_PER_PAGE
        self.headers = {"Authorization": self.api_key}

    async def search_photos(
        self, query: str, orientation: Optional[str] = "landscape", per_page: Optional[int] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Search for photos on Pexels

        Args:
            query: Search term (e.g., "Paris", "Tokyo", "Beach")
            orientation: Photo orientation - "landscape", "portrait", or "square"
            per_page: Number of results per page (default: 1)

        Returns:
            Dictionary with photo data or None if failed
        """
        if not query:
            logger.warning("Empty query provided to Pexels search")
            return None

        per_page = per_page or self.per_page

        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/search",
                    headers=self.headers,
                    params={"query": query, "per_page": per_page, "orientation": orientation},
                    timeout=10.0,  # 10 second timeout
                )

                # Check for rate limiting
                if response.status_code == 429:
                    logger.error("Pexels API rate limit exceeded")
                    return None

                response.raise_for_status()
                data = response.json()

                # Log rate limit info
                if "X-Ratelimit-Remaining" in response.headers:
                    remaining = response.headers.get("X-Ratelimit-Remaining")
                    logger.info(f"Pexels API requests remaining: {remaining}")

                return data

        except httpx.TimeoutException:
            logger.error(f"Timeout while searching Pexels for '{query}'")
            return None
        except httpx.HTTPError as e:
            logger.error(f"HTTP error while searching Pexels: {e}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error searching Pexels: {e}")
            return None

    async def get_destination_image(
        self, destination: str, fallback_query: str = "travel destination"
    ) -> Optional[Dict[str, str]]:
        """
        Get a single image for a destination

        Args:
            destination: Destination name (e.g., "Paris, France")
            fallback_query: Query to use if destination search fails

        Returns:
            Dictionary with image_url, photographer, and photographer_url
            or None if no image found
        """
        # Try with destination first
        data = await self.search_photos(destination, orientation="landscape")

        # If no results, try with fallback query
        if not data or not data.get("photos"):
            logger.info(f"No photos found for '{destination}', trying fallback query")
            data = await self.search_photos(fallback_query, orientation="landscape")

        # Extract first photo
        if data and data.get("photos") and len(data["photos"]) > 0:
            photo = data["photos"][0]

            return {
                "image_url": photo["src"]["large"],  # Use 'large' size (650px height)
                "photographer": photo["photographer"],
                "photographer_url": photo["photographer_url"],
                "pexels_url": photo["url"],  # Link to photo on Pexels
                "avg_color": photo.get("avg_color"),  # Useful for placeholder
            }

        logger.warning(f"No images found for destination '{destination}'")
        return None

    async def get_curated_photos(self, per_page: int = 15) -> Optional[Dict[str, Any]]:
        """
        Get curated photos from Pexels

        Args:
            per_page: Number of results per page

        Returns:
            Dictionary with curated photos data
        """
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/curated",
                    headers=self.headers,
                    params={"per_page": per_page},
                    timeout=10.0,
                )

                response.raise_for_status()
                return response.json()

        except Exception as e:
            logger.error(f"Error fetching curated photos: {e}")
            return None

    async def get_rate_limit_status(self) -> Optional[Dict[str, int]]:
        """Get current rate limit status"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"{self.base_url}/curated", headers=self.headers, params={"per_page": 1}
                )

                return {
                    "limit": int(response.headers.get("X-Ratelimit-Limit", 0)),
                    "remaining": int(response.headers.get("X-Ratelimit-Remaining", 0)),
                    "reset": int(response.headers.get("X-Ratelimit-Reset", 0)),
                }
        except Exception as e:
            logger.error(f"Error checking rate limit: {e}")
            return None
