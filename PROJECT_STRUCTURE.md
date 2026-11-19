# TrainBuddy – Project Structure

> **TrainBuddy – Train + Crowd Advisor**  
> *"Know the train. Know the crowd. Choose how to travel."*

---

## Full Directory Tree

```
train/
├── backend/
│   ├── config/                     # Django project configuration
│   │   ├── settings.py             # SQLite default, JWT, CORS, drf-spectacular
│   │   ├── urls.py                 # Root URL dispatcher + Swagger /api/docs/
│   │   ├── wsgi.py
│   │   └── asgi.py                 # Django Channels hook for future realtime
│   │
│   ├── apps/
│   │   ├── accounts/               # Custom User, JWT Auth, 1-Click Guest Demo
│   │   │   ├── models.py           # AbstractBaseUser with email login
│   │   │   ├── serializers.py      # Register, Login, Profile serializers
│   │   │   ├── views.py            # Register, Login (JWT), Refresh, Profile, Guest
│   │   │   ├── urls.py
│   │   │   ├── admin.py
│   │   │   └── apps.py
│   │   │
│   │   ├── stations/               # Railway station master data
│   │   │   ├── models.py           # Station (code, name, city, lat, lng)
│   │   │   ├── serializers.py
│   │   │   ├── views.py            # List & search stations
│   │   │   ├── urls.py
│   │   │   └── admin.py
│   │   │
│   │   ├── trains/                 # Trains, stops, coaches, saved trains
│   │   │   ├── models.py           # Train, TrainStop, Coach, SavedTrain
│   │   │   ├── serializers.py      # Nested serializers (stops, coaches, crowd_info)
│   │   │   ├── views.py            # Search, Detail, Coach list, Save/unsave
│   │   │   ├── urls.py
│   │   │   ├── admin.py
│   │   │   ├── services.py         # Business logic (search, filtering)
│   │   │   └── management/
│   │   │       └── commands/
│   │   │           └── seed_demo_data.py   # --reset flag: 10 stations, 5 trains,
│   │   │                                   #   8 coaches/train, 32+ crowd reports
│   │   │
│   │   ├── crowd_reports/          # Passenger crowd submissions
│   │   │   ├── models.py           # CrowdReport (user, train, coach, level, GPS)
│   │   │   ├── serializers.py
│   │   │   ├── views.py            # Submit, List, anti-spam (15-min window)
│   │   │   ├── urls.py
│   │   │   └── admin.py
│   │   │
│   │   ├── crowd_engine/           # Weighted consensus estimation
│   │   │   ├── models.py           # CrowdEstimate (train, coach, level, confidence)
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   ├── urls.py
│   │   │   └── services.py         # CrowdEngineService
│   │   │                           #   Recency decay: <2h=1.5×, 2–6h=1.2×, 6–12h=1.0×, older=0.7×
│   │   │                           #   GPS verified: 1.4× weight boost
│   │   │                           #   Min reports: 2 coach, 3 train
│   │   │
│   │   ├── journey_tracking/       # Privacy-preserving GPS corridor validation
│   │   │   ├── models.py           # JourneySession (opt-in, start/stop, corridor)
│   │   │   ├── serializers.py
│   │   │   ├── views.py            # Start, Stop, Update location (haversine check)
│   │   │   └── urls.py
│   │   │
│   │   ├── alternatives/           # Lower-crowd travel options per train
│   │   │   ├── models.py           # TravelAlternative (type, fare, duration, source_note)
│   │   │   ├── serializers.py
│   │   │   ├── views.py
│   │   │   └── urls.py
│   │   │
│   │   ├── notifications/          # In-app alert feed
│   │   │   ├── models.py           # InAppNotification (user, type, message, is_read)
│   │   │   ├── serializers.py
│   │   │   ├── views.py            # List (with unread_count), mark-read
│   │   │   └── urls.py
│   │   │
│   │   └── analytics/              # Dashboard metrics & demo reset
│   │       ├── views.py            # Dashboard stats, POST /api/demo/reset/
│   │       └── urls.py
│   │
│   ├── manage.py
│   ├── requirements.txt            # Django 5.1, DRF 3.17, SimpleJWT 5.5,
│   │                               # drf-spectacular, django-cors-headers, psycopg2
│   ├── .env.example                # USE_SQLITE, SECRET_KEY, DB_*, ALLOWED_HOSTS
│   ├── .env                        # Active env (USE_SQLITE=True for zero-setup demo)
│   └── venv/                       # Python 3.13 virtual environment
│
└── frontend/
    ├── lib/
    │   ├── main.dart               # MultiProvider setup, MaterialApp, theme init
    │   │
    │   ├── core/
    │   │   ├── constants/
    │   │   │   ├── app_colors.dart     # Brand palette + semantic crowd colours
    │   │   │   └── api_constants.dart  # All 25 API endpoints
    │   │   ├── theme/
    │   │   │   └── app_theme.dart      # Material 3 theme (navy/blue/white)
    │   │   └── utils/
    │   │       └── crowd_utils.dart    # Color, label, icon, advisory mapping
    │   │
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── station_model.dart
    │   │   ├── coach_model.dart        # CoachModel + CoachCrowdInfo
    │   │   ├── train_model.dart        # TrainModel + TrainStopModel
    │   │   ├── crowd_report_model.dart
    │   │   ├── travel_alternative_model.dart
    │   │   └── notification_model.dart
    │   │
    │   ├── services/
    │   │   ├── api_service.dart        # HTTP client, JWT header injection
    │   │   ├── auth_service.dart       # Login, register, guest, logout
    │   │   ├── storage_service.dart    # SharedPreferences token store
    │   │   └── location_service.dart   # GPS permission + simulated corridor check
    │   │
    │   ├── providers/
    │   │   ├── auth_provider.dart      # User state, login/logout
    │   │   ├── train_provider.dart     # Featured trains, search, details
    │   │   ├── crowd_provider.dart     # Crowd estimates, alternatives, reports
    │   │   ├── journey_provider.dart   # GPS session management
    │   │   └── notification_provider.dart  # Unread count, fetch, mark-read
    │   │
    │   ├── widgets/
    │   │   ├── demo_banner.dart        # "DEMO DATA – NOT LIVE" yellow strip
    │   │   ├── crowd_badge.dart        # Coloured crowd level pill
    │   │   ├── train_card.dart         # Train result card with crowd indicator
    │   │   ├── coach_card.dart         # Legacy coach list tile (kept for reference)
    │   │   └── train_top_view.dart     # ★ TOP-DOWN TRAIN VISUALIZER
    │   │                               #   - Locomotive + coach bogies (top-down)
    │   │                               #   - Coloured passenger dots per crowd level
    │   │                               #   - Animated opacity filtering per category
    │   │                               #   - Dot colour coding:
    │   │                               #       General   → Red
    │   │                               #       Sleeper   → Yellow
    │   │                               #       AC 3 Tier → Orange
    │   │                               #       AC 2 Tier → Green
    │   │                               #       AC First  → Blue
    │   │
    │   └── screens/
    │       ├── splash_screen.dart                     # Animated splash, 2.2 s
    │       ├── auth/
    │       │   ├── login_screen.dart                  # Email/password + Guest Demo
    │       │   └── register_screen.dart               # Name, email, password
    │       ├── home/
    │       │   ├── home_dashboard_screen.dart         # Search, popular routes, featured
    │       │   └── main_navigation_screen.dart        # 5-tab bottom navigation
    │       ├── search/
    │       │   ├── train_search_results_screen.dart   # Train cards with crowd badge
    │       │   └── train_detail_screen.dart           # Stops + crowd summary + actions
    │       ├── crowd/
    │       │   ├── coach_crowd_screen.dart            # ★ REDESIGNED
    │       │   │                                      #   Top-down train view
    │       │   │                                      #   Filter: All / AC / Sleeper / General
    │       │   │                                      #   Animated coach highlight on filter
    │       │   │                                      #   Detail cards with mini dot preview
    │       │   └── submit_crowd_report_screen.dart    # Coach + level + comment form
    │       ├── journey/
    │       │   └── gps_validation_screen.dart         # Opt-in GPS, privacy bullets
    │       ├── alternatives/
    │       │   └── alternatives_screen.dart           # ★ REDESIGNED
    │       │                                          #   Mode tabs: Train / Bus / Car / Flight
    │       │                                          #   Expandable cards with fare, distance,
    │       │                                          #   duration, highlights, disclaimers
    │       ├── map/
    │       │   └── crowd_map_screen.dart              # OpenStreetMap + station markers
    │       │                                          #   Tap map (not markers) to dismiss
    │       │                                          #   mouse_tracker assertion fixed
    │       ├── notifications/
    │       │   └── notifications_screen.dart          # Alert feed, mark-read
    │       └── profile/
    │           └── profile_screen.dart               # Saved trains + Demo Reset button
    │
    ├── test/
    │   ├── widget_test.dart           # Splash screen smoke test
    │   └── map_test.dart              # CrowdMapScreen with empty stops guard
    │
    ├── pubspec.yaml                   # flutter_map 8.3.2, provider, http,
    │                                  # shared_preferences, intl, latlong2
    └── analysis_options.yaml          # deprecated_member_use: ignore
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/auth/register/` | Create account |
| POST | `/api/auth/login/` | JWT login |
| POST | `/api/auth/token/refresh/` | Refresh access token |
| POST | `/api/auth/guest/` | 1-click guest demo |
| GET | `/api/auth/profile/` | Current user profile |
| GET | `/api/stations/` | Station list |
| GET | `/api/trains/search/` | Search trains by route + date |
| GET | `/api/trains/<id>/` | Train detail with stops + coaches |
| GET | `/api/trains/<id>/coaches/` | Coach list with crowd estimates |
| GET | `/api/trains/<id>/alternatives/` | Alternate trains |
| POST | `/api/trains/<id>/save/` | Save / unsave train |
| POST | `/api/crowd-reports/` | Submit crowd report |
| GET | `/api/crowd-reports/my/` | My report history |
| GET | `/api/notifications/` | Notification feed |
| POST | `/api/notifications/<id>/read/` | Mark notification read |
| GET | `/api/dashboard/` | Home dashboard stats |
| POST | `/api/demo/reset/` | Reset all demo data |
| GET | `/api/docs/` | Swagger UI |
| GET | `/api/schema/` | OpenAPI schema |

