import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../config/api_config.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? controller;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      MapLibreMap(
        styleString: ApiConfig.mapStyleUrl,
        initialCameraPosition: const CameraPosition(
          target: LatLng(25.3176, 82.9739),
          zoom: 10.5,
        ),
        onMapCreated: (c) => controller = c,
      ),
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xE607110B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(children: [
                Icon(Icons.public, color: Color(0xFF72E35B)),
                SizedBox(width: 8),
                Text('FoodRescue Map', style: TextStyle(fontWeight: FontWeight.w700)),
              ]),
            ),
            const Spacer(),
            FloatingActionButton.small(
              heroTag: 'mapReset',
              onPressed: () => controller?.animateCamera(
                CameraUpdate.newCameraPosition(const CameraPosition(target: LatLng(25.3176, 82.9739), zoom: 10.5)),
              ),
              child: const Icon(Icons.my_location),
            )
          ]),
        ),
      ),
      Positioned(
        left: 16, right: 16, bottom: 18,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: const [
              Icon(Icons.location_on, color: Color(0xFF72E35B)),
              SizedBox(width: 10),
              Expanded(child: Text('Nearby donors and volunteer routes can be connected here.')),
            ]),
          ),
        ),
      ),
    ]);
  }
}
