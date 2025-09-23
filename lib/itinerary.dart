import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'geolocator_page.dart';

class ItineraryPage extends StatelessWidget {
  final List<String> places;

  const ItineraryPage({super.key, required this.places});

  static final Map<String, LatLng> demoCoords = {
    "Gangtok": LatLng(27.3389, 88.6065),
    "Mangan": LatLng(27.4906, 88.5941),
    "Lachen": LatLng(27.7159, 88.7264),
    "North Sikkim": LatLng(27.6246, 88.6995),
  };

  @override
  Widget build(BuildContext context) {
    final routeOrder = ["Gangtok", "Mangan", "Lachen", "North Sikkim"];
    final polylinePoints = routeOrder.map((p) => demoCoords[p]!).toList();

    final List<Marker> markers = List.generate(routeOrder.length, (index) {
      final place = routeOrder[index];
      return Marker(
        point: demoCoords[place]!,
        width: 40,
        height: 40,
        builder: (ctx) => Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.location_pin,
              size: 40,
              color: Colors.blueAccent,
            ),
            Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                shadows: [
                  Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(0, 1))
                ],
              ),
            ),
          ],
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinerary Map"),
        backgroundColor: const Color(0xFFA5D6A7),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              center: demoCoords["Gangtok"],
              zoom: 9,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourdomain.rakshakapp',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color: Colors.blueAccent,
                    strokeWidth: 6,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LocationTrackerHome(),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Text(
                      'Geolocator',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
