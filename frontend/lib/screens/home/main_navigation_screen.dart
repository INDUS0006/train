import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/notification_provider.dart';
import 'home_dashboard_screen.dart';
import '../search/train_search_results_screen.dart';
import '../route/live_route_status_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final notifProv = Provider.of<NotificationProvider>(context);

    final screens = [
      const HomeDashboardScreen(),
      TrainSearchResultsScreen(
        fromCode: 'HYB',
        toCode: 'BZA',
        journeyDate: DateTime.now(),
      ),
      const LiveRouteStatusScreen(),
      const NotificationsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.white,
        elevation: 4,
        indicatorColor: AppColors.softBlue,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.primaryBlue),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search, color: AppColors.primaryBlue),
            label: 'Trains',
          ),
          const NavigationDestination(
            icon: Icon(Icons.alt_route_rounded),
            selectedIcon: Icon(Icons.route_rounded, color: AppColors.primaryBlue),
            label: 'Live Route',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: notifProv.unreadCount > 0,
              label: Text('${notifProv.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: notifProv.unreadCount > 0,
              label: Text('${notifProv.unreadCount}'),
              child: const Icon(Icons.notifications, color: AppColors.primaryBlue),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
