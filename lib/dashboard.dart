import 'package:flutter/material.dart';
import 'sos_alert_page.dart';
import 'registration_page.dart'; // Import SimpleEmergencyContact model

class DashboardPage extends StatelessWidget {
  final String userName;
  final List<SimpleEmergencyContact> emergencyContacts;

  const DashboardPage({super.key, required this.userName, required this.emergencyContacts});

  @override
  Widget build(BuildContext context) {
    const double score = 78; // Dummy static safety score

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/image.jpeg',
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Score Display
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 150,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 15,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent.shade400),
                          ),
                        ),
                        Text(
                          '$score%',
                          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Your Tourist Safety Score',
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 45),

                  // Dashboard buttons
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
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
                            // TODO: Implement view alert history
                          },
                        ),
                        _dashboardButton(
                          icon: Icons.map_outlined,
                          label: 'Itinerary',
                          color: Colors.blueAccent,
                          onTap: () {
                            // TODO: Implement show trip itinerary
                          },
                        ),
                        _dashboardButton(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          color: Colors.purpleAccent,
                          onTap: () {
                            // TODO: Implement user profile & info
                          },
                        ),
                        _dashboardButton(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          color: Colors.tealAccent,
                          onTap: () {
                            // TODO: Implement app preferences & language
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      color: color.withOpacity(0.7),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 18),
              Text(label,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
