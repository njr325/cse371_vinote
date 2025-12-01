class TastingEntry {
  final int? id; // ID de la base de données (peut être null lors de l'insertion)
  final int wineId; // Lien vers la table Wine (Clé étrangère logique)
  final String name;
  final String region;
  final int vintage;
  final double rating;
  
  // Champs détaillés pour la dégustation
  final String aroma; 
  final String flavor; 
  final String personalNotes; 
  
  final String date; // Format ISO 8601

  TastingEntry({
    this.id,
    required this.wineId,
    required this.name,
    required this.region,
    required this.vintage,
    required this.rating,
    required this.aroma, 
    required this.flavor, 
    required this.personalNotes,
    required this.date,
  });

  // Convertit un objet TastingEntry en Map (pour l'insertion/mise à jour dans SQLite)
  Map<String, dynamic> toMap() {
    final map = {
      'wineId': wineId,
      'name': name,
      'region': region,
      'vintage': vintage,
      'rating': rating,
      'aroma': aroma,
      'flavor': flavor,
      'personalNotes': personalNotes,
      'date': date,
    };
    
    // Correction de typage : Assurer que l'ID est bien un int s'il est présent
    if (id != null) {
      map['id'] = id as int;
    }
    
    return map;
  }

  // Crée un objet TastingEntry à partir d'une Map (récupéré de SQLite)
  factory TastingEntry.fromMap(Map<String, dynamic> map) {
    return TastingEntry(
      id: map['id'] as int?,
      wineId: map['wineId'] as int,
      name: map['name'] as String,
      region: map['region'] as String,
      // Conversions robustes
      vintage: (map['vintage'] as int?) ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0, 
      aroma: map['aroma'] as String,
      flavor: map['flavor'] as String,
      personalNotes: map['personalNotes'] as String,
      date: map['date'] as String,
    );
  }
}