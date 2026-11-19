import mimetypes
from pathlib import Path
from django.contrib import admin
from django.urls import path, re_path, include
from django.http import FileResponse, HttpResponse
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView

BASE_DIR = Path(__file__).resolve().parent.parent
POSSIBLE_DIRS = [
    BASE_DIR / 'public',
    BASE_DIR.parent / 'public',
    BASE_DIR.parent / 'frontend' / 'build' / 'web',
]

def get_public_dir():
    for d in POSSIBLE_DIRS:
        if d.exists() and (d / 'index.html').exists():
            return d
    return BASE_DIR / 'public'

def serve_flutter(request, path=''):
    public_dir = get_public_dir()
    clean_path = path.lstrip('/')
    if not clean_path:
        file_path = public_dir / 'index.html'
    else:
        file_path = public_dir / clean_path

    if file_path.exists() and file_path.is_file():
        content_type, _ = mimetypes.guess_type(str(file_path))
        if clean_path.endswith('.wasm'):
            content_type = 'application/wasm'
        elif clean_path.endswith('.js'):
            content_type = 'application/javascript'
        return FileResponse(open(file_path, 'rb'), content_type=content_type)

    # For SPA routes (e.g. /trains, /profile), fallback to index.html
    index_file = public_dir / 'index.html'
    if index_file.exists():
        return FileResponse(open(index_file, 'rb'), content_type='text/html')

    return HttpResponse("TrainBuddy Frontend loading or index.html not found.", status=404)

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

    # Frontend Single Page App fallback
    re_path(r'^(?P<path>.*)$', serve_flutter),
]
