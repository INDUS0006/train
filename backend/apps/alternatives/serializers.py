from rest_framework import serializers
from apps.alternatives.models import TravelAlternative


class TravelAlternativeSerializer(serializers.ModelSerializer):
    alternative_type_display = serializers.CharField(source='get_alternative_type_display', read_only=True)

    class Meta:
        model = TravelAlternative
        fields = [
            'id', 'train', 'alternative_type', 'alternative_type_display',
            'title', 'operator', 'departure_time', 'arrival_time',
            'duration_text', 'crowd_level', 'fare_estimate',
            'source_note', 'is_demo'
        ]
