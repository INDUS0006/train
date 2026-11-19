from django.urls import path
from apps.trains.views import (
    TrainListAPIView, TrainSearchAPIView, TrainDetailAPIView,
    TrainStopsAPIView, TrainCoachesAPIView, TrainToggleSaveAPIView,
    SavedTrainsListAPIView
)

app_name = 'trains'

urlpatterns = [
    path('', TrainListAPIView.as_view(), name='train-list'),
    path('search/', TrainSearchAPIView.as_view(), name='train-search'),
    path('saved/', SavedTrainsListAPIView.as_view(), name='train-saved'),
    path('<int:pk>/', TrainDetailAPIView.as_view(), name='train-detail'),
    path('<int:pk>/stops/', TrainStopsAPIView.as_view(), name='train-stops'),
    path('<int:pk>/coaches/', TrainCoachesAPIView.as_view(), name='train-coaches'),
    path('<int:pk>/save/', TrainToggleSaveAPIView.as_view(), name='train-toggle-save'),
]
