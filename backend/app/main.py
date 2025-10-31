from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import uvicorn
import logging
import os
from contextlib import asynccontextmanager
from app.database import engine, Base

from app.routes import auth, chat, trips, destinations, expenses

from app.middleware.error_handler import error_handler_middleware
from app.middleware.request_id import request_id_middleware
from app.middleware.rate_limit import rate_limit_middleware
from app.config import settings

# Initialize Sentry for error tracking
try:
    import sentry_sdk
    from sentry_sdk.integrations.fastapi import FastApiIntegration
    from sentry_sdk.integrations.sqlalchemy import SqlalchemyIntegration

    sentry_dsn = os.getenv("SENTRY_DSN")
    if sentry_dsn:
        sentry_sdk.init(
            dsn=sentry_dsn,
            integrations=[
                FastApiIntegration(),
                SqlalchemyIntegration(),
            ],
            environment=settings.ENVIRONMENT,
            traces_sample_rate=0.1,
            profiles_sample_rate=0.1,
        )
        logger_sentry = logging.getLogger(__name__)
        logger_sentry.info(f"Sentry initialized for {settings.ENVIRONMENT} environment")
except Exception as e:
    print(f"Sentry initialization failed (non-critical): {e}")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup and shutdown events"""
    # Startup: Ensure database tables are created
    logger.info("Starting WanderAI API...")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    # This will create all tables defined in your models if they don't exist
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created/verified")
    yield
    # Shutdown
    logger.info("Shutting down WanderAI API...")


# Initialize the FastAPI app with the lifespan hook
app = FastAPI(
    title="WanderAI API",
    version="1.0.0",
    description="AI-powered travel planning API with Gemini integration",
    lifespan=lifespan,
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

logger.info(f"CORS Origins configured: {settings.CORS_ORIGINS}")


# Custom middleware (order matters: request ID first, then error handling)
app.middleware("http")(request_id_middleware)
app.middleware("http")(rate_limit_middleware)
app.middleware("http")(error_handler_middleware)

# Include routers (API Endpoints)
# We use /v1 prefix for versioning
app.include_router(auth.router, prefix="/v1/auth", tags=["Authentication"])
app.include_router(chat.router, prefix="/v1/chat", tags=["Chat"])
app.include_router(trips.router, prefix="/v1/trips", tags=["Trips"])
app.include_router(destinations.router, prefix="/v1/destinations", tags=["Destinations"])
app.include_router(expenses.router, prefix="/v1/expenses", tags=["Expenses"])


@app.get("/")
async def root():
    """Root endpoint"""
    logger.debug("Root endpoint accessed")
    return {
        "message": "WanderAI API is running!",
        "version": "1.0.0",
        "docs": "/docs",
        "environment": settings.ENVIRONMENT,
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "wanderai-api",
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0",
    }


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=settings.DEBUG,
        log_level="info",
    )
