// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'config.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
//
// class TrailSearchResult {
//   final String id;
//   final String name;
//   final double lat;
//   final double lng;
//   final String? subtitle;
//
//   TrailSearchResult({
//     required this.id,
//     required this.name,
//     required this.lat,
//     required this.lng,
//     this.subtitle,
//   });
//
//   LatLng get latLng => LatLng(lat, lng);
// }
//
// class LookupServices {
//   static const MethodChannel _channel = MethodChannel('app.config');
//
//
//   // ---------------------------------------------------------
//   // 1. SEARCH TRAILS BY NAME (using Places Text Search)
//   // ---------------------------------------------------------
//   static Future<List<TrailSearchResult>> searchTrailsByName(String name) async {
//     final apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//
//     final url =
//         "https://maps.googleapis.com/maps/api/place/textsearch/json"
//         "?query=$name hiking trail"
//         "&type=park"
//         "&key=$apiKey";
//
//     final res = await http.get(Uri.parse(url));
//
//     final data = jsonDecode(res.body);
//
//     if (data["status"] != "OK") return [];
//
//     List results = data["results"];
//
//     return results.map((place) {
//       final loc = place["geometry"]["location"];
//       return TrailSearchResult(
//         id: place["place_id"],
//         name: place["name"],
//         lat: loc["lat"],
//         lng: loc["lng"],
//         subtitle: place["formatted_address"],
//       );
//     }).toList();
//   }
//
//   // ---------------------------------------------------------
//   // 2. SEARCH PLACES (Cities, Areas, Addresses)
//   // ---------------------------------------------------------
//   static Future<List<TrailSearchResult>> searchPlaces(String query) async {
//     final apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//
//     final url =
//         "https://maps.googleapis.com/maps/api/place/textsearch/json"
//         "?query=$query"
//         "&key=$apiKey";
//
//     final res = await http.get(Uri.parse(url));
//     final data = jsonDecode(res.body);
//
//     if (data["status"] != "OK") return [];
//
//     List results = data["results"];
//
//     return results.map((place) {
//       final loc = place["geometry"]["location"];
//       return TrailSearchResult(
//         id: place["place_id"],
//         name: place["name"],
//         lat: loc["lat"],
//         lng: loc["lng"],
//         subtitle: place["formatted_address"],
//       );
//     }).toList();
//   }
//
//   // ---------------------------------------------------------
//   // 3. AUTOCOMPLETE RESULTS (For typing suggestions)
//   // ---------------------------------------------------------
//   static Future<List<String>> autocomplete(String input) async {
//     final apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//
//     if (input.isEmpty) return [];
//
//     final url =
//         "https://maps.googleapis.com/maps/api/place/autocomplete/json"
//         "?input=$input"
//         "&types=geocode"
//         "&key=$apiKey";
//
//     final res = await http.get(Uri.parse(url));
//     final data = jsonDecode(res.body);
//
//     if (data["status"] != "OK") return [];
//
//     List predictions = data["predictions"];
//
//     return predictions.map<String>((p) => p["description"]).toList();
//   }
//
//   // // ---------------------------------------------------------
//   // // 4. NEARBY TRAILS (using Nearby Search)
//   // // ---------------------------------------------------------
//   // static Future<List<TrailSearchResult>> fetchNearbyTrails(
//
//   //     LatLng location) async {
//   //   final url =
//   //       "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
//   //       "?location=${location.latitude},${location.longitude}"
//   //       "&radius=5000"
//   //       "&keyword=hiking"
//   //       "&type=park"
//   //       "&key=$apiKey";
//   //
//   //   final res = await http.get(Uri.parse(url));
//   //   final data = jsonDecode(res.body);
//   //
//   //   if (data["status"] != "OK") return [];
//   //
//   //   List results = data["results"];
//   //
//   //   return results.map((place) {
//   //     final loc = place["geometry"]["location"];
//   //     return TrailSearchResult(
//   //       id: place["place_id"],
//   //       name: place["name"],
//   //       lat: loc["lat"],
//   //       lng: loc["lng"],
//   //       subtitle: place["vicinity"],
//   //     );
//   //   }).toList();
//   // }
// }
