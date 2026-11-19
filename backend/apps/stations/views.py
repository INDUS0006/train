from rest_framework import generics, permissions
from django.db.models import Q
from apps.stations.models import Station
from apps.stations.serializers import StationSerializer


class StationListAPIView(generics.ListAPIView):
    serializer_class = StationSerializer
    permission_classes = [permissions.AllowAny]
    pagination_class = None

    def get_queryset(self):
        queryset = Station.objects.all().order_by('station_name')
        query = self.request.query_params.get('q', '').strip()
        if query:
            queryset = queryset.filter(
                Q(station_code__icontains=query) |
                Q(station_name__icontains=query) |
                Q(city__icontains=query)
            )
        return queryset
