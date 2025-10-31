from fastapi import Request
import uuid


async def request_id_middleware(request: Request, call_next):
    """Add unique request ID to each request and state"""
    request_id = str(uuid.uuid4())
    # Save the ID to the request state so other parts of the app can access it
    request.state.request_id = request_id

    response = await call_next(request)
    response.headers["X-Request-ID"] = request_id

    return response
