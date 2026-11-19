from django.db import models
from django.conf import settings
from apps.trains.models import Train


class JourneySession(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='journey_sessions'
    )
    train = models.ForeignKey(Train, on_delete=models.CASCADE, related_name='journey_sessions')
    journey_date = models.DateField()
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)
    last_latitude = models.FloatField(null=True, blank=True)
    last_longitude = models.FloatField(null=True, blank=True)
    last_accuracy = models.FloatField(null=True, blank=True)
    is_near_route = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-start_time']

    def __str__(self):
        status = 'Active' if self.is_active else 'Ended'
        return f"{self.user} on {self.train.train_number} ({status})"
