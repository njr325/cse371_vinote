import 'dart:convert';
import 'package:flutter/services.dart';
import '../services/location_service.dart';
import '../models/wine.dart';

// Énumération pour définir le profil de saveur d'un vin
enum WineFlavorProfile { 
  Red_Light, 
  Red_Bold, 
  White_Dry, 
  White_Sweet, 
  Sparkling, 
  Unknown 
}

class PairingLogicService {
  final LocationService _locationService = LocationService();
  Map<String, dynamic>? _pairingRules;
  Map<String, dynamic>? _localCuisine;

  // Initialise et charge les fichiers JSON depuis les assets
  Future<void> _loadData() async {
    if (_pairingRules == null) {
      final rulesJson = await rootBundle.loadString('assets/data/pairing_rules.json');
      _pairingRules = json.decode(rulesJson);
    }
    if (_localCuisine == null) {
      final localJson = await rootBundle.loadString('assets/data/local_cuisine_data.json');
      _localCuisine = json.decode(localJson);
    }
  }

  /// Fonction de mappage (simplifiée) pour déterminer le profil du vin scanné.
  /// Dans une version réelle, ceci analyserait les notes de dégustation de l'IA.
  WineFlavorProfile _getProfileFromWine(Wine wine) {
    final nameLower = wine.labelName.toLowerCase();
    
    if (nameLower.contains('cabernet') || nameLower.contains('syrah')) {
      return WineFlavorProfile.Red_Bold;
    }
    if (nameLower.contains('pinot noir') || nameLower.contains('gamay')) {
      return WineFlavorProfile.Red_Light;
    }
    if (nameLower.contains('champagne') || nameLower.contains('cava')) {
      return WineFlavorProfile.Sparkling;
    }
    if (nameLower.contains('sauvignon')) {
      return WineFlavorProfile.White_Dry;
    }
    return WineFlavorProfile.Unknown;
  }
  
  // Fonction principale pour obtenir les suggestions
  Future<Map<String, List<String>>> getPairingSuggestions(Wine wine) async {
    await _loadData();
    
    final profile = _getProfileFromWine(wine);
    final profileKey = profile.toString().split('.').last; // Ex: "Red_Bold"

    final List<String> generalPairings = 
        (_pairingRules?['profiles'][profileKey]?['dishes'] as List<dynamic>?)
        ?.map((e) => e as String).toList() ?? ['Aucune suggestion générale trouvée.'];

    // 1. Déterminer le pays actuel
    final countryCode = await _locationService.getCurrentCountryCode();
    
    // 2. Trouver les plats locaux basés sur le pays
    final List<String> localPairings = [];
    if (countryCode != null && _localCuisine?.containsKey(countryCode) == true) {
      final countryData = _localCuisine![countryCode];
      localPairings.addAll((countryData['local_dishes'] as List<dynamic>).map((e) => e as String));
      // Optionnel: ajouter la logique pour les régions spécifiques si vous avez les données régionales
    }
    
    return {
      'profile_name': [_pairingRules?['profiles'][profileKey]?['name'] ?? 'Inconnu'],
      'general': generalPairings,
      'local': localPairings.isNotEmpty ? localPairings : ['Aucun plat local suggéré pour votre région (${countryCode ?? 'inconnu'}).'],
    };
  }
}