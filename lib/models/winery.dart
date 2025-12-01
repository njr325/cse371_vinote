// lib/models/winery.dart

import 'package:latlong2/latlong.dart'; // NOUVEL IMPORT

class Winery {
  final int id;
  final String name;
  final String description;
  final LatLng location; // Le type LatLng est maintenant reconnu
  // ... autres champs
  
  Winery({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
  });
  // Ajoutez les méthodes fromMap/toMap si vous stockez Winery dans la DB
}