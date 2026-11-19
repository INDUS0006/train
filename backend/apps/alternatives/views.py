from rest_framework import permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response
from apps.alternatives.models import TravelAlternative
from apps.alternatives.serializers import TravelAlternativeSerializer
from apps.trains.models import Train


class TrainAlternativesAPIView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, pk):
        try:
            train = Train.objects.get(pk=pk)
        except Train.DoesNotExist:
            return Response({'detail': 'Train not found.'}, status=status.HTTP_404_NOT_FOUND)

        alternatives = train.alternatives.all().order_by('departure_time')
        serializer = TravelAlternativeSerializer(alternatives, many=True)
        return Response({
            'train_id': train.id,
            'train_number': train.train_number,
            'train_name': train.train_name,
            'count': alternatives.count(),
            'alternatives': serializer.data,
            'disclaimer': 'DEMO OPTIONS – NOT LIVE BOOKING AVAILABILITY'
        })
