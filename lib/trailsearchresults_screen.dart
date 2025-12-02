import 'package:flutter/material.dart';
import 'services/trail_service.dart';
import 'trail_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class TrailSearchResultsScreen extends StatefulWidget {
  final String query;

  TrailSearchResultsScreen({required this.query});

  @override
  _TrailSearchResultsScreenState createState() =>
      _TrailSearchResultsScreenState();
}

class _TrailSearchResultsScreenState extends State<TrailSearchResultsScreen> {
  List<Trail> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchTrails();
  }

  Future<void> _searchTrails() async {
    results = await TrailService.searchTrailsByName(widget.query);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Trails Matching: ${widget.query}")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, i) {
          final t = results[i];
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
