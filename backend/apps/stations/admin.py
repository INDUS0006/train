from django.contrib import admin
from apps.stations.models import Station


@admin.register(Station)
class StationAdmin(admin.ModelAdmin):
    list_display = ('station_code', 'station_name', 'city', 'state', 'latitude', 'longitude')
    search_fields = ('station_code', 'station_name', 'city')
    list_filter = ('state', 'city')
