from django.urls import path
from apps.crowd_engine.views import TrainCrowdEstimateAPIView, CoachCrowdEstimateAPIView

app_name = 'crowd_engine'

urlpatterns = [
    path('trains/<int:train_id>/crowd/', TrainCrowdEstimateAPIView.as_view(), name='train-crowd'),
    path('trains/<int:train_id>/coaches/<int:coach_id>/crowd/', CoachCrowdEstimateAPIView.as_view(), name='coach-crowd'),
]
