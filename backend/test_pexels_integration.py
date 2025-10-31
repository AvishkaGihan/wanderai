"""
Test script for Pexels API integration
"""

import asyncio
from app.services.pexels_service import PexelsService


async def test_pexels():
    service = PexelsService()

    print("=" * 60)
    print("Testing Pexels API Integration")
    print("=" * 60)

    # Test 1: Search for photos
    print("\n✓ Test 1: Searching for Paris photos...")
    result = await service.search_photos("Paris", orientation="landscape")
    if result:
        print(f"✓ Found {len(result.get('photos', []))} photos")
        if result.get("photos"):
            photo = result["photos"][0]
            print(f"  - Photo URL: {photo.get('url', 'N/A')}")
            print(f"  - Photographer: {photo.get('photographer', 'N/A')}")
    else:
        print("✗ Search failed")

    # Test 2: Get destination image
    print("\n✓ Test 2: Getting destination image for Tokyo...")
    image_data = await service.get_destination_image("Tokyo, Japan")
    if image_data:
        print("✓ Got image successfully!")
        print(f"  - Image URL: {image_data['image_url']}")
        print(f"  - Photographer: {image_data['photographer']}")
        print(f"  - Photographer URL: {image_data['photographer_url']}")
    else:
        print("✗ Failed to get image")

    # Test 3: Test with generic destination
    print("\n✓ Test 3: Testing with 'Barcelona' destination...")
    image_data = await service.get_destination_image("Barcelona")
    if image_data:
        print("✓ Got image successfully!")
        print(f"  - Image URL: {image_data['image_url']}")
        print(f"  - Photographer: {image_data['photographer']}")
    else:
        print("✗ Failed to get image")

    # Test 4: Check rate limit
    print("\n✓ Test 4: Checking rate limit status...")
    rate_limit = await service.get_rate_limit_status()
    if rate_limit:
        print("✓ Rate limit info:")
        print(f"  - Limit: {rate_limit['limit']} requests/month")
        print(f"  - Remaining: {rate_limit['remaining']}")
        print(f"  - Reset: {rate_limit['reset']}")
    else:
        print("✗ Could not fetch rate limit")

    print("\n" + "=" * 60)
    print("✓ All tests completed!")
    print("=" * 60)


if __name__ == "__main__":
    asyncio.run(test_pexels())
