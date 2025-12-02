import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'services/trail_service.dart';
import 'trail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const MethodChannel _channel = MethodChannel('app.config');
  String? apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await _channel.invokeMethod<String>('getMapsApiKey');
    setState(() {
      apiKey = key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please log in to see favorites.")),
      );
    }

    final favoritesRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites");

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorite Trails"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: favoritesRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || apiKey == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "No favorite trails yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final trail = Trail(
                id: data["id"],
                name: data["name"],
                address: data["address"],
                lat: data["lat"],
                lng: data["lng"],
                photoReference: data["photoReference"],
                rating: data["rating"]?.toDouble(),
                icon: null,
                userRatingsTotal: data["userRatingsTotal"],
              );

              return _buildFavoriteCard(context, trail);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, Trail trail) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrailDetailScreen(trail: trail),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildThumbnail(trail),
              const SizedBox(width: 12),
              Expanded(child: _buildTrailInfo(context, trail)),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteFavorite(context, trail),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(Trail trail) {
    if (trail.photoReference == null || apiKey == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 70,
          width: 70,
          color: Colors.grey[300],
          child: const Icon(Icons.photo, size: 28),
        ),
      );
    }

    final url =
        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${trail.photoReference}&key=$apiKey";

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: 70,
        width: 70,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTrailInfo(BuildContext context, Trail trail) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trail.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          trail.address,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 6),
        if (trail.rating != null)
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 4),
              Text("${trail.rating} (${trail.userRatingsTotal ?? 0})"),
            ],
          ),
      ],
    );
  }

  Future<void> _deleteFavorite(BuildContext context, Trail trail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("favorites")
        .doc(trail.id);

    await docRef.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Removed ${trail.name}")),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/services.dart';
// import 'services/trail_service.dart';
// import 'trail_screen.dart';
//
// class FavoritesScreen extends StatelessWidget {
//   const FavoritesScreen({super.key});
//   const MethodChannel static const = MethodChannel('app.config');
//   final apiKey = await channel.invokeMethod<String>('getMapsApiKey') ?? '';
//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//
//     if (user == null) {
//       return const Scaffold(
//         body: Center(child: Text("Please log in to see favorites.")),
//       );
//     }
//
//     final favoritesRef = FirebaseFirestore.instance
//         .collection("users")
//         .doc(user.uid)
//         .collection("favorites");
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Favorite Trails"),
//         backgroundColor: Colors.green,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: favoritesRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           final docs = snapshot.data!.docs;
//
//           if (docs.isEmpty) {
//             return const Center(
//               child: Text(
//                 "No favorite trails yet.",
//                 style: TextStyle(fontSize: 18),
//               ),
//             );
//           }
//
//           return ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: docs.length,
//             itemBuilder: (context, index) {
//               final data = docs[index].data() as Map<String, dynamic>;
//
//               final trail = Trail(
//                 id: data["id"],
//                 name: data["name"],
//                 address: data["address"],
//                 lat: data["lat"],
//                 lng: data["lng"],
//                 photoReference: data["photoReference"],
//                 rating: data["rating"]?.toDouble(),
//                 icon: null,
//                 userRatingsTotal: data["userRatingsTotal"],
//               );
//
//               return _buildFavoriteCard(context, trail);
//             },
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFavoriteCard(BuildContext context, Trail trail) {
//     return Card(
//       elevation: 3,
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => TrailDetailScreen(trail: trail),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               _buildThumbnail(trail),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: _buildTrailInfo(context, trail),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.red),
//                 onPressed: () => _deleteFavorite(context, trail),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildThumbnail(Trail trail) {
//     if (trail.photoReference == null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Container(
//           height: 70,
//           width: 70,
//           color: Colors.grey[300],
//           child: const Icon(Icons.photo, size: 28),
//         ),
//       );
//     }
//
//     // Build photo URL
//     final url =
//         "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${trail.photoReference}&key=${apiKey}";
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(10),
//       child: Image.network(
//         url,
//         height: 70,
//         width: 70,
//         fit: BoxFit.cover,
//       ),
//     );
//   }
//
//   Widget _buildTrailInfo(BuildContext context, Trail trail) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           trail.name,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           trail.address,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(color: Colors.black54),
//         ),
//         const SizedBox(height: 6),
//         if (trail.rating != null)
//           Row(
//             children: [
//               const Icon(Icons.star, color: Colors.amber, size: 18),
//               const SizedBox(width: 4),
//               Text("${trail.rating} (${trail.userRatingsTotal ?? 0})"),
//             ],
//           ),
//       ],
//     );
//   }
//
//   Future<void> _deleteFavorite(BuildContext context, Trail trail) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;
//
//     final docRef = FirebaseFirestore.instance
//         .collection("users")
//         .doc(user.uid)
//         .collection("favorites")
//         .doc(trail.id);
//
//     await docRef.delete();
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Removed ${trail.name}")),
//     );
//   }
// }
