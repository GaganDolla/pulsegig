import 'package:flutter/material.dart';
import 'clinic_shifts_screen.dart';
import 'clinic_post_job_screen.dart';
import 'clinic_profile_screen.dart';
import '../messages_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Home Dashboard - To be implemented'));
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('More Screen - To be implemented'));
  }
}


/// The main dashboard for Clinic users, with bottom navigation.
class ClinicDashboardScreen extends StatefulWidget {
  static const routeName = '/clinic-dashboard';
  const ClinicDashboardScreen({Key? key}) : super(key: key);

  @override
  _ClinicDashboardScreenState createState() => _ClinicDashboardScreenState();
}

class _ClinicDashboardScreenState extends State<ClinicDashboardScreen> {
  int _currentIndex = 0;

  // The tabs displayed in the dashboard
  static const List<Widget> _tabs = [
    HomeDashboardScreen(),     // New dashboard summary screen (to be implemented)
    ClinicShiftsScreen(),      // Shifts list
    MessagesScreen(),          // In-app communications
    MoreScreen(),              // Settings, profile, billing
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Shifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ClinicPostJobScreen()),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Post Shift',
      ),
    );
  }
}