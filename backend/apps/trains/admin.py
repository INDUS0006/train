from django.contrib import admin
from apps.trains.models import Train, TrainStop, Coach, SavedTrain


class TrainStopInline(admin.TabularInline):
    model = TrainStop
    extra = 1


class CoachInline(admin.TabularInline):
    model = Coach
    extra = 1


@admin.register(Train)
class TrainAdmin(admin.ModelAdmin):
    list_display = ('train_number', 'train_name', 'source_station', 'destination_station', 'departure_time', 'arrival_time', 'is_active', 'is_demo_data')
    list_filter = ('is_active', 'is_demo_data', 'source_station', 'destination_station')
    search_fields = ('train_number', 'train_name')
    inlines = [TrainStopInline, CoachInline]


@admin.register(TrainStop)
class TrainStopAdmin(admin.ModelAdmin):
    list_display = ('train', 'stop_order', 'station', 'arrival_time', 'departure_time', 'distance_km')
    list_filter = ('train', 'station')


@admin.register(Coach)
class CoachAdmin(admin.ModelAdmin):
    list_display = ('train', 'coach_number', 'coach_type', 'coach_label', 'position')
    list_filter = ('coach_type', 'train')
    search_fields = ('coach_number', 'coach_label', 'train__train_number')


@admin.register(SavedTrain)
class SavedTrainAdmin(admin.ModelAdmin):
    list_display = ('user', 'train', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('user__email', 'train__train_number')
