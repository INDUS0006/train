from rest_framework import serializers
from apps.journey_tracking.models import JourneySession
from apps.trains.serializers import TrainListSerializer


class JourneySessionSerializer(serializers.ModelSerializer):
    train = TrainListSerializer(read_only=True)

    class Meta:
        model = JourneySession
        fields = [
            'id', 'train', 'journey_date', 'start_time', 'end_time',
            'is_active', 'last_latitude', 'last_longitude',
            'last_accuracy', 'is_near_route', 'created_at'
        ]
