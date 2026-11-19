from django.contrib import admin
from apps.alternatives.models import TravelAlternative


@admin.register(TravelAlternative)
class TravelAlternativeAdmin(admin.ModelAdmin):
    list_display = ('title', 'train', 'alternative_type', 'departure_time', 'duration_text', 'crowd_level', 'is_demo')
    list_filter = ('alternative_type', 'crowd_level', 'is_demo')
    search_fields = ('title', 'operator', 'train__train_number')
