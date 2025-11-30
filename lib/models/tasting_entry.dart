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

  // Convertit un objet TastingEntry en Map (pour l'insertion dans SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'vintage': vintage,
      'rating': rating,
      'notes': notes,
      'date': date,
    };
  }

  // Crée un objet TastingEntry à partir d'une Map (récupéré de SQLite)
  factory TastingEntry.fromMap(Map<String, dynamic> map) {
    return TastingEntry(
      id: map['id'] as int?,
      name: map['name'] as String,
      region: map['region'] as String,
      vintage: map['vintage'] as int,
      rating: map['rating'] as double,
      notes: map['notes'] as String,
      date: map['date'] as String,
    );
  }
}