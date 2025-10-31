from fastapi import Request
from fastapi.responses import JSONResponse
from datetime import datetime, timezone
import logging
import traceback

logger = logging.getLogger(__name__)


async def error_handler_middleware(request: Request, call_next):
    """Global error handling middleware"""
    try:
        response = await call_next(request)
        return response
    except Exception as exc:
        # Log the detailed error, including the traceback for debugging
        logger.error(
            f"Unhandled exception: {str(exc)}",
            extra={
                "path": str(request.url),
                "method": request.method,
                "traceback": traceback.format_exc(),
            },
        )

        # Return a standardized 500 JSON error response
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "An unexpected error occurred",
                    "timestamp": datetime.now(timezone.utc).isoformat(),
                    "request_id": getattr(
                        request.state, "request_id", "unknown"
                    ),  # Use the ID created in request_id.py
                }
            },
        )
