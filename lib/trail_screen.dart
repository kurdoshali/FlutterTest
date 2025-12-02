import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/trail_service.dart';

class TrailDetailScreen extends StatefulWidget {
  final Trail trail;

  const TrailDetailScreen({super.key, required this.trail});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  List<String> photoUrls = [];
  List<Map<String, dynamic>> reviews = [];
  String? websiteUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  /// Builds a Google Place photo URL using a photo reference
  String buildPhotoUrl(String reference, String apiKey) {
    return 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=900'
        '&photoreference=$reference'
        '&key=$apiKey';
  }

  String fixUrl(String url) {
    if (url.startsWith("http://")) {
      return url.replaceFirst("http://", "https://");
    }
    return url;
  }

  /// Loads multiple photos, website, and reviews
  Future<void> _loadDetails() async {
    const MethodChannel channel = MethodChannel('app.config');
    final apiKey = await channel.invokeMethod<String>('getMapsApiKey') ?? '';

    final details =
    await TrailService.fetchPlaceDetails(widget.trail.id, apiKey);

    // Photos
    if (details['photos'] != null) {
      for (var p in details['photos']) {
        final ref = p['photo_reference'];
        final url = buildPhotoUrl(ref, apiKey);
        photoUrls.add(url);
      }
    }

    // Website
    websiteUrl = details['website'];

    // Reviews
    if (details['reviews'] != null) {
      reviews = List<Map<String, dynamic>>.from(details['reviews']);
    }

    setState(() {
      isLoading = false;
    });
  }

  Widget _buildPhotoCarousel() {
    if (photoUrls.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 220,
          color: Colors.grey[300],
          child: const Center(child: Text("No photos available")),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: PageView.builder(
          itemCount: photoUrls.length,
          controller: PageController(viewportFraction: 0.92),
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.network(
                photoUrls[index],
                fit: BoxFit.cover,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> r) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r['author_name'] ?? "Unknown user",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Icon(Icons.star, color: Colors.amber[700], size: 20),
                Text(" ${r['rating'] ?? "-"}"),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r['text'] ?? '',
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trail.name),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _buildPhotoCarousel(),
          const SizedBox(height: 18),

          /// Name
          Text(
            widget.trail.name,
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          /// Address
          Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 6),
              Expanded(child: Text(widget.trail.address)),
            ],
          ),
          const SizedBox(height: 10),

          /// Rating
          if (widget.trail.rating != null)
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 22),
                Text(" ${widget.trail.rating}"),
                const SizedBox(width: 8),
                Text("(${widget.trail.userRatingsTotal} reviews)"),
              ],
            ),

          const SizedBox(height: 20),

          /// Website Button
          if (websiteUrl != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final fixed = fixUrl(websiteUrl!);
                final uri = Uri.parse(fixed);

                launchUrl(uri, mode: LaunchMode.externalApplication);

                // if (await canLaunchUrl(uri)) {
                //   await launchUrl(uri, mode: LaunchMode.externalApplication);
                // }
              },
              icon: const Icon(Icons.link),
              label: const Text("Visit Trail Website"),
            ),

          const SizedBox(height: 28),

          /// Reviews Section
          Text(
            "Reviews",
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          if (reviews.isEmpty)
            const Text("No reviews available.")
          else
            ...reviews.map(_buildReviewCard),
        ],
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'services/trail_service.dart';
//
// class TrailDetailScreen extends StatefulWidget {
//   final Trail trail;
//
//   const TrailDetailScreen({super.key, required this.trail});
//
//   @override
//   State<TrailDetailScreen> createState() => _TrailDetailScreenState();
// }
//
// class _TrailDetailScreenState extends State<TrailDetailScreen> {
//   String? photoUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPhotoUrl();
//   }
//
//   String buildPhotoUrl(String photoReference, String apiKey) {
//     return 'https://maps.googleapis.com/maps/api/place/photo'
//         '?maxwidth=800'
//         '&photoreference=$photoReference'
//         '&key=$apiKey';
//   }
//
//   Future<void> _loadPhotoUrl() async {
//     const MethodChannel _channel = MethodChannel('app.config');
//     final apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//
//     final photoReference = widget.trail.photoReference;
//     if (photoReference != null && photoReference.isNotEmpty) {
//       final url = buildPhotoUrl(photoReference, apiKey);
//       setState(() {
//         photoUrl = url;
//       });
//     }
//   }
//   // Future<void> _loadPhotoUrl() async {
//   //   const MethodChannel _channel = MethodChannel('app.config');
//   //   final apiKey = await _channel.invokeMethod<String>('getMapsApiKey') ?? '';
//   //   final url = widget.trail.photoUrl?.replaceAll('YOUR_API_KEY', apiKey);
//   //   setState(() {
//   //     photoUrl = url;
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.trail.name),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           if (photoUrl != null)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 photoUrl!,
//                 height: 200,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//               ),
//             )
//           else
//             Container(
//               height: 200,
//               color: Colors.grey[300],
//               child: const Center(child: Text("No photo available")),
//             ),
//           const SizedBox(height: 16),
//           Text(widget.trail.name, style: Theme.of(context).textTheme.headlineSmall),
//           const SizedBox(height: 8),
//           Text(widget.trail.address),
//           const SizedBox(height: 8),
//           if (widget.trail.rating != null)
//             Row(
//               children: [
//                 Icon(Icons.star, color: Colors.amber),
//                 const SizedBox(width: 4),
//                 Text('${widget.trail.rating}'),
//                 const SizedBox(width: 8),
//                 Text('(${widget.trail.userRatingsTotal ?? 0} ratings)'),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
// }
