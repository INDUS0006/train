from django.contrib import admin
from apps.crowd_engine.models import CrowdEstimate


@admin.register(CrowdEstimate)
class CrowdEstimateAdmin(admin.ModelAdmin):
    list_display = (
        'id', 'train', 'coach', 'journey_date', 'crowd_level',
        'confidence_level', 'valid_report_count', 'last_updated'
    )
    list_filter = ('crowd_level', 'confidence_level', 'journey_date', 'train')
    search_fields = ('train__train_number', 'train__train_name')
