import 'package:flutter/material.dart';

class ClinicProfileScreen extends StatelessWidget {
  const ClinicProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mockClinic = {
      'name': 'Downtown Primary Care Clinic',
      'type': 'Primary Care Clinic',
      'location': 'Toronto, ON',
      'description': 'A walk-in and family care clinic offering comprehensive medical services.',
      'services': ['General Checkup', 'Pediatrics', 'Vaccinations'],
      'equipment': ['X-Ray', 'Ultrasound'],
      'roles': ['Doctor', 'Nurse', 'Receptionist'],
      'hours': 'Mon–Fri, 9 AM – 5 PM',
      'capacity': '6 rooms',
      'accreditation': 'Ontario Health Accredited',
      'safetyProtocol': true,
      'contact': 'Jane Doe – Clinic Manager',
      'software': 'Accuro EMR',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Clinic Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
              icon: Icons.info_outline,
              title: 'Clinic Overview',
              children: [
                _infoTile('Name', mockClinic['name'] as String),
                _infoTile('Type', mockClinic['type'] as String),
                _infoTile('Location', mockClinic['location'] as String),
                _infoTile('Contact', mockClinic['contact'] as String),
                _infoTile('About', mockClinic['description'] as String),
              ],
            ),
            _buildCard(
              icon: Icons.schedule,
              title: 'Operations',
              children: [
                _infoTile('Operational Hours', mockClinic['hours'] as String),
                _infoTile('Number of Rooms', mockClinic['capacity'] as String),
                _infoTile('Accreditation', mockClinic['accreditation'] as String),
                _infoTile('Safety Protocols', (mockClinic['safetyProtocol'] as bool) ? 'Yes' : 'No'),
              ],
            ),
            _buildCard(
              icon: Icons.medical_services,
              title: 'Services',
              children: [
                _tagList(mockClinic['services'] as List<String>),
              ],
            ),
            _buildCard(
              icon: Icons.devices_other,
              title: 'Available Equipment',
              children: [
                _tagList(mockClinic['equipment'] as List<String>),
              ],
            ),
            _buildCard(
              icon: Icons.group,
              title: 'Staff Roles',
              children: [
                _tagList(mockClinic['roles'] as List<String>),
              ],
            ),
            _buildCard(
              icon: Icons.computer,
              title: 'Software & Tools',
              children: [
                _infoTile('EMR Software', mockClinic['software'] as String),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required List<Widget> children}) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.blueAccent),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.blueAccent),
            SizedBox(width: 8),
          ],
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value ?? 'Not specified'),
    );
  }

  Widget _tagList(List<String> tags) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) => Chip(
        label: Text(tag),
        backgroundColor: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      )).toList(),
    );
  }
}
