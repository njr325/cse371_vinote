class TastingEntry {
  final int? id; // ID de la base de données (peut être null lors de l'insertion)
  
  // Remplacer 'notes' par les champs de l'écran pour la clarté :
  final String aroma; // Anciennement inclus dans 'notes'
  final String flavor; // Anciennement inclus dans 'notes'
  final String personalNotes; // Anciennement inclus dans 'notes'
  
  // Garder les informations du vin pour la recherche (nom, région, millésime)
  // NOTE: Dans une base de données relationnelle, ces champs seraient dans la table Wine.
  // Pour la simplicité de SQLite non-relationnelle ici, nous les ajoutons.
  final String name; // Nom du vin (nécessaire pour l'affichage du journal)
  final String region;
  final int vintage;

  final double rating;
  final String date; // Format ISO 8601 pour un stockage facile

  TastingEntry({
    this.id,
    required this.name,
    required this.region,
    required this.vintage,
    required this.rating,
    required this.aroma, // NOUVEAU
    required this.flavor, // NOUVEAU
    required this.personalNotes, // NOUVEAU
    required this.date,
  });

  // Convertit un objet TastingEntry en Map (pour l'insertion/mise à jour dans SQLite)
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'region': region,
      'vintage': vintage,
      'rating': rating,
      'aroma': aroma, // NOUVEAU
      'flavor': flavor, // NOUVEAU
      'personalNotes': personalNotes, // NOUVEAU
      'date': date,
    };
    
    // Omettre l'ID pour l'insertion
    if (id != null) {
      map['id'] = id;
    }
    
    return map;
  }

  // Crée un objet TastingEntry à partir d'une Map (récupéré de SQLite)
  factory TastingEntry.fromMap(Map<String, dynamic> map) {
    return TastingEntry(
      id: map['id'] as int?,
      name: map['name'] as String,
      region: map['region'] as String,
      vintage: map['vintage'] as int,
      rating: (map['rating'] as num).toDouble(), 
      aroma: map['aroma'] as String, // NOUVEAU
      flavor: map['flavor'] as String, // NOUVEAU
      personalNotes: map['personalNotes'] as String, // NOUVEAU
      date: map['date'] as String,
    );
  }
}