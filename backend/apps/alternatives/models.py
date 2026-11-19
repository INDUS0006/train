from django.db import models
from apps.trains.models import Train


class AlternativeType(models.TextChoices):
    TRAIN = 'TRAIN', 'Alternative Train'
    BUS = 'BUS', 'Express Bus'
    CAB = 'CAB', 'Shared Cab'
    OTHER = 'OTHER', 'Other Travel Option'


class TravelAlternative(models.Model):
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='alternatives')
    alternative_type = models.CharField(
        max_length=20, choices=AlternativeType.choices, default=AlternativeType.TRAIN
    )
    title = models.CharField(max_length=150)
    operator = models.CharField(max_length=100, default='Indian Railways')
    departure_time = models.TimeField()
    arrival_time = models.TimeField()
    duration_text = models.CharField(max_length=50)
    crowd_level = models.CharField(max_length=25, default='LOW')
    fare_estimate = models.CharField(max_length=50, blank=True)
    source_note = models.CharField(
        max_length=250, default='Demo option – for illustrative comparison'
    )
    is_demo = models.BooleanField(default=True)

    class Meta:
        ordering = ['departure_time']

    def __str__(self):
        return f"{self.title} ({self.get_alternative_type_display()} for {self.train.train_number})"
