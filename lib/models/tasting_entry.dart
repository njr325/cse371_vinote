class TastingEntry {
  final int? id; // ID de la base de données (peut être null lors de l'insertion)
  final String name;
  final String region;
  final int vintage;
  final double rating;
  final String notes;
  final String date; // Format ISO 8601 pour un stockage facile

  TastingEntry({
    this.id,
    required this.name,
    required this.region,
    required this.vintage,
    required this.rating,
    required this.notes,
    required this.date,
  });

  // Convertit un objet TastingEntry en Map (pour l'insertion/mise à jour dans SQLite)
  // CORRECTION CRITIQUE : Omet l'ID si l'entrée est nouvelle (id == null)
  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'region': region,
      'vintage': vintage,
      'rating': rating,
      'notes': notes,
      'date': date,
    };
    
    // N'inclut l'ID que s'il est déjà défini (pour la mise à jour, pas l'insertion)
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
      
      // La valeur de 'vintage' doit être convertie en int
      vintage: map['vintage'] as int,
      
      // CORRECTION : Utilise 'num' comme type intermédiaire pour convertir les INTEGER ou REAL 
      // de SQLite en double (le type le plus sûr pour un 'rating').
      rating: (map['rating'] as num).toDouble(), 
      
      notes: map['notes'] as String,
      date: map['date'] as String,
    );
  }
}