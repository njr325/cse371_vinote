import 'package:google_maps_flutter/google_maps_flutter.dart';

class Winery {
  final String id;
  final String name;
  final String address;
  final LatLng coordinates; // Position sur la carte
  final double rating;
  
  Winery({
    required this.id,
    required this.name,
    required this.address,
    required this.coordinates,
    required this.rating,
  });

  // Fonction utilitaire pour créer un Winery à partir d'une Map (typiquement d'une API)
  factory Winery.fromApiMap(Map<String, dynamic> map) {
    // Supposons que l'API retourne des coordonnées 'lat' et 'lng'
    return Winery(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      coordinates: LatLng(map['latitude'] as double, map['longitude'] as double),
      rating: map['rating'] as double? ?? 0.0, // Rating peut être optionnel
    );
  }
}