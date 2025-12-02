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
      debugPrint("NEARBY RESPONSE: ${jsonEncode(json)}");
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

  static Future<Map<String, dynamic>> fetchPlaceDetails(String placeId, String apiKey) async {
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

  static Future<List<Trail>> searchTrailsByName(String name) async {
    final String apiKey =
        await _channel.invokeMethod<String>('getMapsApiKey') ?? '';

    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=${Uri.encodeComponent(name)}"
        "&type=park"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);
    print("🔍Search Name Called!!!!!!!!: ${jsonEncode(json)}");

    if (json["status"] != "OK") return [];

    List results = json["results"];

    return results.map<Trail>((place) {
      final loc = place["geometry"]["location"];

      return Trail(
        id: place["place_id"],
        name: place["name"] ?? "Unknown Trail",
        address: place["formatted_address"] ?? "No address",
        lat: loc["lat"],
        lng: loc["lng"],
        photoReference: (place["photos"] != null && place["photos"].isNotEmpty)
            ? place["photos"][0]["photo_reference"]
            : null,
        rating: place["rating"]?.toDouble(),
        icon: place["icon"],
        userRatingsTotal: place["user_ratings_total"],
      );
    }).toList();
  }

  static Future<List<Trail>> searchPlaces(String query) async {
    final String apiKey =
        await _channel.invokeMethod<String>('getMapsApiKey') ?? '';

    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=${Uri.encodeComponent(query)}"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);
    print("🔍 searchPlaces() raw response: ${jsonEncode(json)}");

    if (json["status"] != "OK") return [];

    List results = json["results"];

    return results.map<Trail>((place) {
      final loc = place["geometry"]["location"];

      return Trail(
        id: place["place_id"],
        name: place["name"],
        address: place["formatted_address"] ?? "",
        lat: loc["lat"],
        lng: loc["lng"],
        photoReference: null, // usually not provided
        rating: place["rating"]?.toDouble(),
        icon: place["icon"],
        userRatingsTotal: place["user_ratings_total"],
      );
    }).toList();
  }

  static Future<List<String>> autocomplete(String input) async {
    if (input.isEmpty) return [];

    final String apiKey =
        await _channel.invokeMethod<String>('getMapsApiKey') ?? '';

    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        "?input=${Uri.encodeComponent(input)}"
        "&types=geocode"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final json = jsonDecode(response.body);

    if (json["status"] != "OK") return [];

    List predictions = json["predictions"];

    return predictions.map<String>((p) => p["description"]).toList();
  }


}
