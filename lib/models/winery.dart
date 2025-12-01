// lib/models/winery.dart

import 'package:latlong2/latlong.dart'; // Pour LatLng

class Winery {
  final int id;
  final String name;
  final String description;
  final LatLng location; // Coordonnées géographiques

  Winery({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
  });

  // NOUVEAU CONSTRUCTEUR D'USINE : Convertit les données brutes de l'API en objet Winery
  factory Winery.fromApiMap(Map<String, dynamic> map) {
    // ⚠️ ATTENTION : Les noms des clés ('lat', 'lon', 'name', etc.) 
    // dépendent de la structure réelle du JSON renvoyé par votre API OSM.
    
    // Si votre API OSM est basée sur Overpass ou Nominatim, les clés peuvent varier.
    
    // Exemple d'une structure API standard (à ajuster si nécessaire) :
    
    final double latitude = (map['latitude'] as num?)?.toDouble() ?? 0.0;
    final double longitude = (map['longitude'] as num?)?.toDouble() ?? 0.0;
    
    return Winery(
      // L'ID est souvent une chaîne ou un long int dans les APIs, on le convertit en int.
      id: map['id'] as int? ?? map['osm_id'] as int? ?? 0, 
      name: map['name'] as String? ?? 'Vignoble inconnu',
      description: map['description'] as String? ?? 'Aucune description fournie.',
      location: LatLng(latitude, longitude),
    );
  }
}