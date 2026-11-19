from django.urls import path
from apps.analytics.views import DashboardAPIView, DemoResetAPIView

app_name = 'analytics'

urlpatterns = [
    path('dashboard/', DashboardAPIView.as_view(), name='dashboard'),
    path('demo/reset/', DemoResetAPIView.as_view(), name='demo-reset'),
]
