import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'services/trail_service.dart';
import 'trail_screen.dart';

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
    // Marker(
    //   markerId: MarkerId('trail_1'),
    //   position: LatLng(37.8076, -122.4751),
    //   infoWindow: InfoWindow(title: 'Test Trail 1'),
    // ),
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
        onPressed: _loadNearbyTrails,
        child: const Icon(Icons.place),

      ),
    );
  }

  Future<void> _loadNearbyTrails() async {
    final controller = await _mapController.future;
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final LatLng userLocation = LatLng(position.latitude, position.longitude);

    debugPrint("Fetching trails near: $userLocation");

    try {
      final trails = await TrailService.fetchNearbyTrails(userLocation);
      setState(() {
        _markers.clear();
        for (final trail in trails) {
          _markers.add(
            Marker(
              markerId: MarkerId(trail.id),
              position: trail.latLng,
              infoWindow: InfoWindow(
                title: trail.name,
                onTap: () => _openTrailDetail(trail),
              ),
            ),
          );
        }
      });

      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 10),
      );

      debugPrint("Loaded ${trails.length} trail markers");
    } catch (e) {
      debugPrint("Error loading trails: $e");
    }
  }
  void _openTrailDetail(Trail trail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrailDetailScreen(trail: trail),
      ),
    );
  }

}


