import sys
from pathlib import Path

# Add the backend directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.database import engine, Base

from app.models.user import User  # noqa: F401
from app.models.trip import Trip, Day, Activity  # noqa: F401
from app.models.destination import Destination  # noqa: F401
from app.models.expense import Expense  # noqa: F401
from app.models.chat_message import ChatMessage  # noqa: F401

import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def init_database():
    """Create all database tables defined in the models"""
    logger.info("Creating database tables...")
    # This is similar to the code in app.main's lifespan hook
    Base.metadata.create_all(bind=engine)
    logger.info("✅ Database tables created successfully!")


if __name__ == "__main__":
    # Note: Running this script assumes you are in the apps/backend directory
    init_database()
