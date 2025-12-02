import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'services/trail_service.dart';
import 'trail_screen.dart';



class PlaceSearchResultsScreen extends StatefulWidget {
  final String query;

  PlaceSearchResultsScreen({required this.query});

  @override
  _PlaceSearchResultsScreenState createState() =>
      _PlaceSearchResultsScreenState();
}

class _PlaceSearchResultsScreenState extends State<PlaceSearchResultsScreen> {
  List<Trail> placeMatches = [];
  List<Trail> nearbyTrails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _runPlaceSearch();
  }

  Future<void> _runPlaceSearch() async {
    // 1. Find place(s) that match the name
    placeMatches = await TrailService.searchPlaces(widget.query);

    if (placeMatches.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    // 2. Take the FIRST place result’s coordinates
    final LatLng pos = placeMatches.first.latLng;
    print(pos);

    // 3. Use your existing nearby-trails function
    nearbyTrails = await TrailService.fetchNearbyTrails(pos);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trails near: ${widget.query}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: nearbyTrails.length,
        itemBuilder: (context, i) {
          final t = nearbyTrails[i];
          return ListTile(
            leading: Icon(Icons.terrain),
            title: Text(t.name),
            subtitle: Text(t.address),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TrailDetailScreen(trail: t),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
