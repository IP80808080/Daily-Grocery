from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken, AuthenticationFailed

def verify_access_token(request):
    """
    Verify the access token from the request headers and return the user associated with it.
    """
    authentication = JWTAuthentication()
    try:
        user, _ = authentication.authenticate(request)
        return user
    except InvalidToken:
        raise AuthenticationFailed('Invalid access token')
    except AuthenticationFailed:
        raise AuthenticationFailed('Failed to authenticate with access token')
