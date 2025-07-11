import 'package:flutter/material.dart';
import 'available_shifts_screen.dart';
import 'my_applications_screen.dart';
import '../messages_screen.dart';
import '../profile_screen.dart';

/// The main dashboard for Professional users, with bottom navigation.
class ProfessionalDashboardScreen extends StatefulWidget {
  static const routeName = '/professional-dashboard';
  const ProfessionalDashboardScreen({Key? key}) : super(key: key);

  @override
  _ProfessionalDashboardScreenState createState() => _ProfessionalDashboardScreenState();
}

class _ProfessionalDashboardScreenState extends State<ProfessionalDashboardScreen> {
  int _currentIndex = 0;

  static const List<Widget> _tabs = [
    AvailableShiftsScreen(),     // Browse open shifts
    MyApplicationsScreen(),      // View your bids/applications
    MessagesScreen(),            // In-app communications
    ProfileScreen(),             // Your profile & settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Applications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}