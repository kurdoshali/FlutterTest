import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  CameraPosition _cameraPosition = CameraPosition(
    target: LatLng(37.7749, -122.4194), // default location
    zoom: 9.0,
  );
  bool _locationPermissionGranted = false;

  final Set<Marker> _markers = {
    Marker(
      markerId: MarkerId('trail_1'),
      position: LatLng(37.8076, -122.4751),
      infoWindow: InfoWindow(title: 'Test Trail 1'),
    ),
  };

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      debugPrint("Location permission denied.");
      return;
    }

    _locationPermissionGranted = true;

    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final LatLng userLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _cameraPosition = CameraPosition(target: userLatLng, zoom: 14.0);
    });

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(userLatLng));
    debugPrint("Moved camera to user's location: $userLatLng");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _cameraPosition,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController.complete(controller);
          debugPrint("Google Map created");
        },
        myLocationEnabled: _locationPermissionGranted,
        myLocationButtonEnabled: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.place),
        onPressed: () async {
          debugPrint("Floating button pressed");

          final controller = await _mapController.future;
          LatLng fallback = const LatLng(37.8076, -122.4751); // Golden Gate area
          LatLng? userLatLng;

          if (_locationPermissionGranted) {
            try {
              final position = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,
              );
              userLatLng = LatLng(position.latitude, position.longitude);
            } catch (e) {
              debugPrint("Failed to get location, using fallback: $e");
            }
          }

          final target = userLatLng ?? fallback;

          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: target, zoom: 14.0),
            ),
          );

          debugPrint("Moved camera to: $target");
        },
      ),
    );
  }
}

