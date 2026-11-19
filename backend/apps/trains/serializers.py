from rest_framework import serializers
from django.utils import timezone
from apps.stations.serializers import StationSerializer
from apps.trains.models import Train, TrainStop, Coach, SavedTrain
from apps.crowd_engine.models import CrowdEstimate, EstimateCrowdLevel, ConfidenceLevel


class CoachSerializer(serializers.ModelSerializer):
    coach_type_display = serializers.CharField(source='get_coach_type_display', read_only=True)
    crowd_info = serializers.SerializerMethodField()

    class Meta:
        model = Coach
        fields = [
            'id', 'coach_number', 'coach_type', 'coach_type_display',
            'coach_label', 'position', 'crowd_info'
        ]

    def get_crowd_info(self, obj):
        journey_date = self.context.get('journey_date', timezone.localdate())
        try:
            est = CrowdEstimate.objects.get(train=obj.train, coach=obj, journey_date=journey_date)
            return {
                'crowd_level': est.crowd_level,
                'valid_report_count': est.valid_report_count,
                'confidence_level': est.confidence_level,
                'confidence_score': est.confidence_score,
                'last_updated': est.last_updated.isoformat() if est.last_updated else None,
                'explanation': est.explanation,
                'distribution': est.distribution,
            }
        except CrowdEstimate.DoesNotExist:
            return {
                'crowd_level': EstimateCrowdLevel.INSUFFICIENT_DATA,
                'valid_report_count': 0,
                'confidence_level': ConfidenceLevel.NONE,
                'confidence_score': 0.0,
                'last_updated': None,
                'explanation': 'Not enough information for this coach yet.',
                'distribution': {},
            }


class TrainStopSerializer(serializers.ModelSerializer):
    station = StationSerializer(read_only=True)

    class Meta:
        model = TrainStop
        fields = [
            'id', 'stop_order', 'station', 'arrival_time', 'departure_time',
            'distance_km', 'halt_minutes'
        ]


class TrainListSerializer(serializers.ModelSerializer):
    source_station = StationSerializer(read_only=True)
    destination_station = StationSerializer(read_only=True)
    crowd_estimate = serializers.SerializerMethodField()
    is_saved = serializers.SerializerMethodField()

    class Meta:
        model = Train
        fields = [
            'id', 'train_number', 'train_name', 'source_station',
            'destination_station', 'departure_time', 'arrival_time',
            'duration_hours', 'runs_on_days', 'is_active', 'is_demo_data',
            'crowd_estimate', 'is_saved'
        ]

    def get_crowd_estimate(self, obj):
        journey_date = self.context.get('journey_date', timezone.localdate())
        try:
            est = CrowdEstimate.objects.get(train=obj, coach=None, journey_date=journey_date)
            return {
                'crowd_level': est.crowd_level,
                'valid_report_count': est.valid_report_count,
                'confidence_level': est.confidence_level,
                'confidence_score': est.confidence_score,
                'last_updated': est.last_updated.isoformat() if est.last_updated else None,
                'explanation': est.explanation,
                'distribution': est.distribution,
            }
        except CrowdEstimate.DoesNotExist:
            return {
                'crowd_level': EstimateCrowdLevel.INSUFFICIENT_DATA,
                'valid_report_count': 0,
                'confidence_level': ConfidenceLevel.NONE,
                'confidence_score': 0.0,
                'last_updated': None,
                'explanation': 'Not enough crowd reports received yet.',
                'distribution': {},
            }

    def get_is_saved(self, obj):
        user = self.context.get('user')
        if user and user.is_authenticated:
            return SavedTrain.objects.filter(user=user, train=obj).exists()
        return False


class TrainDetailSerializer(TrainListSerializer):
    stops = TrainStopSerializer(many=True, read_only=True)
    coaches = serializers.SerializerMethodField()

    class Meta(TrainListSerializer.Meta):
        fields = TrainListSerializer.Meta.fields + ['stops', 'coaches']

    def get_coaches(self, obj):
        coaches = obj.coaches.all().order_by('position')
        return CoachSerializer(coaches, many=True, context=self.context).data
