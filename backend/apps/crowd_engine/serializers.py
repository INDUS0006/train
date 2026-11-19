from rest_framework import serializers
from apps.crowd_engine.models import CrowdEstimate


class CrowdEstimateSerializer(serializers.ModelSerializer):
    coach_number = serializers.CharField(source='coach.coach_number', read_only=True, allow_null=True)
    coach_label = serializers.CharField(source='coach.coach_label', read_only=True, allow_null=True)

    class Meta:
        model = CrowdEstimate
        fields = [
            'id', 'train', 'journey_date', 'coach', 'coach_number',
            'coach_label', 'crowd_level', 'valid_report_count',
            'confidence_level', 'confidence_score', 'last_updated',
            'calculation_method', 'distribution', 'explanation'
        ]