---

## Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| Passenger | `rahul@trainbuddy.demo` | `TrainBuddy@2026` |
| Passenger | `priya@trainbuddy.demo` | `TrainBuddy@2026` |
| Admin | `admin@trainbuddy.demo` | `TrainBuddy@2026` |
| Guest | (1-click on login screen) | — |

---

## Crowd Engine Rules

| Factor | Weight |
|--------|--------|
| Report < 2 hours old | 1.5× |
| Report 2–6 hours old | 1.2× |
| Report 6–12 hours old | 1.0× |
| Report > 12 hours old | 0.7× |
| GPS verified report | +1.4× |
| Minimum for coach estimate | 2 reports |
| Minimum for train estimate | 3 reports |

---

## Key Design Decisions

> [!IMPORTANT]
> All demonstration data is clearly labelled **"DEMO DATA – NOT LIVE RAILWAY INFORMATION"** on every screen.

> [!NOTE]
> GPS is never claimed to count individual passengers or identify coach numbers. Location sharing is strictly opt-in and explained on the GPS Validation screen.

> [!TIP]
> The app works without PostgreSQL — SQLite is the default (`USE_SQLITE=True` in `.env`). Switch to PostgreSQL by setting `USE_SQLITE=False` and providing DB credentials.

> [!CAUTION]
> Anti-spam: Duplicate crowd reports within 15 minutes update the existing record — they never inflate the report count.

---

## Running the App

### Backend
```powershell
cd backend
.\venv\Scripts\activate
python manage.py runserver 127.0.0.1:8000
# Optional: seed fresh demo data
python manage.py seed_demo_data --reset
```

### Frontend
```powershell
cd frontend
flutter run -d chrome --web-port 3000
# or for Android:
flutter run -d <device-id>
```

### Tests
```powershell
# Backend (12 tests)
cd backend; .\venv\Scripts\python manage.py test

# Frontend (2 tests)
cd frontend; flutter test

# Lint check
cd frontend; flutter analyze   # → No issues found
```
