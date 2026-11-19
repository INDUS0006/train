from django.db import models
from django.conf import settings
from apps.trains.models import Train, Coach


class CrowdLevel(models.TextChoices):
    LOW = 'LOW', 'Low'
    MEDIUM = 'MEDIUM', 'Medium'
    HIGH = 'HIGH', 'High'
    VERY_HIGH = 'VERY_HIGH', 'Very High'


class ReportSource(models.TextChoices):
    MANUAL = 'MANUAL', 'Passenger Manual Submission'
    GPS_VERIFIED = 'GPS_VERIFIED', 'GPS-Assisted Validated'
    DEMO = 'DEMO', 'Demonstration Seed Record'


class CrowdReport(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='crowd_reports'
    )
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='crowd_reports')
    journey_date = models.DateField(db_index=True)
    coach = models.ForeignKey(
        Coach,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='crowd_reports'
    )
    crowd_level = models.CharField(max_length=20, choices=CrowdLevel.choices)
    comment = models.TextField(blank=True)
    latitude = models.FloatField(null=True, blank=True)
    longitude = models.FloatField(null=True, blank=True)
    gps_accuracy = models.FloatField(null=True, blank=True)
    report_source = models.CharField(
        max_length=20, choices=ReportSource.choices, default=ReportSource.MANUAL
    )
    is_valid = models.BooleanField(default=True, db_index=True)
    invalidation_reason = models.CharField(max_length=150, blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['train', 'journey_date', 'is_valid']),
            models.Index(fields=['train', 'coach', 'journey_date', 'is_valid']),
            models.Index(fields=['user', 'created_at']),
        ]

    def __str__(self):
        coach_str = f" Coach {self.coach.coach_number}" if self.coach else " (Overall)"
        return f"{self.train.train_number}{coach_str} on {self.journey_date}: {self.crowd_level} by {self.user or 'Guest'}"
