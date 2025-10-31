from fastapi import status
from typing import Optional


class AppException(Exception):
    """Base application exception for structured errors"""

    def __init__(
        self, code: str, message: str, status_code: int = 400, details: Optional[dict] = None
    ):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class AuthenticationError(AppException):
    """Authentication related errors (401)"""

    def __init__(self, message: str = "Authentication failed"):
        super().__init__(
            code="AUTH_ERROR", message=message, status_code=status.HTTP_401_UNAUTHORIZED
        )


class NotFoundError(AppException):
    """Resource not found errors (404)"""

    def __init__(self, resource: str = "Resource"):
        super().__init__(
            code="NOT_FOUND", message=f"{resource} not found", status_code=status.HTTP_404_NOT_FOUND
        )


class ValidationError(AppException):
    """Validation errors (422)"""

    def __init__(self, message: str, details: Optional[dict] = None):
        super().__init__(
            code="VALIDATION_ERROR",
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=details,
        )
