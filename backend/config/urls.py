from django.contrib import admin
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

urlpatterns = [
    path('admin/', admin.site.urls),

    # OpenAPI 3 Schema & Swagger UI
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('api/docs/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    path('api/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),

    # Domain APIs
    path('api/auth/', include('apps.accounts.urls', namespace='accounts')),
    path('api/stations/', include('apps.stations.urls', namespace='stations')),
    path('api/trains/', include('apps.trains.urls', namespace='trains')),
    path('api/', include('apps.crowd_engine.urls', namespace='crowd_engine')),
    path('api/crowd-reports/', include('apps.crowd_reports.urls', namespace='crowd_reports')),
    path('api/', include('apps.alternatives.urls', namespace='alternatives')),
    path('api/journey/', include('apps.journey_tracking.urls', namespace='journey_tracking')),
    path('api/notifications/', include('apps.notifications.urls', namespace='notifications')),
    path('api/', include('apps.analytics.urls', namespace='analytics')),
]
