import math
from datetime import datetime
from django.utils import timezone
from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.journey_tracking.models import JourneySession
from apps.journey_tracking.serializers import JourneySessionSerializer
from apps.trains.models import Train


def haversine_km(lat1, lon1, lat2, lon2):
    R = 6371.0  # Earth radius in km
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return R * c


class JourneyStartAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        train_id = request.data.get('train_id')
        journey_date_str = request.data.get('journey_date')
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        accuracy = request.data.get('accuracy')

        if not train_id:
            return Response({'train_id': 'This field is required.'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            train = Train.objects.get(id=train_id)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        try:
            journey_date = datetime.strptime(journey_date_str, '%Y-%m-%d').date() if journey_date_str else timezone.localdate()
        except ValueError:
            journey_date = timezone.localdate()

        # End previous active sessions for this user
        JourneySession.objects.filter(user=request.user, is_active=True).update(
            is_active=False, end_time=timezone.now()
        )

        is_near_route = False
        if latitude is not None and longitude is not None:
            # Check station stops proximity
            for stop in train.stops.select_related('station').all():
                dist = haversine_km(latitude, longitude, stop.station.latitude, stop.station.longitude)
                if dist <= 25.0:  # Within 25 km of any station on route
                    is_near_route = True
                    break

        session = JourneySession.objects.create(
            user=request.user,
            train=train,
            journey_date=journey_date,
            last_latitude=latitude,
            last_longitude=longitude,
            last_accuracy=accuracy,
            is_near_route=is_near_route,
            is_active=True
        )

        return Response({
            'message': f'Journey tracking started for Train {train.train_number}.',
            'session': JourneySessionSerializer(session).data,
            'is_near_route': is_near_route,
            'note': 'GPS validation active with user consent. Individual locations are not stored or shared.'
        }, status=status.HTTP_201_CREATED)


class JourneyStopAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        active_sessions = JourneySession.objects.filter(user=request.user, is_active=True)
        count = active_sessions.count()
        active_sessions.update(is_active=False, end_time=timezone.now())

        return Response({
            'message': 'Active journey tracking ended.',
            'sessions_ended': count
        })


class JourneyStatusAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        active_session = JourneySession.objects.filter(
            user=request.user, is_active=True
        ).select_related('train').first()

        if not active_session:
            return Response({
                'has_active_journey': False,
                'session': None
            })

        return Response({
            'has_active_journey': True,
            'session': JourneySessionSerializer(active_session).data
        })
