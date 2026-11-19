from django.contrib import admin
from apps.journey_tracking.models import JourneySession


@admin.register(JourneySession)
class JourneySessionAdmin(admin.ModelAdmin):
    list_display = ('user', 'train', 'journey_date', 'start_time', 'is_active', 'is_near_route')
    list_filter = ('is_active', 'is_near_route', 'journey_date')
    search_fields = ('user__email', 'train__train_number')
