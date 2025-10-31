"""add trip image fields from pexels

Revision ID: 001_add_trip_image_fields
Revises:
Create Date: 2025-10-31 00:00:00.000000

"""

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = "001_add_trip_image_fields"
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # Add image_url, photographer, and photographer_url columns to trips table
    op.add_column("trips", sa.Column("image_url", sa.Text(), nullable=True))
    op.add_column("trips", sa.Column("photographer", sa.String(), nullable=True))
    op.add_column("trips", sa.Column("photographer_url", sa.Text(), nullable=True))


def downgrade() -> None:
    # Remove the columns if rolling back
    op.drop_column("trips", "photographer_url")
    op.drop_column("trips", "photographer")
    op.drop_column("trips", "image_url")
