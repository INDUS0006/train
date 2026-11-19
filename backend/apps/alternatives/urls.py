from django.urls import path
from apps.alternatives.views import TrainAlternativesAPIView

app_name = 'alternatives'

urlpatterns = [
    path('trains/<int:pk>/alternatives/', TrainAlternativesAPIView.as_view(), name='train-alternatives'),
]
