import uuid
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from apps.accounts.models import User
from apps.accounts.serializers import UserSerializer, RegisterSerializer, LoginSerializer


def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class RegisterView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                'message': 'User registered successfully.',
                'user': UserSerializer(user).data,
                'tokens': tokens,
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            tokens = get_tokens_for_user(user)
            return Response({
                'message': 'Login successful.',
                'user': UserSerializer(user).data,
                'tokens': tokens,
            })
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GuestLoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        # Create a clean guest demo user
        guest_uuid = str(uuid.uuid4())[:8]
        username = f"guest_{guest_uuid}"
        email = f"guest_{guest_uuid}@trainbuddy.demo"
        user = User.objects.create_user(
            username=username,
            email=email,
            password=str(uuid.uuid4()),
            first_name='Demo',
            last_name='Passenger',
            is_guest=True
        )
        tokens = get_tokens_for_user(user)
        return Response({
            'message': 'Guest demo session initialized.',
            'user': UserSerializer(user).data,
            'tokens': tokens,
            'is_demo_mode': True,
        }, status=status.HTTP_201_CREATED)


class ProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def patch(self, request):
        serializer = UserSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
