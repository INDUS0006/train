from django.urls import path
from apps.crowd_reports.views import CrowdReportCreateAPIView, MyCrowdReportsListAPIView

app_name = 'crowd_reports'

urlpatterns = [
    path('', CrowdReportCreateAPIView.as_view(), name='crowd-report-create'),
    path('my-reports/', MyCrowdReportsListAPIView.as_view(), name='my-crowd-reports'),
]
