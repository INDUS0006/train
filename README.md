# TrainBuddy – Train + Crowd Advisor

> **"Know the train. Know the crowd. Choose how to travel."**

[![Django](https://img.shields.io/badge/Backend-Django%205.1%20%7C%20DRF-092E20?logo=django)](https://www.djangoproject.com/)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter%203.50%20%7C%20Dart-02569B?logo=flutter)](https://flutter.dev/)
[![OpenAPI](https://img.shields.io/badge/API-OpenAPI%203.0%20%7C%20Swagger-85EA2D?logo=swagger)](http://127.0.0.1:8000/api/docs/)
[![License](https://img.shields.io/badge/License-Demo%20MVP-blue.svg)]()

---

## 1. Project Overview

**TrainBuddy** is a full-stack railway companion application designed to give train passengers visibility into real passenger crowding levels before they board. While conventional railway apps provide schedules and platform updates, TrainBuddy focuses on crowd transparency:

1. **Overall Train Crowd Estimation**: Real-time aggregated crowd category (*Low*, *Medium*, *High*, *Very High*, or *Not Enough Data*).
2. **Coach-Wise Crowd Breakdown**: Coach-level visibility across Sleeper (S1, S2, S3), AC 3 Tier (B1, B2), AC 2 Tier (A1), and General unreserved coaches.
3. **Verified Crowd Reporting**: Passengers submit on-the-ground observations with rate-limiting, anti-spam protections, and duplicate prevention.
4. **GPS-Assisted Journey Validation (Opt-In)**: Privacy-preserving corridor verification confirming passenger proximity to train stops without exposing or permanently storing individual coordinates.
5. **Weighted Estimation Engine**: Transparent consensus scoring incorporating report recency decay (reports <2 hrs get 1.5× weight) and GPS verification weight (1.4×).
6. **Honest "Insufficient Data" Handling**: When report thresholds are not met, the system transparently indicates insufficient data rather than fabricating numbers.
7. **Alternative Travel Options**: Suggests alternative trains, intercity express buses (e.g., TSRTC Garuda Plus), and shared cabs when a selected train is overcrowded.
8. **OpenStreetMap Interactive Route View**: Interactive railway corridor map with stations and demonstration train position tracking.
9. **Presentation Demo Mode**: Built-in 1-click Guest Demo access and instant database reset for live audience presentations.

> **Important Disclosure**: This application uses clearly marked demonstration records (*"DEMO DATA – NOT LIVE RAILWAY INFORMATION"*). GPS is strictly used to validate corridor presence with explicit user consent; it is never used as a passenger-counting sensor nor to claim coach-level positioning.

---

## 2. Technology Stack & Architecture

### Backend
- **Python 3.13**
- **Django 5.1 & Django REST Framework (DRF)**
- **Simple JWT** (`djangorestframework-simplejwt`) for authentication
- **PostgreSQL** support with zero-configuration **SQLite** fallback via `.env`
- **drf-spectacular** for OpenAPI 3.0 specification & interactive Swagger UI
- **django-cors-headers** for cross-origin Flutter Web/Mobile support
- **Modular Domain Architecture**: `accounts`, `stations`, `trains`, `crowd_reports`, `crowd_engine`, `journey_tracking`, `alternatives`, `notifications`, `analytics`

### Frontend
- **Flutter 3.50 (Dart 3.14)**
- **Material 3 Design System**: Navy Blue (`#08234C`), Primary Blue (`#1769AA`), Soft Background (`#F5F8FC`), and Semantic Crowd Colors
- **Provider** pattern for state management
- **flutter_map & latlong2** with OpenStreetMap tiles
- **shared_preferences** for secure local token and preference persistence
- **http** with custom service layer, automated Bearer auth, and error handling

---

## 3. Project Structure

```text
train/
├── backend/
│   ├── config/
│   │   ├── settings.py           # Database, DRF, JWT, CORS, Spectacular
│   │   ├── urls.py               # Master API routing & Swagger endpoints
│   │   ├── wsgi.py
│   │   └── asgi.py
│   ├── apps/
│   │   ├── accounts/             # Custom User model, Auth views, JWT, Guest login
│   │   ├── stations/             # Railway stations, coordinates, search
│   │   ├── trains/               # Train, TrainStop, Coach, SavedTrain models & seed command
│   │   ├── crowd_reports/        # Passenger report submission, validation, anti-spam
│   │   ├── crowd_engine/         # CrowdEngineService, CrowdEstimate model, consensus
│   │   ├── journey_tracking/     # Opt-in GPS corridor validation session
│   │   ├── alternatives/         # Travel alternatives (Trains, Buses, Cabs)
│   │   ├── notifications/        # In-app notifications & alert feed
│   │   └── analytics/            # Dashboard metrics & demo reset endpoint
│   ├── manage.py
│   ├── requirements.txt
│   ├── .env.example
│   └── .env
└── frontend/
    ├── lib/
    │   ├── main.dart             # MultiProvider setup & theme initialization
    │   ├── core/
    │   │   ├── constants/        # AppColors, ApiConstants
    │   │   ├── theme/            # Material 3 light theme definition
    │   │   └── utils/            # CrowdUtils (color mappings, labels, advisory text)
    │   ├── models/               # Strongly-typed models (Train, Coach, User, Report, etc.)
    │   ├── services/             # ApiService, AuthService, StorageService, LocationService
    │   ├── providers/            # AuthProvider, TrainProvider, CrowdProvider, JourneyProvider, NotificationProvider
    │   ├── widgets/              # TrainCard, CoachCard, CrowdBadge, DemoBanner
    │   └── screens/
    │       ├── splash_screen.dart
    │       ├── auth/             # LoginScreen, RegisterScreen
    │       ├── home/             # HomeDashboardScreen, MainNavigationScreen
    │       ├── search/           # TrainSearchResultsScreen, TrainDetailScreen
    │       ├── crowd/            # CoachCrowdScreen, SubmitCrowdReportScreen
    │       ├── journey/          # GpsValidationScreen
    │       ├── alternatives/     # AlternativesScreen
    │       ├── map/              # CrowdMapScreen (OpenStreetMap)
    │       ├── notifications/    # NotificationsScreen
    │       └── profile/          # ProfileScreen (Demo reset, settings, saved trains)
    └── pubspec.yaml
```

---

## 4. Demo Login Credentials

| Role | Email | Password | Purpose |
| :--- | :--- | :--- | :--- |
| **Guest Demo (1-Click)** | *None required* | *None required* | Instant demo presentation without typing credentials |
| **Demo Passenger** | `rahul@trainbuddy.demo` | `TrainBuddy@2026` | Normal passenger account with saved trains & history |
| **Commuter** | `priya@trainbuddy.demo` | `TrainBuddy@2026` | Second commuter account |
| **System Administrator** | `admin@trainbuddy.demo` | `TrainBuddy@2026` | Full Django Admin access at `/admin/` |

---

## 5. Quick Setup & Run Instructions

### Windows (PowerShell)

#### Step 1: Backend Setup
```powershell
# Navigate to backend directory
cd c:\Users\INDUS_PC_I\Desktop\train\backend

# Create Python virtual environment (if not already created)
python -m venv venv

# Activate virtual environment
.\venv\Scripts\Activate.ps1

# Install requirements
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Seed demonstration records (creates stations, trains, coaches, demo reports)
python manage.py seed_demo_data --reset

# Run backend unit tests to verify system integrity
python manage.py test

# Start Django development server
python manage.py runserver 127.0.0.1:8000
```

> **API Documentation**: While the server is running, open [http://127.0.0.1:8000/api/docs/](http://127.0.0.1:8000/api/docs/) in your browser for the interactive Swagger UI.

#### Step 2: Frontend Setup (New Terminal)
```powershell
# Navigate to frontend directory
cd c:\Users\INDUS_PC_I\Desktop\train\frontend

# Fetch Flutter dependencies
flutter pub get

# Verify codebase health
flutter analyze

# Run Flutter tests
flutter test

# Launch the app in Google Chrome (Web) or connected device
flutter run -d chrome
```

---

### Ubuntu / Linux (Bash)

#### Step 1: Backend Setup
```bash
cd backend

# Create & activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Migrate & seed demo data
python manage.py migrate
python manage.py seed_demo_data --reset

# Run test suite
python manage.py test

# Start server
python manage.py runserver 0.0.0.0:8000
```

#### Step 2: Frontend Setup
```bash
cd frontend
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

---

## 6. PostgreSQL Configuration (Optional)

By default, the application runs on SQLite (`USE_SQLITE=True` in `.env`) so it can be demonstrated instantly with zero setup. To switch to PostgreSQL:

1. Create a PostgreSQL database:
   ```sql
   CREATE DATABASE trainbuddy;
   ```
2. Update `backend/.env`:
   ```env
   USE_SQLITE=False
   DB_NAME=trainbuddy
   DB_USER=postgres
   DB_PASSWORD=your_password
   DB_HOST=127.0.0.1
   DB_PORT=5432
   ```
3. Run migrations and re-seed:
   ```bash
   python manage.py migrate
   python manage.py seed_demo_data --reset
   ```

---

## 7. Interactive Demonstration Flow

Follow this step-by-step walkthrough to showcase TrainBuddy to an audience:

1. **Launch TrainBuddy**: The app opens with an animated splash screen and brand tagline: *"Know the train. Know the crowd. Choose how to travel."*
2. **Instant 1-Click Guest Demo**: On the Sign-In screen, tap **"Enter Guest Demo (Instant Access)"** to enter immediately without manual typing.
3. **Home Dashboard**:
   - Notice the prominent crowd banner: *"Check how crowded your train may be before boarding."*
   - Review popular routes (*Hyderabad → Vijayawada*, *Vijayawada → Visakhapatnam*, *Hyderabad → Warangal*).
   - Review the **Crowd Legend Card** explaining transparent consensus weighting.
4. **Search Trains**:
   - Select **FROM: HYB (Hyderabad Deccan)** and **TO: BZA (Vijayawada)**.
   - Tap **"Find Trains & Crowd Estimates"**.
5. **Review Search Results**:
   - Train cards display train number, name, timings, duration, and overall crowd badges:
     - **12723 Godavari Express**: High Crowd (32 valid reports).
     - **12727 Visakhapatnam Express**: Medium Crowd.
     - **17210 Sample Intercity**: Not Enough Data (only 1 report).
6. **Train Details**:
   - Tap on **12723 Godavari Express**.
   - Review the overall crowd level card, report count, and confidence score.
   - Scroll through the station halts timeline (HYB, SC, KZJ, WL, KMT, BZA, etc.).
7. **Coach-Wise Crowds**:
   - Tap **"Coach Crowds"**.
   - See realistic coach-by-coach variations:
     - `GEN1` & `GEN2`: Very High Crowd (Gate rush).
     - `S1`: High Crowd (Packed).
     - `S2`: Medium Crowd (Manageable).
     - `B1`: Low Crowd (Comfortable seating).
     - `B2`: High Crowd (Congested).
     - `A1`: Low Crowd (Spacious).
8. **Submit a New Crowd Report**:
   - Tap **"Report Crowd for Coach"** on coach **S1** or **S2**.
   - Select crowd level (*Low*, *Medium*, *High*, or *Very High*).
   - Add an optional comment and check **"GPS Journey Verification"**.
   - Tap **"Submit Validated Crowd Report"**.
   - Observe the confirmation and immediate recalculation of reports and estimate.
9. **Spam & Duplicate Prevention**:
   - Attempting to submit another report for the same coach within minutes automatically updates the user's previous report rather than inflating the count.
10. **Explore Alternatives**:
    - Tap **"Alternatives"** from Train Details to view lower-crowd options:
      - Train 12727 (Later departure, Medium crowd).
      - TSRTC Garuda Plus AC Express Bus (Low crowd).
      - Highway Shared Intercity Cab (Low crowd).
11. **OpenStreetMap Route View**:
    - Tap **"Route Map"** to inspect the railway line polyline and station markers on OpenStreetMap.
    - Tap any station marker to inspect halt duration and km distance.
12. **GPS Journey Validation (Opt-In)**:
    - Open **"GPS Journey Validation"**.
    - Tap **"Start GPS Journey Validation"** to verify corridor presence. Review clear privacy commitments.
13. **Repeatable Demo Reset**:
    - Go to **Profile** → **Demo Presentation Control**.
    - Tap **"Reset Demo Data to Seed State"** at any time to restore the demonstration database for the next audience presentation!

---

## 8. Complete REST API Reference

| Method | Endpoint | Description |
| :--- | :--- | :--- |
| `POST` | `/api/auth/register/` | Register new user account |
| `POST` | `/api/auth/login/` | Sign in with email and password |
| `POST` | `/api/auth/guest-login/` | Generate 1-click guest demo credentials |
| `POST` | `/api/auth/refresh/` | Refresh expired JWT access token |
| `GET` | `/api/auth/profile/` | Retrieve user profile & preferences |
| `GET` | `/api/dashboard/` | Retrieve popular routes, stats, and featured trains |
| `GET` | `/api/stations/` | List railway stations with coordinates |
| `GET` | `/api/trains/` | List active trains |
| `GET` | `/api/trains/search/` | Search trains by route, date, and query |
| `GET` | `/api/trains/{id}/` | Get train details with stops and coaches |
| `GET` | `/api/trains/{id}/stops/` | Get train route stops list |
| `GET` | `/api/trains/{id}/coaches/` | Get coaches with crowd estimates |
| `POST` | `/api/trains/{id}/save/` | Toggle saved/bookmarked train |
| `GET` | `/api/trains/saved/` | List user's saved trains |
| `GET` | `/api/trains/{id}/crowd/` | Get overall crowd estimate for train |
| `GET` | `/api/trains/{id}/coaches/{coach_id}/crowd/` | Get coach-level crowd estimate |
| `POST` | `/api/crowd-reports/` | Submit passenger crowd report |
| `GET` | `/api/crowd-reports/my-reports/` | List current user's submitted reports |
| `GET` | `/api/trains/{id}/alternatives/` | List travel alternatives for train |
| `POST` | `/api/journey/start/` | Start opt-in GPS journey validation |
| `POST` | `/api/journey/stop/` | Stop active journey tracking |
| `GET` | `/api/journey/status/` | Get active journey status and route proximity |
| `GET` | `/api/notifications/` | In-app notification feed |
| `POST` | `/api/notifications/{id}/read/` | Mark notification as read |
| `POST` | `/api/notifications/read-all/` | Mark all notifications as read |
| `POST` | `/api/demo/reset/` | Reset & re-seed demonstration database |
| `GET` | `/api/docs/` | Interactive Swagger UI API documentation |
| `GET` | `/api/schema/` | OpenAPI 3.0 YAML schema download |

---

## 9. Testing & Quality Verification

### Backend Automated Test Suite
Run the 12 comprehensive unit and integration tests:
```powershell
cd backend
.\venv\Scripts\python manage.py test
```
**Test Coverage:**
- User registration, login, and guest demo token generation
- Train route searching and stop sequence filtering
- Train details and stop schedule serialization
- Crowd report creation with input validation
- Anti-spam & duplicate prevention (updating existing report vs. count inflation)
- `CrowdEngineService` weighted consensus calculation
- Honest `INSUFFICIENT_DATA` response when reports fall below threshold
- Coach-wise crowd response and distribution calculation
- Travel alternatives response

### Frontend Code Quality & Tests
```powershell
cd frontend
flutter analyze
flutter test
```
- **Static Analysis**: 0 warnings, 0 errors.
- **Widget Test**: Passes smoke test and verifies core component rendering.

---

## 10. Privacy & Legal Compliance

TrainBuddy is architected in accordance with principles of the Indian **Digital Personal Data Protection (DPDP) Act**:
- **Purpose Limitation**: Location permissions are requested only for journey corridor verification.
- **Data Minimization**: Coordinates are processed solely to verify proximity to route stations and are never published or shared.
- **No Individual Tracking**: No passenger map displays individual user coordinates.
- **Explicit Consent**: GPS validation requires explicit opt-in and can be deactivated with a single tap.

---

## 11. Troubleshooting

1. **Backend connection error in Flutter Web (`Failed to fetch` or `XMLHttpRequest error`)**:
   - Ensure the Django server is running on `http://127.0.0.1:8000`.
   - Verify `CORS_ALLOW_ALL_ORIGINS = True` is active in `backend/.env`.
2. **PostgreSQL connection refused**:
   - Keep `USE_SQLITE=True` in `.env` for zero-configuration local demonstration, or ensure your PostgreSQL service is running on port 5432.
3. **Port 8000 already in use**:
   - Start Django on an alternate port: `python manage.py runserver 127.0.0.1:8080`.
   - Update `baseUrl` in `frontend/lib/core/constants/api_constants.dart` or via Profile settings.
