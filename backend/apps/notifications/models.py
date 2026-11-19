from django.db import models
from django.conf import settings
from apps.trains.models import Train


class NotificationType(models.TextChoices):
    CROWD_UPDATE = 'CROWD_UPDATE', 'Crowd Level Update'
    JOURNEY_REMINDER = 'JOURNEY_REMINDER', 'Journey Reminder'
    NEW_REPORT = 'NEW_REPORT', 'New Crowd Report'
    SYSTEM_NOTICE = 'SYSTEM_NOTICE', 'System Notice'


class InAppNotification(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='notifications'
    )
    title = models.CharField(max_length=150)
    message = models.TextField()
    notification_type = models.CharField(
        max_length=30, choices=NotificationType.choices, default=NotificationType.SYSTEM_NOTICE
    )
    train = models.ForeignKey(
        Train, on_delete=models.SET_NULL, null=True, blank=True, related_name='notifications'
    )
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"[{self.notification_type}] {self.title}"
