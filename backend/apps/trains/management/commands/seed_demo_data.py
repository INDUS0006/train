import random
from datetime import time, timedelta, date
from django.core.management.base import BaseCommand
from django.utils import timezone
from apps.accounts.models import User
from apps.stations.models import Station
from apps.trains.models import Train, TrainStop, Coach, CoachType, SavedTrain
from apps.crowd_reports.models import CrowdReport, CrowdLevel, ReportSource
from apps.crowd_engine.services import CrowdEngineService
from apps.alternatives.models import TravelAlternative, AlternativeType
from apps.notifications.models import InAppNotification, NotificationType


class Command(BaseCommand):
    help = 'Seeds extensive realistic demonstration data for TrainBuddy MVP presentation.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--reset',
            action='store_true',
            help='Wipes existing demo records before reseeding.',
        )

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("--- Starting Extensive TrainBuddy Demo Seeder ---"))

        if options.get('reset'):
            self.stdout.write("Resetting existing demo records...")
            CrowdReport.objects.all().delete()
            TravelAlternative.objects.all().delete()
            InAppNotification.objects.all().delete()
            TrainStop.objects.all().delete()
            Coach.objects.all().delete()
            SavedTrain.objects.all().delete()
            Train.objects.all().delete()
            Station.objects.all().delete()

        today = timezone.localdate()
        date_window = [today + timedelta(days=d) for d in range(-2, 4)]  # 6 days of demo coverage

        # 1. Create Demo Users
        self.stdout.write("Creating demo accounts...")
        admin_user, _ = User.objects.get_or_create(
            email='admin@trainbuddy.demo',
            defaults={
                'username': 'train_admin',
                'first_name': 'System',
                'last_name': 'Admin',
                'is_staff': True,
                'is_superuser': True,
            }
        )
        admin_user.set_password('TrainBuddy@2026')
        admin_user.save()

        demo_user, _ = User.objects.get_or_create(
            email='rahul@trainbuddy.demo',
            defaults={
                'username': 'rahul_passenger',
                'first_name': 'Rahul',
                'last_name': 'Sharma',
                'location_sharing_enabled': True,
            }
        )
        demo_user.set_password('TrainBuddy@2026')
        demo_user.save()

        user_priya, _ = User.objects.get_or_create(
            email='priya@trainbuddy.demo',
            defaults={
                'username': 'priya_commuter',
                'first_name': 'Priya',
                'last_name': 'Reddy',
                'location_sharing_enabled': False,
            }
        )
        user_priya.set_password('TrainBuddy@2026')
        user_priya.save()

        guest_user, _ = User.objects.get_or_create(
            email='guest_demo@trainbuddy.demo',
            defaults={
                'username': 'guest_demo',
                'first_name': 'Guest',
                'last_name': 'Passenger',
                'is_guest': True,
            }
        )
        guest_user.set_password('TrainBuddy@2026')
        guest_user.save()

        # 2. Comprehensive Station Network
        self.stdout.write("Creating comprehensive railway stations...")
        stations_data = [
            {'code': 'HYB', 'name': 'Hyderabad Deccan', 'city': 'Hyderabad', 'state': 'Telangana', 'lat': 17.3926, 'lon': 78.4682},
            {'code': 'SC', 'name': 'Secunderabad Junction', 'city': 'Secunderabad', 'state': 'Telangana', 'lat': 17.4334, 'lon': 78.5042},
            {'code': 'KZJ', 'name': 'Kazipet Junction', 'city': 'Kazipet', 'state': 'Telangana', 'lat': 17.9806, 'lon': 79.5204},
            {'code': 'WL', 'name': 'Warangal', 'city': 'Warangal', 'state': 'Telangana', 'lat': 17.9689, 'lon': 79.5941},
            {'code': 'MABD', 'name': 'Mahbubabad', 'city': 'Mahbubabad', 'state': 'Telangana', 'lat': 17.5985, 'lon': 79.9984},
            {'code': 'DKJ', 'name': 'Dornakal Junction', 'city': 'Dornakal', 'state': 'Telangana', 'lat': 17.4527, 'lon': 80.1472},
            {'code': 'KMT', 'name': 'Khammam', 'city': 'Khammam', 'state': 'Telangana', 'lat': 17.2473, 'lon': 80.1514},
            {'code': 'BZA', 'name': 'Vijayawada Junction', 'city': 'Vijayawada', 'state': 'Andhra Pradesh', 'lat': 16.5186, 'lon': 80.6198},
            {'code': 'EE', 'name': 'Eluru', 'city': 'Eluru', 'state': 'Andhra Pradesh', 'lat': 16.7107, 'lon': 81.0952},
            {'code': 'RJY', 'name': 'Rajahmundry', 'city': 'Rajahmundry', 'state': 'Andhra Pradesh', 'lat': 17.0005, 'lon': 81.7820},
            {'code': 'SLO', 'name': 'Samalkot Junction', 'city': 'Samalkot', 'state': 'Andhra Pradesh', 'lat': 17.0506, 'lon': 82.1691},
            {'code': 'VSKP', 'name': 'Visakhapatnam Junction', 'city': 'Visakhapatnam', 'state': 'Andhra Pradesh', 'lat': 17.7231, 'lon': 83.2906},
            {'code': 'TPTY', 'name': 'Tirupati', 'city': 'Tirupati', 'state': 'Andhra Pradesh', 'lat': 13.6288, 'lon': 79.4192},
            {'code': 'MAS', 'name': 'Chennai Central', 'city': 'Chennai', 'state': 'Tamil Nadu', 'lat': 13.0827, 'lon': 80.2707},
            {'code': 'SBC', 'name': 'KSR Bengaluru', 'city': 'Bengaluru', 'state': 'Karnataka', 'lat': 12.9784, 'lon': 77.5694},
            {'code': 'NDLS', 'name': 'New Delhi', 'city': 'New Delhi', 'state': 'Delhi', 'lat': 28.6429, 'lon': 77.2195},
            {'code': 'CNB', 'name': 'Kanpur Central', 'city': 'Kanpur', 'state': 'Uttar Pradesh', 'lat': 26.4547, 'lon': 80.3507},
            {'code': 'BSB', 'name': 'Varanasi Junction', 'city': 'Varanasi', 'state': 'Uttar Pradesh', 'lat': 25.3283, 'lon': 82.9866},
            {'code': 'MMCT', 'name': 'Mumbai Central', 'city': 'Mumbai', 'state': 'Maharashtra', 'lat': 18.9696, 'lon': 72.8193},
            {'code': 'PUNE', 'name': 'Pune Junction', 'city': 'Pune', 'state': 'Maharashtra', 'lat': 18.5289, 'lon': 73.8744},
        ]

        stations = {}
        for s_data in stations_data:
            st, _ = Station.objects.update_or_create(
                station_code=s_data['code'],
                defaults={
                    'station_name': s_data['name'],
                    'city': s_data['city'],
                    'state': s_data['state'],
                    'latitude': s_data['lat'],
                    'longitude': s_data['lon'],
                }
            )
            stations[s_data['code']] = st

        # 3. Extensive Train Catalog
        self.stdout.write("Creating rich train routes & schedules...")
        trains_data = [
            {
                'number': '12723',
                'name': 'Godavari Express (Demonstration Record)',
                'from': 'HYB',
                'to': 'VSKP',
                'dept': time(17, 15),
                'arr': time(5, 45),
                'duration': 12.5,
                'stops': [
                    ('HYB', time(17, 15), time(17, 15), 0, 0),
                    ('SC', time(17, 35), time(17, 40), 10, 5),
                    ('KZJ', time(19, 38), time(19, 40), 142, 2),
                    ('WL', time(19, 53), time(19, 55), 152, 2),
                    ('MABD', time(20, 39), time(20, 40), 212, 1),
                    ('DKJ', time(20, 59), time(21, 0), 237, 1),
                    ('KMT', time(21, 18), time(21, 20), 260, 2),
                    ('BZA', time(23, 15), time(23, 30), 350, 15),
                    ('EE', time(0, 23), time(0, 25), 410, 2),
                    ('RJY', time(1, 48), time(1, 50), 499, 2),
                    ('SLO', time(2, 38), time(2, 40), 549, 2),
                    ('VSKP', time(5, 45), time(5, 45), 698, 0),
                ]
            },
            {
                'number': '20834',
                'name': 'Vande Bharat Express (Demonstration Record)',
                'from': 'SC',
                'to': 'VSKP',
                'dept': time(15, 0),
                'arr': time(23, 30),
                'duration': 8.5,
                'stops': [
                    ('SC', time(15, 0), time(15, 0), 0, 0),
                    ('WL', time(16, 30), time(16, 32), 142, 2),
                    ('KMT', time(17, 45), time(17, 46), 250, 1),
                    ('BZA', time(19, 0), time(19, 5), 340, 5),
                    ('RJY', time(20, 58), time(21, 0), 490, 2),
                    ('SLO', time(21, 40), time(21, 42), 540, 2),
                    ('VSKP', time(23, 30), time(23, 30), 690, 0),
                ]
            },
            {
                'number': '12727',
                'name': 'Visakhapatnam Express (Demonstration Record)',
                'from': 'HYB',
                'to': 'VSKP',
                'dept': time(22, 15),
                'arr': time(10, 25),
                'duration': 12.1,
                'stops': [
                    ('HYB', time(22, 15), time(22, 15), 0, 0),
                    ('SC', time(22, 40), time(22, 45), 10, 5),
                    ('KZJ', time(0, 48), time(0, 50), 142, 2),
                    ('WL', time(1, 3), time(1, 5), 152, 2),
                    ('KMT', time(2, 28), time(2, 30), 260, 2),
                    ('BZA', time(4, 25), time(4, 40), 350, 15),
                    ('RJY', time(6, 58), time(7, 0), 499, 2),
                    ('VSKP', time(10, 25), time(10, 25), 698, 0),
                ]
            },
            {
                'number': '12760',
                'name': 'Charminar Superfast Express (Demonstration Record)',
                'from': 'HYB',
                'to': 'BZA',
                'dept': time(18, 0),
                'arr': time(23, 50),
                'duration': 5.8,
                'stops': [
                    ('HYB', time(18, 0), time(18, 0), 0, 0),
                    ('SC', time(18, 20), time(18, 25), 10, 5),
                    ('KZJ', time(20, 28), time(20, 30), 142, 2),
                    ('WL', time(20, 43), time(20, 45), 152, 2),
                    ('KMT', time(22, 10), time(22, 12), 260, 2),
                    ('BZA', time(23, 50), time(23, 50), 350, 0),
                ]
            },
            {
                'number': '12714',
                'name': 'Satavahana Express (Demonstration Record)',
                'from': 'SC',
                'to': 'BZA',
                'dept': time(16, 25),
                'arr': time(22, 15),
                'duration': 5.8,
                'stops': [
                    ('SC', time(16, 25), time(16, 25), 0, 0),
                    ('KZJ', time(18, 18), time(18, 20), 132, 2),
                    ('WL', time(18, 33), time(18, 35), 142, 2),
                    ('MABD', time(19, 14), time(19, 15), 202, 1),
                    ('DKJ', time(19, 39), time(19, 40), 227, 1),
                    ('KMT', time(20, 8), time(20, 10), 250, 2),
                    ('BZA', time(22, 15), time(22, 15), 340, 0),
                ]
            },
            {
                'number': '17210',
                'name': 'Seshadri Express (Demonstration Record)',
                'from': 'HYB',
                'to': 'BZA',
                'dept': time(6, 0),
                'arr': time(11, 45),
                'duration': 5.75,
                'stops': [
                    ('HYB', time(6, 0), time(6, 0), 0, 0),
                    ('SC', time(6, 20), time(6, 25), 10, 5),
                    ('KZJ', time(8, 28), time(8, 30), 142, 2),
                    ('WL', time(8, 43), time(8, 45), 152, 2),
                    ('KMT', time(10, 8), time(10, 10), 260, 2),
                    ('BZA', time(11, 45), time(11, 45), 350, 0),
                ]
            },
            {
                'number': '12952',
                'name': 'Mumbai Rajdhani Express (Demonstration Record)',
                'from': 'MMCT',
                'to': 'NDLS',
                'dept': time(17, 0),
                'arr': time(8, 35),
                'duration': 15.5,
                'stops': [
                    ('MMCT', time(17, 0), time(17, 0), 0, 0),
                    ('NDLS', time(8, 35), time(8, 35), 1384, 0),
                ]
            },
            {
                'number': '22436',
                'name': 'Vande Bharat Express (Demonstration Record)',
                'from': 'NDLS',
                'to': 'BSB',
                'dept': time(6, 0),
                'arr': time(14, 0),
                'duration': 8.0,
                'stops': [
                    ('NDLS', time(6, 0), time(6, 0), 0, 0),
                    ('CNB', time(10, 8), time(10, 10), 440, 2),
                    ('BSB', time(14, 0), time(14, 0), 759, 0),
                ]
            },
            {
                'number': '12658',
                'name': 'Chennai Mail (Demonstration Record)',
                'from': 'SBC',
                'to': 'MAS',
                'dept': time(22, 40),
                'arr': time(4, 15),
                'duration': 5.5,
                'stops': [
                    ('SBC', time(22, 40), time(22, 40), 0, 0),
                    ('MAS', time(4, 15), time(4, 15), 358, 0),
                ]
            }
        ]

        coach_templates_standard = [
            ('GEN1', CoachType.GENERAL, 'General Unreserved (GEN1)', 1),
            ('GEN2', CoachType.GENERAL, 'General Unreserved (GEN2)', 2),
            ('S1', CoachType.SLEEPER, 'Sleeper Class (S1)', 3),
            ('S2', CoachType.SLEEPER, 'Sleeper Class (S2)', 4),
            ('S3', CoachType.SLEEPER, 'Sleeper Class (S3)', 5),
            ('B1', CoachType.AC_3_TIER, 'AC 3 Tier (B1)', 6),
            ('B2', CoachType.AC_3_TIER, 'AC 3 Tier (B2)', 7),
            ('A1', CoachType.AC_2_TIER, 'AC 2 Tier (A1)', 8),
        ]

        coach_templates_vb = [
            ('EC1', CoachType.AC_1_TIER, 'Executive Chair Car (EC1)', 1),
            ('EC2', CoachType.AC_1_TIER, 'Executive Chair Car (EC2)', 2),
            ('C1', CoachType.CHAIR_CAR, 'AC Chair Car (C1)', 3),
            ('C2', CoachType.CHAIR_CAR, 'AC Chair Car (C2)', 4),
            ('C3', CoachType.CHAIR_CAR, 'AC Chair Car (C3)', 5),
            ('C4', CoachType.CHAIR_CAR, 'AC Chair Car (C4)', 6),
            ('C5', CoachType.CHAIR_CAR, 'AC Chair Car (C5)', 7),
            ('C6', CoachType.CHAIR_CAR, 'AC Chair Car (C6)', 8),
        ]

        created_trains = {}

        for t_info in trains_data:
            train, _ = Train.objects.update_or_create(
                train_number=t_info['number'],
                defaults={
                    'train_name': t_info['name'],
                    'source_station': stations[t_info['from']],
                    'destination_station': stations[t_info['to']],
                    'departure_time': t_info['dept'],
                    'arrival_time': t_info['arr'],
                    'duration_hours': t_info['duration'],
                    'runs_on_days': 'Daily',
                    'is_active': True,
                    'is_demo_data': True,
                }
            )
            created_trains[t_info['number']] = train

            # Add stops
            TrainStop.objects.filter(train=train).delete()
            for idx, (st_code, arr, dept, dist, halt) in enumerate(t_info['stops'], start=1):
                TrainStop.objects.create(
                    train=train,
                    station=stations[st_code],
                    stop_order=idx,
                    arrival_time=arr,
                    departure_time=dept,
                    distance_km=dist,
                    halt_minutes=halt
                )

            # Add coaches
            Coach.objects.filter(train=train).delete()
            tpl = coach_templates_vb if 'Vande Bharat' in train.train_name else coach_templates_standard
            for c_num, c_type, c_lbl, pos in tpl:
                Coach.objects.create(
                    train=train,
                    coach_number=c_num,
                    coach_type=c_type,
                    coach_label=c_lbl,
                    position=pos
                )

        # 4. Generate Crowd Demonstration Reports for ALL trains across date window
        self.stdout.write("Generating coach-level crowd demonstration reports across 5-day window...")
        now = timezone.now()
        users_pool = [demo_user, user_priya, guest_user, None]

        # Specifications for each train's crowd profile
        profiles = {
            '12723': {  # Godavari - High crowd
                'GEN1': (CrowdLevel.VERY_HIGH, 'Severe rush! Impossible to board general bogie.', 5),
                'GEN2': (CrowdLevel.VERY_HIGH, 'Overflowing with waitlist commuters.', 4),
                'S1': (CrowdLevel.HIGH, 'Coach is packed with waiting list passengers.', 5),
                'S2': (CrowdLevel.MEDIUM, 'Moderate rush, confirmed seats occupied.', 4),
                'S3': (CrowdLevel.HIGH, 'Doorways crowded, aisle blocked.', 4),
                'B1': (CrowdLevel.LOW, 'Peaceful AC coach, clean and spacious.', 3),
                'B2': (CrowdLevel.HIGH, 'Rush in 3A today with extra passengers.', 4),
                'A1': (CrowdLevel.LOW, 'Comfortable 2-tier coach, uncrowded.', 3),
            },
            '20834': {  # Vande Bharat - Low / Premium crowd
                'EC1': (CrowdLevel.LOW, 'Spacious executive luxury class, quiet journey.', 4),
                'EC2': (CrowdLevel.LOW, 'Pristine coach condition, no standing allowed.', 3),
                'C1': (CrowdLevel.LOW, 'Comfortable chair car with plenty of leg room.', 4),
                'C2': (CrowdLevel.LOW, 'Smooth travel, all reserved seats filled.', 3),
                'C3': (CrowdLevel.MEDIUM, 'Slight rush in middle car, but seats confirmed.', 4),
                'C4': (CrowdLevel.LOW, 'Very clean and quiet.', 3),
                'C5': (CrowdLevel.LOW, 'Comfortable AC temperature and light crowd.', 3),
                'C6': (CrowdLevel.LOW, 'Smooth onboarding at Secunderabad.', 3),
            },
            '12727': {  # Visakhapatnam Express - Medium crowd
                'GEN1': (CrowdLevel.HIGH, 'Heavy rush near the general entrance.', 4),
                'GEN2': (CrowdLevel.HIGH, 'General compartment congested.', 4),
                'S1': (CrowdLevel.MEDIUM, 'Manageable crowding in sleeper bay.', 4),
                'S2': (CrowdLevel.MEDIUM, 'Standard overnight rush, berths full.', 4),
                'S3': (CrowdLevel.MEDIUM, 'Normal passenger flow.', 3),
                'B1': (CrowdLevel.LOW, 'Very pleasant 3-tier travel.', 3),
                'B2': (CrowdLevel.MEDIUM, 'All 3A berths occupied, calm atmosphere.', 3),
                'A1': (CrowdLevel.LOW, '2A coach is quiet and spacious.', 3),
            },
            '12760': {  # Charminar - High crowd
                'GEN1': (CrowdLevel.VERY_HIGH, 'Extreme rush, passengers standing near washrooms.', 5),
                'GEN2': (CrowdLevel.VERY_HIGH, 'Unreserved coach heavily packed.', 4),
                'S1': (CrowdLevel.HIGH, 'Sleeper aisle crowded, heavy luggage.', 4),
                'S2': (CrowdLevel.HIGH, 'Doorways crowded during halts.', 4),
                'S3': (CrowdLevel.MEDIUM, 'Berths filled, manageable aisle passage.', 3),
                'B1': (CrowdLevel.MEDIUM, 'AC coach comfortable with confirmed berths.', 3),
                'B2': (CrowdLevel.HIGH, 'Heavy booking on 3A today.', 4),
                'A1': (CrowdLevel.LOW, 'Uncrowded 2-tier coach.', 3),
            },
            '12714': {  # Satavahana - Medium intercity crowd
                'GEN1': (CrowdLevel.HIGH, 'Office commuters crowding general coaches.', 4),
                'GEN2': (CrowdLevel.HIGH, 'Heavy day commuter boarding.', 4),
                'S1': (CrowdLevel.MEDIUM, 'Fairly busy daytime intercity run.', 4),
                'S2': (CrowdLevel.MEDIUM, 'All seats occupied, aisle clear.', 3),
                'S3': (CrowdLevel.LOW, 'Steady comfortable travel.', 3),
                'B1': (CrowdLevel.LOW, 'Cool and pleasant AC chair travel.', 3),
                'B2': (CrowdLevel.LOW, 'Spacious AC cabin.', 3),
                'A1': (CrowdLevel.LOW, 'Very uncrowded coach.', 3),
            },
            '17210': {  # Seshadri - Low to Medium crowd
                'GEN1': (CrowdLevel.MEDIUM, 'Moderate passenger load today.', 3),
                'GEN2': (CrowdLevel.MEDIUM, 'Steady general crowd.', 3),
                'S1': (CrowdLevel.LOW, 'Comfortable sleeper experience.', 3),
                'S2': (CrowdLevel.LOW, 'Less rush on this early morning departure.', 3),
                'S3': (CrowdLevel.LOW, 'Quiet sleeper coach.', 3),
                'B1': (CrowdLevel.LOW, 'Very relaxed AC coach.', 3),
                'B2': (CrowdLevel.LOW, 'Ample personal space.', 3),
                'A1': (CrowdLevel.LOW, 'Peaceful travel.', 3),
            },
            '12952': {  # Mumbai Rajdhani - Low / Premium
                'GEN1': (CrowdLevel.LOW, 'Strictly reserved train, no unreserved crowd.', 3),
                'GEN2': (CrowdLevel.LOW, 'Confirmed ticket holders only.', 3),
                'S1': (CrowdLevel.LOW, 'Rajdhani speed and comfort.', 3),
                'S2': (CrowdLevel.LOW, 'Punctual and spacious.', 3),
                'S3': (CrowdLevel.LOW, 'High quality travel experience.', 3),
                'B1': (CrowdLevel.LOW, 'Quiet AC 3-Tier coach.', 3),
                'B2': (CrowdLevel.LOW, 'Clean corridor and beds.', 3),
                'A1': (CrowdLevel.LOW, 'Spacious 2-Tier cabin.', 3),
            },
            '22436': {  # Vande Bharat NDLS-BSB
                'EC1': (CrowdLevel.LOW, 'First-class luxury, quiet cabin.', 3),
                'EC2': (CrowdLevel.LOW, 'Attentive service and low crowd.', 3),
                'C1': (CrowdLevel.MEDIUM, 'Chair car filled with pilgrims & tourists.', 4),
                'C2': (CrowdLevel.MEDIUM, 'Active passenger movement.', 3),
                'C3': (CrowdLevel.LOW, 'Comfortable journey.', 3),
                'C4': (CrowdLevel.LOW, 'Quiet afternoon ride.', 3),
                'C5': (CrowdLevel.LOW, 'Pleasant travel.', 3),
                'C6': (CrowdLevel.LOW, 'Quick boarding at Kanpur.', 3),
            },
            '12658': {  # Chennai Mail
                'GEN1': (CrowdLevel.HIGH, 'Bangalore to Chennai weekend crowd.', 4),
                'GEN2': (CrowdLevel.HIGH, 'Heavy rush in unreserved section.', 4),
                'S1': (CrowdLevel.MEDIUM, 'Overnight commuters sleeping peacefully.', 3),
                'S2': (CrowdLevel.MEDIUM, 'Confirmed berths occupied.', 3),
                'S3': (CrowdLevel.MEDIUM, 'Normal passenger flow.', 3),
                'B1': (CrowdLevel.LOW, 'Clean AC coach.', 3),
                'B2': (CrowdLevel.LOW, 'Quiet night ride.', 3),
                'A1': (CrowdLevel.LOW, 'Comfortable 2A coach.', 3),
            }
        }

        # Seed reports for every date in date_window
        for d in date_window:
            for tr_num, coach_profile in profiles.items():
                train_obj = created_trains.get(tr_num)
                if not train_obj:
                    continue
                coaches_dict = {c.coach_number: c for c in train_obj.coaches.all()}

                for c_num, (level, comment, count) in coach_profile.items():
                    coach_obj = coaches_dict.get(c_num)
                    for i in range(count):
                        report_time = now - timedelta(hours=random.uniform(0.5, 10.0))
                        rep = CrowdReport.objects.create(
                            user=random.choice(users_pool),
                            train=train_obj,
                            journey_date=d,
                            coach=coach_obj,
                            crowd_level=level,
                            comment=comment,
                            latitude=train_obj.source_station.latitude + random.uniform(-0.01, 0.01),
                            longitude=train_obj.source_station.longitude + random.uniform(-0.01, 0.01),
                            gps_accuracy=random.uniform(8.0, 30.0),
                            report_source=ReportSource.GPS_VERIFIED if random.random() > 0.3 else ReportSource.DEMO,
                            is_valid=True
                        )
                        CrowdReport.objects.filter(id=rep.id).update(created_at=report_time)

        # 5. Compute Estimates via CrowdEngineService for ALL trains & dates
        self.stdout.write("Computing crowd estimations across all trains & dates...")
        for tr in created_trains.values():
            for d in date_window:
                CrowdEngineService.recompute_train_and_coaches(tr, d)

        # 6. Create Travel Alternatives for Godavari (12723) and other trains
        self.stdout.write("Creating travel alternatives...")
        godavari = created_trains['12723']
        TravelAlternative.objects.filter(train=godavari).delete()
        alternatives_data = [
            {
                'train': godavari,
                'type': AlternativeType.TRAIN,
                'title': '20834 – Vande Bharat Express (Faster & Less Crowded)',
                'operator': 'Indian Railways',
                'dept': time(15, 0),
                'arr': time(23, 30),
                'duration': '8 hrs 30 mins',
                'crowd': 'LOW',
                'fare': '₹1,420 (CC) / ₹2,630 (EC)',
                'note': 'Fastest daytime executive connectivity with low crowd'
            },
            {
                'train': godavari,
                'type': AlternativeType.TRAIN,
                'title': '12727 – Visakhapatnam Express (Later Departure)',
                'operator': 'Indian Railways',
                'dept': time(22, 15),
                'arr': time(10, 25),
                'duration': '12 hrs 10 mins',
                'crowd': 'MEDIUM',
                'fare': '₹395 (SL) / ₹1,050 (3A)',
                'note': 'Demonstration option – overnight departure with lower coach density'
            },
            {
                'train': godavari,
                'type': AlternativeType.BUS,
                'title': 'TSRTC Garuda Plus AC Multi-Axle Bus',
                'operator': 'Telangana State RTC',
                'dept': time(18, 30),
                'arr': time(23, 45),
                'duration': '5 hrs 15 mins to Vijayawada',
                'crowd': 'LOW',
                'fare': '₹650',
                'note': 'Express highway Volvo coach with reserved reclining seats'
            },
            {
                'train': godavari,
                'type': AlternativeType.CAB,
                'title': 'Highway Intercity Shared Cab (ORR Junction)',
                'operator': 'Ola Outstation / Uber Intercity',
                'dept': time(17, 45),
                'arr': time(22, 30),
                'duration': '4 hrs 45 mins to Vijayawada',
                'crowd': 'LOW',
                'fare': '₹900 / seat (Shared) / ₹3,800 (Sedan)',
                'note': 'Point-to-point AC sedan highway travel'
            }
        ]

        for alt in alternatives_data:
            TravelAlternative.objects.create(
                train=alt['train'],
                alternative_type=alt['type'],
                title=alt['title'],
                operator=alt['operator'],
                departure_time=alt['dept'],
                arrival_time=alt['arr'],
                duration_text=alt['duration'],
                crowd_level=alt['crowd'],
                fare_estimate=alt['fare'],
                source_note=alt['note'],
                is_demo=True
            )

        # 7. Create In-App Notifications
        self.stdout.write("Creating demonstration notifications...")
        InAppNotification.objects.create(
            user=demo_user,
            title='High Crowd Alert: Train 12723 (Godavari Exp)',
            message='Coaches S1, S3 and GEN1 are reporting high passenger volumes today. AC coaches (B1, A1) and Vande Bharat 20834 have lower crowd levels.',
            notification_type=NotificationType.CROWD_UPDATE,
            train=godavari,
            is_read=False
        )
        InAppNotification.objects.create(
            user=demo_user,
            title='Journey Notice: Hyderabad to Vijayawada Corridor',
            message='Crowd information is active for 6 trains today. Check coach-wise availability before boarding.',
            notification_type=NotificationType.JOURNEY_REMINDER,
            train=godavari,
            is_read=False
        )
        InAppNotification.objects.create(
            user=None,  # Broadcast
            title='Welcome to TrainBuddy Demo',
            message='Know the train. Know the crowd. Choose how to travel. All records are clearly marked demonstration data.',
            notification_type=NotificationType.SYSTEM_NOTICE,
            is_read=False
        )

        # Bookmark Godavari for demo_user
        SavedTrain.objects.get_or_create(user=demo_user, train=godavari)

        self.stdout.write(self.style.SUCCESS("✓ Successfully seeded extensive TrainBuddy demonstration records!"))
        self.stdout.write(self.style.SUCCESS("  Demo accounts:"))
        self.stdout.write("  - Admin: admin@trainbuddy.demo / TrainBuddy@2026")
        self.stdout.write("  - Demo Passenger: rahul@trainbuddy.demo / TrainBuddy@2026")
        self.stdout.write("  - Commuter: priya@trainbuddy.demo / TrainBuddy@2026")
        self.stdout.write("  - Guest Demo available via /api/auth/guest-login/")
