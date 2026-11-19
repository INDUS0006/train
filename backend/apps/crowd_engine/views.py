from datetime import datetime
from django.utils import timezone
from rest_framework import status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.crowd_engine.models import CrowdEstimate, EstimateCrowdLevel, ConfidenceLevel
from apps.crowd_engine.serializers import CrowdEstimateSerializer
from apps.crowd_engine.services import CrowdEngineService
from apps.trains.models import Train, Coach


def get_target_date(request):
    date_str = request.query_params.get('journey_date') or request.query_params.get('date')
    if date_str:
        try:
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        except ValueError:
            pass
    return timezone.localdate()


class TrainCrowdEstimateAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, train_id):
        try:
            train = Train.objects.get(id=train_id)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        journey_date = get_target_date(request)

        # Get or calculate estimate
        estimate = CrowdEstimate.objects.filter(
            train=train, journey_date=journey_date, coach=None
        ).first()

        if not estimate:
            estimate = CrowdEngineService.calculate_estimate(train, journey_date, coach=None)

        serializer = CrowdEstimateSerializer(estimate)
        return Response({
            'train_id': train.id,
            'train_number': train.train_number,
            'train_name': train.train_name,
            'journey_date': journey_date.isoformat(),
            'estimate': serializer.data,
            'disclaimer': 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        })


class CoachCrowdEstimateAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, train_id, coach_id):
        try:
            train = Train.objects.get(id=train_id)
            coach = Coach.objects.get(id=coach_id, train=train)
        except (Train.DoesNotExist, Coach.DoesNotExist):
            return Response({'detail': 'Train or Coach not found.'}, status=status.HTTP_404_NOT_FOUND)

        journey_date = get_target_date(request)

        estimate = CrowdEstimate.objects.filter(
            train=train, journey_date=journey_date, coach=coach
        ).first()

        if not estimate:
            estimate = CrowdEngineService.calculate_estimate(train, journey_date, coach=coach)

        serializer = CrowdEstimateSerializer(estimate)
        return Response({
            'train_id': train.id,
            'train_number': train.train_number,
            'coach_id': coach.id,
            'coach_number': coach.coach_number,
            'coach_label': coach.coach_label,
            'journey_date': journey_date.isoformat(),
            'estimate': serializer.data,
            'disclaimer': 'DEMO DATA – NOT LIVE RAILWAY INFORMATION'
        })
