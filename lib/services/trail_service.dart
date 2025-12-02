import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'config.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class Trail {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? photoReference;
  final double? rating;
  final String? icon;
  final int? userRatingsTotal;

  Trail({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.photoReference,
    this.rating,
    this.icon,
    this.userRatingsTotal,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "name": name,
      "address": address,
      "lat": lat,
      "lng": lng,
      "photoReference": photoReference,
      "rating": rating,
      "userRatingsTotal": userRatingsTotal,
    };
  }

  LatLng get latLng => LatLng(lat, lng);

  String? get photoUrl => photoReference != null
      ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=$photoReference&key=${AppConfig.mapsApiKey}'
      : null;
}

class TrailService {
  static const MethodChannel _channel = MethodChannel('app.config');

  static Future<List<Trail>> fetchNearbyTrails(LatLng location) async {
    final String apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${location.latitude},${location.longitude}'
        '&radius=20000'
        '&keyword=hiking'
        '&type=park'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      debugPrint("PLACES RESPONSE: ${jsonEncode(json)}");
      final results = json['results'] as List;

      return results.map<Trail>((place) {
        final location = place['geometry']['location'];
        return Trail(
          id: place['place_id'],
          name: place['name'] ?? 'Unknown Trail',
          address: place['vicinity'] ?? 'No address',
          lat: location['lat'],
          lng: location['lng'],
          photoReference: (place['photos'] != null && place['photos'].isNotEmpty)
              ? place['photos'][0]['photo_reference']
              : null,
          rating: place['rating']?.toDouble(),
          icon: place['icon'],
          userRatingsTotal: place['user_ratings_total'],
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch places: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> fetchPlaceDetails(
      String placeId, String apiKey) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=name,photos,website,reviews,rating,user_ratings_total'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch details");
    }

    final json = jsonDecode(response.body);
    return json['result'] ?? {};
  }
}
//
//
// class TrailService {
//   // static const String _apiKey = String.fromEnvironment("MAPS_API_KEY"); // or use method channel if needed
//   static const MethodChannel _channel = MethodChannel('app.config');
//
//   static Future<List<LatLng>> fetchNearbyTrails(LatLng location) async {
//     final String apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//
//     final String url =
//         'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
//         '?location=${location.latitude},${location.longitude}'
//         '&radius=5000'
//         '&keyword=hiking'
//         '&type=park'
//         '&key=$apiKey';
//
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final json = jsonDecode(response.body);
//       debugPrint("PLACES RESPONSE: ${jsonEncode(json)}");
//       final results = json['results'] as List;
//
//       return results.map((place) {
//         final lat = place['geometry']['location']['lat'];
//         final lng = place['geometry']['location']['lng'];
//         return LatLng(lat, lng);
//       }).toList();
//     } else {
//       throw Exception('Failed to fetch places: ${response.statusCode}');
//     }
//   }
// }
