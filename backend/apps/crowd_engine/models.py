from django.db import models
from apps.trains.models import Train, Coach


class EstimateCrowdLevel(models.TextChoices):
    LOW = 'LOW', 'Low'
    MEDIUM = 'MEDIUM', 'Medium'
    HIGH = 'HIGH', 'High'
    VERY_HIGH = 'VERY_HIGH', 'Very High'
    INSUFFICIENT_DATA = 'INSUFFICIENT_DATA', 'Not enough data'


class ConfidenceLevel(models.TextChoices):
    NONE = 'NONE', 'No Data'
    LOW = 'LOW', 'Low Confidence'
    MEDIUM = 'MEDIUM', 'Medium Confidence'
    HIGH = 'HIGH', 'High Confidence'


class CrowdEstimate(models.Model):
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='crowd_estimates')
    journey_date = models.DateField(db_index=True)
    coach = models.ForeignKey(
        Coach,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='crowd_estimates'
    )
    crowd_level = models.CharField(
        max_length=25,
        choices=EstimateCrowdLevel.choices,
        default=EstimateCrowdLevel.INSUFFICIENT_DATA
    )
    valid_report_count = models.PositiveIntegerField(default=0)
    confidence_level = models.CharField(
        max_length=20,
        choices=ConfidenceLevel.choices,
        default=ConfidenceLevel.NONE
    )
    confidence_score = models.FloatField(default=0.0)  # 0.0 to 1.0
    last_updated = models.DateTimeField(auto_now=True)
    calculation_method = models.CharField(
        max_length=60, default='WEIGHTED_RECENCY_CONSENSUS'
    )
    distribution = models.JSONField(default=dict, blank=True)
    explanation = models.TextField(blank=True)

    class Meta:
        ordering = ['-last_updated']
        unique_together = ('train', 'journey_date', 'coach')
        indexes = [
            models.Index(fields=['train', 'journey_date']),
            models.Index(fields=['train', 'journey_date', 'coach']),
        ]

    def __str__(self):
        coach_str = f" Coach {self.coach.coach_number}" if self.coach else " (Overall)"
        return f"{self.train.train_number}{coach_str} on {self.journey_date}: {self.crowd_level} ({self.confidence_level}, {self.valid_report_count} reports)"
