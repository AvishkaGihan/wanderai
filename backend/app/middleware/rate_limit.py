import logging
from fastapi import Request
from fastapi.responses import JSONResponse
from collections import defaultdict
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


# Simple in-memory rate limiter (for single instance)
# For production with multiple instances, use Redis
class RateLimiter:
    def __init__(self, requests_per_minute: int = 100):
        self.requests_per_minute = requests_per_minute
        self.requests = defaultdict(list)

    def is_allowed(self, client_id: str) -> bool:
        """Check if client is allowed to make request"""
        now = datetime.utcnow()
        minute_ago = now - timedelta(minutes=1)

        # Clean old requests
        self.requests[client_id] = [
            req_time for req_time in self.requests[client_id] if req_time > minute_ago
        ]

        # Check if under limit
        if len(self.requests[client_id]) < self.requests_per_minute:
            self.requests[client_id].append(now)
            return True

        return False


rate_limiter = RateLimiter(requests_per_minute=100)


async def rate_limit_middleware(request: Request, call_next):
    """Rate limiting middleware"""
    # Get client IP or user ID
    client_id = request.client.host if request.client else "unknown"

    # Skip rate limiting for health check
    if request.url.path == "/health":
        return await call_next(request)

    if not rate_limiter.is_allowed(client_id):
        logger.warning(f"Rate limit exceeded for client: {client_id}")
        return JSONResponse(
            status_code=429,
            content={
                "error": {
                    "code": "RATE_LIMIT_EXCEEDED",
                    "message": "Too many requests. Please try again later.",
                    "retry_after": 60,
                }
            },
        )

    response = await call_next(request)
    return response
