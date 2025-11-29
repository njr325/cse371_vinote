class Wine {
  final int? id; // ID dans la base de données SQLite
  final String labelName;
  final String grapeVariety;
  final String region;
  final int vintage;
  final String tastingNotesAI; // Notes génériques obtenues (après scan)

  Wine({
    this.id,
    required this.labelName,
    required this.grapeVariety,
    required this.region,
    required this.vintage,
    required this.tastingNotesAI,
  });

  // Convertir un Wine en Map pour l'enregistrement dans la DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'labelName': labelName,
      'grapeVariety': grapeVariety,
      'region': region,
      'vintage': vintage,
      'tastingNotesAI': tastingNotesAI,
    };
  }

  // Créer un Wine à partir d'un Map (lecture de la DB)
  factory Wine.fromMap(Map<String, dynamic> map) {
    return Wine(
      id: map['id'] as int?,
      labelName: map['labelName'] as String,
      grapeVariety: map['grapeVariety'] as String,
      region: map['region'] as String,
      vintage: map['vintage'] as int,
      tastingNotesAI: map['tastingNotesAI'] as String,
    );
  }
}