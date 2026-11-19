from django.urls import path
from apps.journey_tracking.views import JourneyStartAPIView, JourneyStopAPIView, JourneyStatusAPIView

app_name = 'journey_tracking'

urlpatterns = [
    path('start/', JourneyStartAPIView.as_view(), name='journey-start'),
    path('stop/', JourneyStopAPIView.as_view(), name='journey-stop'),
    path('status/', JourneyStatusAPIView.as_view(), name='journey-status'),
]
