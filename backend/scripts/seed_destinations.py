import sys
from pathlib import Path

# Add the backend directory to Python path
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.database import SessionLocal, engine, Base
from app.models.destination import Destination
from decimal import Decimal


def seed_destinations():
    """Seed sample destinations into database"""
    Base.metadata.create_all(bind=engine)  # Ensure tables exist
    db = SessionLocal()

    # Check if destinations already exist
    existing = db.query(Destination).first()
    if existing:
        print("Destinations already seeded!")
        db.close()
        return

    destinations_data = [
        {
            "name": "Rome",
            "country": "Italy",
            "description": "The Eternal City, home to ancient ruins, Renaissance art, and mouth-watering Italian cuisine.",
            "budget": 140.0,
            "attractions": [
                "Colosseum",
                "Vatican City",
                "Trevi Fountain",
                "Roman Forum",
                "Pantheon",
            ],
            "image_url": "https://images.unsplash.com/photo-1552832230-c0197dd311b5",
        },
        {
            "name": "Barcelona",
            "country": "Spain",
            "description": "A coastal city famous for Gaudí's architecture, Mediterranean beaches, and vibrant nightlife.",
            "budget": 130.0,
            "attractions": [
                "Sagrada Familia",
                "Park Güell",
                "La Rambla",
                "Gothic Quarter",
                "Casa Batlló",
            ],
            "image_url": "https://images.unsplash.com/photo-1562883676-8c7feb83f09b",
        },
        {
            "name": "Dubai",
            "country": "UAE",
            "description": "A futuristic desert oasis with ultra-modern architecture, luxury shopping, and world-class entertainment.",
            "budget": 160.0,
            "attractions": [
                "Burj Khalifa",
                "Dubai Mall",
                "Palm Jumeirah",
                "Dubai Marina",
                "Gold Souk",
            ],
            "image_url": "https://images.unsplash.com/photo-1512453979798-5ea266f8880c",
        },
        {
            "name": "Santorini",
            "country": "Greece",
            "description": "A stunning Greek island with whitewashed buildings, blue-domed churches, and breathtaking sunsets.",
            "budget": 120.0,
            "attractions": [
                "Oia Village",
                "Red Beach",
                "Ancient Thira",
                "Amoudi Bay",
                "Akrotiri",
            ],
            "image_url": "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff",
        },
        {
            "name": "London",
            "country": "UK",
            "description": "A historic capital blending royal heritage with modern culture, world-famous museums, and diverse neighborhoods.",
            "budget": 170.0,
            "attractions": [
                "Big Ben",
                "British Museum",
                "Tower of London",
                "Buckingham Palace",
                "London Eye",
            ],
            "image_url": "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad",
        },
        {
            "name": "Bangkok",
            "country": "Thailand",
            "description": "A bustling metropolis with ornate temples, vibrant street markets, and delicious street food.",
            "budget": 70.0,
            "attractions": [
                "Grand Palace",
                "Wat Pho",
                "Chatuchak Market",
                "Wat Arun",
                "Khao San Road",
            ],
            "image_url": "https://images.unsplash.com/photo-1508009603885-50cf7c579365",
        },
    ]

    for dest_data in destinations_data:
        # Convert budget to Decimal for database storage
        dest_data["budget"] = Decimal(dest_data["budget"])
        destination = Destination(**dest_data)
        db.add(destination)

    db.commit()
    print(f"✅ Successfully seeded {len(destinations_data)} destinations!")
    db.close()


if __name__ == "__main__":
    seed_destinations()
