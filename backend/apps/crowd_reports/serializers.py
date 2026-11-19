from rest_framework import serializers
from apps.crowd_reports.models import CrowdReport, CrowdLevel, ReportSource
from apps.trains.models import Train, Coach


class CrowdReportSerializer(serializers.ModelSerializer):
    train_number = serializers.CharField(source='train.train_number', read_only=True)
    train_name = serializers.CharField(source='train.train_name', read_only=True)
    coach_number = serializers.CharField(source='coach.coach_number', read_only=True, allow_null=True)
    crowd_level_display = serializers.CharField(source='get_crowd_level_display', read_only=True)

    class Meta:
        model = CrowdReport
        fields = [
            'id', 'train', 'train_number', 'train_name', 'journey_date',
            'coach', 'coach_number', 'crowd_level', 'crowd_level_display',
            'comment', 'latitude', 'longitude', 'gps_accuracy',
            'report_source', 'is_valid', 'created_at'
        ]
        read_only_fields = ['id', 'is_valid', 'created_at']


class CrowdReportCreateSerializer(serializers.Serializer):
    train_id = serializers.IntegerField()
    journey_date = serializers.DateField()
    coach_id = serializers.IntegerField(required=False, allow_null=True)
    crowd_level = serializers.ChoiceField(choices=CrowdLevel.choices)
    comment = serializers.CharField(required=False, allow_blank=True, default='')
    latitude = serializers.FloatField(required=False, allow_null=True)
    longitude = serializers.FloatField(required=False, allow_null=True)
    gps_accuracy = serializers.FloatField(required=False, allow_null=True)

    def validate_train_id(self, value):
        if not Train.objects.filter(id=value, is_active=True).exists():
            raise serializers.ValidationError('Active train with this ID does not exist.')
        return value

    def validate(self, attrs):
        train_id = attrs.get('train_id')
        coach_id = attrs.get('coach_id')
        if coach_id:
            if not Coach.objects.filter(id=coach_id, train_id=train_id).exists():
                raise serializers.ValidationError({'coach_id': 'Coach does not belong to the selected train.'})
        return attrs
