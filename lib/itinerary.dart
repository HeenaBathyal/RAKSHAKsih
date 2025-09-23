import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

    // Numbered circle markers
    final List<Marker> markers = List.generate(routeOrder.length, (index) {
      final place = routeOrder[index];
      return Marker(
        point: demoCoords[place]!,
        width: 40,
        height: 40,
        builder: (ctx) => CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueAccent,
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Itinerary Map"),
        backgroundColor: const Color(0xFFA5D6A7), // matches dashboard background
      ),
      body: FlutterMap(
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
    );
  }
}
