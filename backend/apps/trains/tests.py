from datetime import time, timedelta
from django.test import TestCase
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from apps.stations.models import Station
from apps.trains.models import Train, Coach, CoachType, TrainStop
from apps.crowd_reports.models import CrowdReport, CrowdLevel, ReportSource
from apps.crowd_engine.services import CrowdEngineService
from apps.alternatives.models import TravelAlternative, AlternativeType


class TrainAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.today = timezone.localdate()

        self.st_hyb = Station.objects.create(
            station_code='HYB', station_name='Hyderabad Deccan', city='Hyderabad',
            latitude=17.3926, longitude=78.4682
        )
        self.st_bza = Station.objects.create(
            station_code='BZA', station_name='Vijayawada Junction', city='Vijayawada',
            latitude=16.5186, longitude=80.6198
        )
        self.train = Train.objects.create(
            train_number='12723',
            train_name='Godavari Express (Demo)',
            source_station=self.st_hyb,
            destination_station=self.st_bza,
            departure_time=time(17, 15),
            arrival_time=time(23, 30),
            duration_hours=6.25,
            is_active=True
        )
        self.coach_s1 = Coach.objects.create(
            train=self.train,
            coach_number='S1',
            coach_type=CoachType.SLEEPER,
            position=1
        )
        self.coach_b1 = Coach.objects.create(
            train=self.train,
            coach_number='B1',
            coach_type=CoachType.AC_3_TIER,
            position=2
        )
        TrainStop.objects.create(
            train=self.train, station=self.st_hyb, stop_order=1,
            arrival_time=time(17, 15), departure_time=time(17, 15)
        )
        TrainStop.objects.create(
            train=self.train, station=self.st_bza, stop_order=2,
            arrival_time=time(23, 30), departure_time=time(23, 30)
        )

        # Alternative option
        TravelAlternative.objects.create(
            train=self.train,
            alternative_type=AlternativeType.BUS,
            title='Express Bus Alternative',
            operator='TSRTC',
            departure_time=time(18, 0),
            arrival_time=time(23, 45),
            duration_text='5 hrs 45 mins',
            crowd_level='LOW',
            is_demo=True
        )

    def test_train_search(self):
        url = reverse('trains:train-search')
        response = self.client.get(url, {'from_code': 'HYB', 'to_code': 'BZA'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['results'][0]['train_number'], '12723')

    def test_train_details(self):
        url = reverse('trains:train-detail', kwargs={'pk': self.train.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['train_number'], '12723')
        self.assertEqual(len(response.data['stops']), 2)
        self.assertEqual(len(response.data['coaches']), 2)

    def test_insufficient_data_response(self):
        # Without reports, crowd level must be INSUFFICIENT_DATA
        url = reverse('crowd_engine:train-crowd', kwargs={'train_id': self.train.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['estimate']['crowd_level'], 'INSUFFICIENT_DATA')
        self.assertEqual(response.data['estimate']['valid_report_count'], 0)

    def test_coach_wise_crowd_response(self):
        # Add 3 reports for coach S1
        for _ in range(3):
            CrowdReport.objects.create(
                train=self.train,
                coach=self.coach_s1,
                journey_date=self.today,
                crowd_level=CrowdLevel.HIGH,
                report_source=ReportSource.MANUAL,
                is_valid=True
            )
        CrowdEngineService.recompute_train_and_coaches(self.train, self.today)

        url = reverse('crowd_engine:coach-crowd', kwargs={'train_id': self.train.id, 'coach_id': self.coach_s1.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['estimate']['crowd_level'], 'HIGH')
        self.assertEqual(response.data['estimate']['valid_report_count'], 3)

    def test_alternative_travel_response(self):
        url = reverse('alternatives:train-alternatives', kwargs={'pk': self.train.id})
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['count'], 1)
        self.assertEqual(response.data['alternatives'][0]['title'], 'Express Bus Alternative')
