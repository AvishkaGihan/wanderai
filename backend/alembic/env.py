from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
import sys
from os.path import dirname, abspath

# Add parent directory to path to enable import of app files
sys.path.insert(0, dirname(dirname(abspath(__file__))))

# Import Base from your database configuration
from app.database import Base

# These imports are required for Alembic to detect table changes, even though they're not directly used
from app.models.user import User  # noqa: F401
from app.models.trip import Trip, Day, Activity  # noqa: F401
from app.models.destination import Destination  # noqa: F401
from app.models.expense import Expense  # noqa: F401
from app.models.chat_message import ChatMessage  # noqa: F401

# this is the Alembic Config object
config = context.config

# Interpret the config file for Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set the target_metadata to Base.metadata from your app
target_metadata = Base.metadata


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode."""
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode."""
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=target_metadata)

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
