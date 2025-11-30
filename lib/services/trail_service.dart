import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrailService {
  static const String _apiKey = String.fromEnvironment("MAPS_API_KEY"); // or use method channel if needed

  static Future<List<LatLng>> fetchNearbyTrails(LatLng location) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=5000'
        '&keyword=hiking'
        '&type=park'
        '&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final results = json['results'] as List;

      return results.map((place) {
        final lat = place['geometry']['location']['lat'];
        final lng = place['geometry']['location']['lng'];
        return LatLng(lat, lng);
      }).toList();
    } else {
      throw Exception('Failed to fetch places: ${response.statusCode}');
    }
  }
}
