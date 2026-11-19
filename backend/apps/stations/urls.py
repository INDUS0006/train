from django.urls import path
from apps.stations.views import StationListAPIView

app_name = 'stations'

urlpatterns = [
    path('', StationListAPIView.as_view(), name='station-list'),
]
