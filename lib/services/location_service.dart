import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  
  /// Récupère la position géographique exacte (coordonnées).
  /// Utilisé pour centrer la carte et calculer les lieux proches.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Vérifier si les services de localisation sont activés.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Les services de localisation sont désactivés.
      return null;
    }

    // 2. Vérifier et demander la permission.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // L'utilisateur a refusé.
        return null;
      }
    }

    try {
      // Obtenir la position actuelle avec une haute précision pour la carte
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high, 
      );
    } catch (e) {
      print("Erreur de récupération de position: $e");
      return null;
    }
  }

  /// Obtient le code pays (ex: 'FR', 'US') de l'utilisateur.
  /// Utilisé pour la vérification de l'âge légal.
  Future<String?> getCurrentCountryCode() async {
    final position = await getCurrentPosition(); // Réutiliser la logique de position
    
    if (position == null) {
      return null;
    }

    try {
      // Géocodage inverse pour obtenir le pays (Geocoding package).
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Le code pays (isoCountryCode) est le plus fiable.
      return placemarks.first.isoCountryCode;
    } catch (e) {
      print("Erreur de géocodage inverse: $e");
      return null; 
    }
  }
}