from pydantic_settings import BaseSettings
from typing import List
import os
from dotenv import load_dotenv

# Load environment variables from the root .env file
load_dotenv()


class Settings(BaseSettings):
    """Application settings"""

    # Environment
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = ENVIRONMENT == "development"

    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "")

    # Redis
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379")

    # Security
    SECRET_KEY: str = os.getenv("SECRET_KEY", "")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # Firebase
    FIREBASE_PROJECT_ID: str = os.getenv("FIREBASE_PROJECT_ID", "")
    FIREBASE_WEB_API_KEY: str = os.getenv("FIREBASE_WEB_API_KEY", "")

    # Google AI / Gemini
    GEMINI_API_KEY: str = os.getenv("GEMINI_API_KEY", "")
    GEMINI_MODEL: str = "gemini-2.5-flash"

    # Pexels API Configuration
    PEXELS_API_KEY: str = os.getenv("PEXELS_API_KEY", "")
    PEXELS_BASE_URL: str = "https://api.pexels.com/v1"
    PEXELS_PHOTOS_PER_PAGE: int = 1
    PEXELS_CACHE_TTL: int = 86400  # 24 hours

    # CORS - Environment specific
    CORS_ORIGINS: List[str] = (
        [
            "http://localhost:3000",
            "http://localhost:8080",
            "http://localhost:8000",
        ]
        if ENVIRONMENT == "development"
        else os.getenv("CORS_ORIGINS", "").split(",")
    )

    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = 100

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        # Validate required fields in production
        if self.ENVIRONMENT == "production":
            required_fields = [
                "DATABASE_URL",
                "SECRET_KEY",
                "FIREBASE_PROJECT_ID",
                "GEMINI_API_KEY",
            ]
            missing = [f for f in required_fields if not getattr(self, f)]
            if missing:
                raise ValueError(f"Missing required environment variables: {', '.join(missing)}")

    class Config:
        env_file = ".env"


settings = Settings()
