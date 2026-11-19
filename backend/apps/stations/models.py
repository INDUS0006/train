from django.db import models


class Station(models.Model):
    station_code = models.CharField(max_length=10, unique=True, db_index=True)
    station_name = models.CharField(max_length=120)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100, blank=True, default='Telangana / Andhra Pradesh')
    latitude = models.FloatField()
    longitude = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['station_code']

    def __str__(self):
        return f"{self.station_name} ({self.station_code})"
