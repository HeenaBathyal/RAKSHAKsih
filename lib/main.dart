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
       theme: ThemeData(primarySwatch: Colors.green),
       home: const WelcomeScreen(),
       routes: {
         // Registration screen route, with callback for post-register navigation
         '/registration': (_) => SinglePageRegistration(
           onRegistered: (name, itinerary) {
             // Navigate to Dashboard page after registration
             Navigator.of(_).pushReplacement(
               MaterialPageRoute(
                 builder: (context) => DashboardPage(
                   userName: name,
                   userItinerary: itinerary, emergencyContacts: [],
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
     return Scaffold(
       body: Stack(
         fit: StackFit.expand,
         children: [
           Image.asset(
             'assets/nature.png', // Welcome screen background
             fit: BoxFit.cover,
           ),
           Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Image.asset('assets/logo.png', height: 100),
               const SizedBox(height: 16),
               const Text('Welcome to', style: TextStyle(fontSize: 22, color: Colors.green)),
               const Text('Rakshak', style: TextStyle(fontSize: 32, color: Colors.green, fontWeight: FontWeight.bold)),
               const SizedBox(height: 8),
               const Text('Your Adventure, Our Compass', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
               const SizedBox(height: 60),
               ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
                   padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                 ),
                 onPressed: () => Navigator.pushNamed(context, '/registration'),
                 child: const Text('Get started', style: TextStyle(fontSize: 18)),
               )
             ],
           ),
         ],
       ),
     );
   }
 }
