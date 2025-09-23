import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:geofence_service/geofence_service.dart' as gf;
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';
import 'dart:async';

class LocationTrackerHome extends StatefulWidget {
  const LocationTrackerHome({Key? key}) : super(key: key);

  @override
  State<LocationTrackerHome> createState() => _LocationTrackerHomeState();
}

class _LocationTrackerHomeState extends State<LocationTrackerHome> {
  // Location variables
  double? _currentLatitude;
  double? _currentLongitude;
  String _locationStatus = 'Initializing...';
  StreamSubscription<geo.Position>? _positionStreamSubscription;

  // Geofence variables
  final _geofenceService = gf.GeofenceService.instance.setup(
    interval: 5000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: false,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: gf.GeofenceRadiusSortType.DESC,
  );

  bool _isInHighRiskZone = false;
  String _geofenceStatus = 'hooray!! in safe zone';

  // Define high-risk zone coordinates (example)
  final double _highRiskLatitude = 40.7580;
  final double _highRiskLongitude = -73.9855;
  final double _highRiskRadius = 200.0; // meters

  @override
  void initState() {
    super.initState();
    _initializeLocationServices();
  }

  Future<void> _initializeLocationServices() async {
    await _requestPermissions();
    await _startLocationTracking();
    _initializeGeofence();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.notification,
    ].request();

    if (statuses[Permission.location]!.isGranted) {
      setState(() {
        _locationStatus = 'Location permission granted';
      });
    } else {
      setState(() {
        _locationStatus = 'Location permission denied';
      });
    }

    if (statuses[Permission.locationAlways]!.isGranted) {
      print('Background location permission granted');
    }
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationStatus = 'Location services are disabled';
      });
      return;
    }

    geo.LocationPermission permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        setState(() {
          _locationStatus = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = 'Location permissions are permanently denied';
      });
      return;
    }

    final geo.LocationSettings locationSettings = geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionStreamSubscription = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((geo.Position position) {
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
        _locationStatus = 'Tracking active';
      });

      _checkGeofence(position.latitude, position.longitude);
    });

    try {
      geo.Position position = await geo.Geolocator.getCurrentPosition();
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });
    } catch (e) {
      setState(() {
        _locationStatus = 'Error getting location: $e';
      });
    }
  }

  void _initializeGeofence() {
    final geofence = gf.Geofence(
      id: 'high_risk_zone',
      latitude: _highRiskLatitude,
      longitude: _highRiskLongitude,
      radius: [
        gf.GeofenceRadius(id: 'radius_200m', length: _highRiskRadius),
      ],
    );

    _geofenceService.addGeofence(geofence);
    _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
    _geofenceService.start([geofence]).catchError((error) {
      print('Error starting geofence service: $error');
    });
  }

  Future<void> _onGeofenceStatusChanged(
    gf.Geofence geofence,
    gf.GeofenceRadius geofenceRadius,
    gf.GeofenceStatus geofenceStatus,
    gf.Location location,
  ) async {
    if (geofence.id == 'high_risk_zone') {
      if (geofenceStatus == gf.GeofenceStatus.ENTER) {
        _onEnterHighRiskZone();
      } else if (geofenceStatus == gf.GeofenceStatus.EXIT) {
        _onExitHighRiskZone();
      }
    }
  }

  void _checkGeofence(double lat, double lon) {
    double distance = geo.Geolocator.distanceBetween(
      lat,
      lon,
      _highRiskLatitude,
      _highRiskLongitude,
    );

    bool isInZone = distance <= _highRiskRadius;

    if (isInZone != _isInHighRiskZone) {
      setState(() {
        _isInHighRiskZone = isInZone;
      });

      if (isInZone) {
        _onEnterHighRiskZone();
      } else {
        _onExitHighRiskZone();
      }
    }
  }

  void _onEnterHighRiskZone() {
    setState(() {
      _geofenceStatus = '⚠️ WARNING: HIGH-RISK ZONE!';
      _isInHighRiskZone = true;
    });

    _vibratePhone();
    _showWarningDialog();
  }

  void _onExitHighRiskZone() {
    setState(() {
      _geofenceStatus = '✅ Outside high-risk zone';
      _isInHighRiskZone = false;
    });
  }

  Future<void> _vibratePhone() async {
    if ((await Vibration.hasVibrator()) ?? false) {
      Vibration.vibrate(pattern: [0, 500, 200, 500]);
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red[50],
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('HIGH-RISK ZONE', style: TextStyle(color: Colors.red)),
            ],
          ),
          content: const Text(
            'You have entered a high-risk area. Please be cautious and stay alert!',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'ACKNOWLEDGE',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _geofenceService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
        backgroundColor: _isInHighRiskZone ? Colors.red : Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isInHighRiskZone
                ? [Colors.red[50]!, Colors.red[100]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  color: _isInHighRiskZone ? Colors.red[100] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 48,
                          color: _isInHighRiskZone ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _locationStatus,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isInHighRiskZone
                                ? Colors.red[900]
                                : Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            const Icon(Icons.explore, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              'Latitude: ${_currentLatitude?.toStringAsFixed(6) ?? 'Loading...'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.navigation, color: Colors.orange),
                            const SizedBox(width: 10),
                            Text(
                              'Longitude: ${_currentLongitude?.toStringAsFixed(6) ?? 'Loading...'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  color: _isInHighRiskZone ? Colors.red : Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Geofence Status',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _isInHighRiskZone
                                ? Colors.white
                                : Colors.green[900],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _geofenceStatus,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: _isInHighRiskZone
                                ? Colors.white
                                : Colors.green[800],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'High-Risk Zone Info',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Center: $_highRiskLatitude, $_highRiskLongitude',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Radius: $_highRiskRadius meters',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
