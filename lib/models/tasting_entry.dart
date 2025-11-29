class TastingEntry {
  final int? id;
  final int wineId; // Clé étrangère vers la table Wine
  final DateTime date;
  final String aroma; // Notes d'arôme de l'utilisateur
  final String flavor; // Notes de saveur de l'utilisateur
  final double rating; // Note personnelle (ex: de 1.0 à 5.0)
  final String personalNotes; 

  TastingEntry({
    this.id,
    required this.wineId,
    required this.date,
    required this.aroma,
    required this.flavor,
    required this.rating,
    required this.personalNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wineId': wineId,
      'date': date.toIso8601String(), // Stocker comme string
      'aroma': aroma,
      'flavor': flavor,
      'rating': rating,
      'personalNotes': personalNotes,
    };
  }

  factory TastingEntry.fromMap(Map<String, dynamic> map) {
    return TastingEntry(
      id: map['id'] as int?,
      wineId: map['wineId'] as int,
      date: DateTime.parse(map['date'] as String),
      aroma: map['aroma'] as String,
      flavor: map['flavor'] as String,
      rating: map['rating'] as double,
      personalNotes: map['personalNotes'] as String,
    );
  }
}