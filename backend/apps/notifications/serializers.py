from rest_framework import serializers
from apps.notifications.models import InAppNotification


class InAppNotificationSerializer(serializers.ModelSerializer):
    notification_type_display = serializers.CharField(source='get_notification_type_display', read_only=True)
    train_number = serializers.CharField(source='train.train_number', read_only=True, allow_null=True)

    class Meta:
        model = InAppNotification
        fields = [
            'id', 'title', 'message', 'notification_type',
            'notification_type_display', 'train', 'train_number',
            'is_read', 'created_at'
        ]
