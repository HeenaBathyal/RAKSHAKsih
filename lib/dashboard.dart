import 'package:flutter/material.dart';
import 'sos_alert_page.dart';
import 'registration_page.dart';
import 'itinerary.dart';

class DashboardPage extends StatelessWidget {
  final String userName;
  final List<String> userItinerary;
  final List<SimpleEmergencyContact> emergencyContacts;

  const DashboardPage({
    super.key,
    required this.userName,
    required this.emergencyContacts,
    required this.userItinerary,
  });

  @override
  Widget build(BuildContext context) {
    const double score = 78;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF145A32),
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 28, color: Colors.black87),
                    onPressed: () {
                      // TODO: Implement Settings Page Navigation
                    },
                  )
                ],
              ),
              const SizedBox(height: 30),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 160,
                      child: CircularProgressIndicator(
                        value: score / 100,
                        strokeWidth: 15,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                      ),
                    ),
                    Text(
                      '$score%',
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF145A32),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Safety Score',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFF145A32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Space of about 2 cm (typically ~55 logical px on most screens)
              const SizedBox(height: 55),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 26,
                  mainAxisSpacing: 26,
                  childAspectRatio: 1.0,
                  children: [
                    _dashboardButton(
                      icon: Icons.warning_amber_rounded,
                      label: 'Panic Button',
                      color: Colors.redAccent,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SosEmergencyPage(
                              emergencyContacts: emergencyContacts,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardButton(
                      icon: Icons.notifications_active,
                      label: 'Alerts',
                      color: Colors.orangeAccent,
                      onTap: () {
                        // Implement Alerts Page
                      },
                    ),
                    _dashboardButton(
                      icon: Icons.map_outlined,
                      label: 'Itinerary',
                      color: Colors.blueAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItineraryPage(
                              places: userItinerary,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardButton(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      color: Colors.purpleAccent,
                      onTap: () {
                        // Implement Profile Page
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.83),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 58, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
