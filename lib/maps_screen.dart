import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'services/trail_service.dart';
import 'trail_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _initialCamera = const CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 8,
  );

  bool locationAllowed = false;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // ---------------- INITIAL USER LOCATION ----------------
  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint("Location permission denied.");
      return;
    }

    locationAllowed = true;
    final pos = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(pos.latitude, pos.longitude);

    // final controller = await _mapController.future;
    // controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 14));
  }

  // ---------------- LOAD NEARBY TRAILS ----------------
  Future<void> _loadNearbyTrails() async {
    final pos = await Geolocator.getCurrentPosition();
    final userLocation = LatLng(pos.latitude, pos.longitude);

    final trails = await TrailService.fetchNearbyTrails(userLocation);

    setState(() {
      _markers.clear();
      for (final t in trails) {
        _markers.add(
          Marker(
            markerId: MarkerId(t.id),
            position: t.latLng,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(
              title: t.name,
              snippet: t.address,
              onTap: () => _openTrail(t),
            ),
          ),
        );
      }
    });

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 12));
  }

  void _openTrail(Trail t) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: t)),
    );
  }

  // ---------------- BUILD UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: (controller) => _mapController.complete(controller),
        initialCameraPosition: _initialCamera,
        myLocationEnabled: locationAllowed,
        myLocationButtonEnabled: true,
        markers: _markers,
        mapToolbarEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
      ),

      // Nearby Trails Button
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Nearby Trails"),
        icon: Icon(Icons.terrain),
        onPressed: _loadNearbyTrails,
      ),
    );
  }
}



// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'services/trail_service.dart';
// import 'package:flutter/services.dart';
// import 'services/Lookup_services.dart';
// import 'trail_screen.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   final Completer<GoogleMapController> _mapController = Completer();
//
//   CameraPosition _initialCamera = const CameraPosition(
//     target: LatLng(37.7749, -122.4194),
//     zoom: 10,
//   );
//
//   bool locationAllowed = false;
//   Set<Marker> _markers = {};
//
//   BitmapDescriptor? trailIcon;
//   BitmapDescriptor? searchIcon;
//
//   TextEditingController _searchController = TextEditingController();
//   List<dynamic> _searchResults = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadMarkerIcons();
//     _initLocation();
//   }
//
//   Future<void> _loadMarkerIcons() async {
//     trailIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)),
//       'assets/icons/trail_marker.png',
//     );
//     searchIcon = await BitmapDescriptor.fromAssetImage(
//       const ImageConfiguration(size: Size(48, 48)),
//       'assets/icons/search_marker.png',
//     );
//   }
//
//   // ---------------- LOCATION INIT ----------------
//   Future<void> _initLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       debugPrint("Location permission denied.");
//       return;
//     }
//
//     locationAllowed = true;
//     final pos = await Geolocator.getCurrentPosition();
//     final userLatLng = LatLng(pos.latitude, pos.longitude);
//
//     final controller = await _mapController.future;
//     controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 14));
//   }
//
//   // ---------------- SEARCH HANDLER ----------------
//   Future<void> _handleSearch(String query) async {
//     if (query.isEmpty) return;
//
//     // 1. Try trail search
//     final trailResults = await TrailService.searchTrailsByName(query);
//     if (trailResults.isNotEmpty) {
//       setState(() => _searchResults = trailResults);
//       return;
//     }
//
//     // 2. Else try Places API Search
//     final placeResults = await TrailService.searchPlaces(query);
//     setState(() => _searchResults = placeResults);
//   }
//
//   Future<void> _goToSearchResult(dynamic result) async {
//     final controller = await _mapController.future;
//
//     LatLng pos = LatLng(result.lat, result.lng);
//
//     setState(() {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: MarkerId(result.id.toString()),
//           position: pos,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//           infoWindow: InfoWindow(title: result.name),
//         ),
//       );
//     });
//
//     controller.animateCamera(CameraUpdate.newLatLngZoom(pos, 14));
//
//     Navigator.pop(context); // close bottom sheet
//   }
//
//   // ---------------- LOAD NEARBY TRAILS ----------------
//   Future<void> _loadNearbyTrails() async {
//     final pos = await Geolocator.getCurrentPosition();
//     final userLocation = LatLng(pos.latitude, pos.longitude);
//
//     final trails = await TrailService.fetchNearbyTrails(userLocation);
//
//     setState(() {
//       _markers.clear();
//       for (final t in trails) {
//         _markers.add(
//           Marker(
//             markerId: MarkerId(t.id),
//             position: t.latLng,
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//             infoWindow: InfoWindow(
//               title: t.name,
//               snippet: t.address,
//               onTap: () => _openTrail(t),
//             ),
//           ),
//         );
//       }
//     });
//
//     final controller = await _mapController.future;
//     controller.animateCamera(CameraUpdate.newLatLngZoom(userLocation, 12));
//   }
//
//   void _openTrail(Trail t) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: t)),
//     );
//   }
//
//   // ---------------- BUILD UI ----------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (controller) => _mapController.complete(controller),
//             initialCameraPosition: _initialCamera,
//             myLocationEnabled: locationAllowed,
//             myLocationButtonEnabled: true,
//             markers: _markers,
//             mapToolbarEnabled: true,
//             zoomControlsEnabled: true,
//           ),
//
//           // ---------------- SEARCH BAR ----------------
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(12),
//               child: Material(
//                 elevation: 4,
//                 borderRadius: BorderRadius.circular(12),
//                 child: TextField(
//                   controller: _searchController,
//                   onSubmitted: _handleSearch,
//                   decoration: InputDecoration(
//                     hintText: "Search location or trail...",
//                     prefixIcon: Icon(Icons.search),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.all(16),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//
//       // Button to load trails
//       floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
//       floatingActionButton: FloatingActionButton.extended(
//         label: Text("Nearby Trails"),
//         icon: Icon(Icons.terrain),
//         onPressed: _loadNearbyTrails,
//       ),
//
//       // ------------- SEARCH RESULTS SHEET -------------
//       bottomSheet: _searchResults.isEmpty
//           ? null
//           : DraggableScrollableSheet(
//         initialChildSize: 0.3,
//         minChildSize: 0.2,
//         maxChildSize: 0.6,
//         builder: (context, scrollController) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(
//                 top: Radius.circular(18),
//               ),
//             ),
//             child: ListView.builder(
//               controller: scrollController,
//               itemCount: _searchResults.length,
//               itemBuilder: (context, i) {
//                 final result = _searchResults[i];
//                 return ListTile(
//                   leading: Icon(Icons.place),
//                   title: Text(result.name),
//                   subtitle: Text(result.address),
//                   onTap: () => _goToSearchResult(result),
//                 );
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'dart:async';
// import 'services/trail_service.dart';
// import 'trail_screen.dart';
//
// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }
//
// class _MapScreenState extends State<MapScreen> {
//   final Completer<GoogleMapController> _mapController = Completer();
//   CameraPosition _cameraPosition = CameraPosition(
//     target: LatLng(37.7749, -122.4194), // default location
//     zoom: 9.0,
//   );
//   bool _locationPermissionGranted = false;
//
//   final Set<Marker> _markers = {
//     // Marker(
//     //   markerId: MarkerId('trail_1'),
//     //   position: LatLng(37.8076, -122.4751),
//     //   infoWindow: InfoWindow(title: 'Test Trail 1'),
//     // ),
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _initLocation();
//   }
//
//   Future<void> _initLocation() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//
//     if (permission == LocationPermission.deniedForever ||
//         permission == LocationPermission.denied) {
//       debugPrint("Location permission denied.");
//       return;
//     }
//
//     _locationPermissionGranted = true;
//
//     final Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high);
//
//     final LatLng userLatLng = LatLng(position.latitude, position.longitude);
//
//     setState(() {
//       _cameraPosition = CameraPosition(target: userLatLng, zoom: 14.0);
//     });
//
//     final controller = await _mapController.future;
//     controller.animateCamera(CameraUpdate.newLatLng(userLatLng));
//     debugPrint("Moved camera to user's location: $userLatLng");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//         mapType: MapType.normal,
//         initialCameraPosition: _cameraPosition,
//         markers: _markers,
//         onMapCreated: (controller) {
//           _mapController.complete(controller);
//           debugPrint("Google Map created");
//         },
//         myLocationEnabled: _locationPermissionGranted,
//         myLocationButtonEnabled: true,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
//       floatingActionButton: FloatingActionButton(
//         onPressed: _loadNearbyTrails,
//         child: const Icon(Icons.place),
//
//       ),
//     );
//   }
//
//   Future<void> _loadNearbyTrails() async {
//     final controller = await _mapController.future;
//     final position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     final LatLng userLocation = LatLng(position.latitude, position.longitude);
//
//     debugPrint("Fetching trails near: $userLocation");
//
//     try {
//       final trails = await TrailService.fetchNearbyTrails(userLocation);
//       setState(() {
//         _markers.clear();
//         for (final trail in trails) {
//           _markers.add(
//             Marker(
//               markerId: MarkerId(trail.id),
//               position: trail.latLng,
//               infoWindow: InfoWindow(
//                 title: trail.name,
//                 onTap: () => _openTrailDetail(trail),
//               ),
//             ),
//           );
//         }
//       });
//
//       await controller.animateCamera(
//         CameraUpdate.newLatLngZoom(userLocation, 10),
//       );
//
//       debugPrint("Loaded ${trails.length} trail markers");
//     } catch (e) {
//       debugPrint("Error loading trails: $e");
//     }
//   }
//   void _openTrailDetail(Trail trail) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => TrailDetailScreen(trail: trail),
//       ),
//     );
//   }
//
// }
//
//
