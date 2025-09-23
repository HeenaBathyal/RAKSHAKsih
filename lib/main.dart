import 'package:flutter/material.dart';

import 'registration_page.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rakshak',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
      routes: {
        '/registration': (_) => SinglePageRegistration(
          onRegistered: (name, itinerary) {
            Navigator.of(_).pushReplacement(
              MaterialPageRoute(
                builder: (context) => DashboardPage(
                  userName: name,
                  userItinerary: itinerary,
                  emergencyContacts: [],
                ),
              ),
            );
          },
        ),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double cmToPx = 38.0; // approx pixels per cm at 160dpi
    final double topMargin = 3 * cmToPx; // 3cm from top
    final double bottomMargin = 3 * cmToPx; // 3cm from bottom

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/nature.png',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              SizedBox(height: topMargin),
              Image.asset(
                'assets/logo.png',
                height: 140,
                width: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Text(
                'Welcome to Rakshak',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.green.shade900,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                '"Your Adventure, Our Compass"',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Expanded(child: Container()),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomMargin),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/registration'),
                    child: const Text(
                      'Get started',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }}