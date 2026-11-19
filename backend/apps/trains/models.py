from django.db import models
from django.conf import settings
from apps.stations.models import Station


class CoachType(models.TextChoices):
    GENERAL = 'GENERAL', 'General Unreserved'
    SLEEPER = 'SLEEPER', 'Sleeper (SL)'
    AC_3_TIER = 'AC_3_TIER', 'AC 3 Tier (3A)'
    AC_2_TIER = 'AC_2_TIER', 'AC 2 Tier (2A)'
    AC_1_TIER = 'AC_1_TIER', 'AC 1st Class (1A)'
    CHAIR_CAR = 'CHAIR_CAR', 'AC Chair Car (CC)'


class Train(models.Model):
    train_number = models.CharField(max_length=10, unique=True, db_index=True)
    train_name = models.CharField(max_length=120)
    source_station = models.ForeignKey(
        Station, on_delete=models.CASCADE, related_name='originating_trains'
    )
    destination_station = models.ForeignKey(
        Station, on_delete=models.CASCADE, related_name='terminating_trains'
    )
    departure_time = models.TimeField()
    arrival_time = models.TimeField()
    duration_hours = models.FloatField(default=5.0)
    runs_on_days = models.CharField(max_length=50, default='Daily')
    is_active = models.BooleanField(default=True)
    is_demo_data = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['train_number']

    def __str__(self):
        return f"{self.train_number} - {self.train_name} ({self.source_station.station_code} -> {self.destination_station.station_code})"


class TrainStop(models.Model):
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='stops')
    station = models.ForeignKey(Station, on_delete=models.CASCADE, related_name='train_stops')
    stop_order = models.PositiveIntegerField()
    arrival_time = models.TimeField(null=True, blank=True)
    departure_time = models.TimeField(null=True, blank=True)
    distance_km = models.FloatField(default=0.0)
    halt_minutes = models.PositiveIntegerField(default=2)

    class Meta:
        ordering = ['train', 'stop_order']
        unique_together = ('train', 'stop_order')

    def __str__(self):
        return f"{self.train.train_number} stop {self.stop_order}: {self.station.station_code}"


class Coach(models.Model):
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='coaches')
    coach_number = models.CharField(max_length=10)  # e.g., "S1", "B1", "A1", "GEN1"
    coach_type = models.CharField(max_length=20, choices=CoachType.choices, default=CoachType.SLEEPER)
    coach_label = models.CharField(max_length=60, blank=True)
    position = models.PositiveIntegerField(default=1)

    class Meta:
        ordering = ['train', 'position']
        unique_together = ('train', 'coach_number')

    def __str__(self):
        return f"{self.train.train_number} Coach {self.coach_number} ({self.get_coach_type_display()})"

    def save(self, *args, **kwargs):
        if not self.coach_label:
            self.coach_label = self.get_coach_type_display()
        super().save(*args, **kwargs)


class SavedTrain(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='saved_trains'
    )
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='saved_by_users')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']
        unique_together = ('user', 'train')

    def __str__(self):
        return f"{self.user} saved {self.train.train_number}"
