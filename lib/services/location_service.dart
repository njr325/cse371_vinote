import 'package:geolocator/geolocator.dart';

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

  // Fonction simplifiée pour SIMULER la détermination de l'âge légal
  // Dans une application réelle, ceci nécessiterait un appel à une API de géocodage inverse
  Future<int> getLegalDrinkingAge(double lat, double lon) async {
    // Logique simplifiée basée sur la latitude (Exemple : si près de l'équateur ou au-dessus)
    
    // Pour les besoins de la démonstration, nous simulons la France (20.90° E)
    // Age légal en France/Europe est généralement 18. Aux US, c'est 21.
    
    // Si la longitude est très négative (proche de l'Amérique)
    if (lon < -50.0) {
      return 21; // Simule l'âge légal de 21 ans (Ex: USA)
    } else {
      return 18; // Simule l'âge légal de 18 ans (Ex: France, Europe)
    }
  }
}