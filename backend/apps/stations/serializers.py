from rest_framework import serializers
from apps.stations.models import Station


class StationSerializer(serializers.ModelSerializer):
    display_name = serializers.SerializerMethodField()

    class Meta:
        model = Station
        fields = [
            'id', 'station_code', 'station_name', 'city', 'state',
            'latitude', 'longitude', 'display_name'
        ]

    def get_display_name(self, obj):
        return f"{obj.station_name} ({obj.station_code})"
