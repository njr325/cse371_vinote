import 'package:latlong2/latlong.dart';
import '../models/winery.dart';

class WineryApiService {
  // Simulez ici l'URL de votre API de recherche de lieux
  // Dans un cas réel, vous utiliseriez une clé API et des requêtes sécurisées.
  // const String _apiUrl = 'https://your-backend.com/api/wineries'; 

  /// Recherche les vignobles et bars à vin autour d'une position.
  Future<List<Winery>> fetchNearbyWineries(LatLng location) async {
    // --- SIMULATION D'APPEL API ---
    
    // Simuler le temps de chargement d'une API
    await Future.delayed(const Duration(seconds: 1));

    // Simulation de données reçues
    final List<Map<String, dynamic>> rawData = [
      {
        'id': 'W1',
        'name': 'Bar à Vin du Coin',
        'address': '1 Rue Imaginaire, Paris',
        'latitude': location.latitude + 0.005, // Proche de l'utilisateur
        'longitude': location.longitude + 0.003,
        'rating': 4.5,
      },
      {
        'id': 'W2',
        'name': 'Domaine du Rhône Fantôme',
        'address': 'Route de la Vigne',
        'latitude': location.latitude - 0.008,
        'longitude': location.longitude - 0.001,
        'rating': 4.8,
      },
      {
        'id': 'W3',
        'name': 'La Cave Secrète',
        'address': 'Sous la Butte',
        'latitude': location.latitude + 0.012,
        'longitude': location.longitude + 0.007,
        'rating': 4.1,
      },
    ];

    // Convertir les données brutes en liste de modèles Winery
    return rawData.map((data) => Winery.fromApiMap(data)).toList();
    
    // --- Code réel pour un appel HTTP ---
    /*
    final response = await http.get(Uri.parse(
      '$_apiUrl?lat=${location.latitude}&lng=${location.longitude}&radius=5000'
    ));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return (jsonResponse['results'] as List)
          .map((item) => Winery.fromApiMap(item))
          .toList();
    } else {
      throw Exception('Échec de la récupération des lieux.');
    }
    */
  }
}