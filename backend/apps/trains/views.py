from datetime import datetime
from django.utils import timezone
from django.db.models import Q
from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.trains.models import Train, TrainStop, Coach, SavedTrain
from apps.trains.serializers import (
    TrainListSerializer, TrainDetailSerializer, TrainStopSerializer, CoachSerializer
)


def parse_journey_date(request):
    date_str = request.query_params.get('journey_date') or request.query_params.get('date')
    if date_str:
        try:
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            pass
    return timezone.localdate()


class TrainListAPIView(generics.ListAPIView):
    permission_classes = [permissions.AllowAny]
    serializer_class = TrainListSerializer

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['journey_date'] = parse_journey_date(self.request)
        context['user'] = self.request.user
        return context

    def get_queryset(self):
        return Train.objects.filter(is_active=True).select_related(
            'source_station', 'destination_station'
        )


class TrainSearchAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        from_code = request.query_params.get('from_code', '').strip().upper()
        to_code = request.query_params.get('to_code', '').strip().upper()
        query = request.query_params.get('q', '').strip()
        journey_date = parse_journey_date(request)

        trains = Train.objects.filter(is_active=True).select_related(
            'source_station', 'destination_station'
        )

        if from_code and to_code:
            # Match trains where from_code and to_code are in stops with stop_order(from) < stop_order(to)
            # or direct source / destination match
            direct_match = trains.filter(
                (Q(source_station__station_code=from_code) | Q(stops__station__station_code=from_code)) &
                (Q(destination_station__station_code=to_code) | Q(stops__station__station_code=to_code))
            ).distinct()
            trains = direct_match
        elif from_code:
            trains = trains.filter(
                Q(source_station__station_code=from_code) | Q(stops__station__station_code=from_code)
            ).distinct()
        elif to_code:
            trains = trains.filter(
                Q(destination_station__station_code=to_code) | Q(stops__station__station_code=to_code)
            ).distinct()

        if query:
            trains = trains.filter(
                Q(train_number__icontains=query) |
                Q(train_name__icontains=query) |
                Q(source_station__station_name__icontains=query) |
                Q(destination_station__station_name__icontains=query)
            ).distinct()

        serializer = TrainListSerializer(
            trains,
            many=True,
            context={'journey_date': journey_date, 'user': request.user}
        )
        return Response({
            'count': trains.count(),
            'journey_date': journey_date.isoformat(),
            'from_code': from_code,
            'to_code': to_code,
            'results': serializer.data,
            'disclaimer': 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        })


class TrainDetailAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        try:
            train = Train.objects.select_related(
                'source_station', 'destination_station'
            ).prefetch_related('stops__station', 'coaches').get(pk=pk)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        journey_date = parse_journey_date(request)
        serializer = TrainDetailSerializer(
            train,
            context={'journey_date': journey_date, 'user': request.user}
        )
        data = serializer.data
        data['disclaimer'] = 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        return Response(data)


class TrainStopsAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        try:
            train = Train.objects.get(pk=pk)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        stops = train.stops.select_related('station').order_by('stop_order')
        serializer = TrainStopSerializer(stops, many=True)
        return Response(serializer.data)


class TrainCoachesAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        try:
            train = Train.objects.get(pk=pk)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        journey_date = parse_journey_date(request)
        coaches = train.coaches.all().order_by('position')
        serializer = CoachSerializer(
            coaches,
            many=True,
            context={'journey_date': journey_date}
        )
        return Response({
            'train_id': train.id,
            'train_number': train.train_number,
            'train_name': train.train_name,
            'journey_date': journey_date.isoformat(),
            'coaches': serializer.data,
            'disclaimer': 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        })


class TrainToggleSaveAPIView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        try:
            train = Train.objects.get(pk=pk)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        saved, created = SavedTrain.objects.get_or_create(user=request.user, train=train)
        if not created:
            saved.delete()
            return Response({'is_saved': False, 'message': f'Train {train.train_number} removed from saved.'})
        return Response({'is_saved': True, 'message': f'Train {train.train_number} saved.'})


class SavedTrainsListAPIView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = TrainListSerializer

    def get_queryset(self):
        return Train.objects.filter(saved_by_users__user=self.request.user)

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['journey_date'] = timezone.localdate()
        context['user'] = self.request.user
        return context
