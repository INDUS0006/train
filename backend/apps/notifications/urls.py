from django.urls import path
from apps.notifications.views import (
    NotificationListAPIView, NotificationMarkReadAPIView, NotificationMarkAllReadAPIView
)

app_name = 'notifications'

urlpatterns = [
    path('', NotificationListAPIView.as_view(), name='notification-list'),
    path('<int:pk>/read/', NotificationMarkReadAPIView.as_view(), name='notification-read'),
    path('read-all/', NotificationMarkAllReadAPIView.as_view(), name='notification-read-all'),
]
