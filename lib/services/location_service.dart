import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  
  // Fonction pour gérer les permissions et obtenir la position actuelle
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Teste si les services de localisation sont activés
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Les services de localisation sont désactivés.');
    }

    // Vérifie et demande la permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission de localisation refusée par l\'utilisateur.');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Les permissions de localisation sont refusées définitivement. Veuillez les activer dans les paramètres.');
    }

    // Récupère la position avec une précision moyenne
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }
  
  // Correction de l'erreur : Ajout de la méthode getCurrentCountryCode
  Future<String?> getCurrentCountryCode() async {
    try {
      final position = await getCurrentLocation();
      // Utilise le géocodage inverse
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      
      if (placemarks.isNotEmpty) {
        return placemarks.first.isoCountryCode;
      }
      return null;
    } catch (e) {
      print("Erreur lors de la récupération du code pays: $e");
      return null;
    }
  }

  // Fonction pour déterminer l'âge légal (inchangée)
  Future<int> getLegalDrinkingAge(double lat, double lon) async {
    if (lon < -50.0) {
      return 21; // Simule l'âge légal de 21 ans (Ex: USA)
    } else {
      return 18; // Simule l'âge légal de 18 ans (Ex: France, Europe)
    }
  }
}