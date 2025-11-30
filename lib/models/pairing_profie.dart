class PairingProfile {
  final String type;           // Ex: 'Vin Rouge Léger'
  final String description;    // Ex: 'Fruité, peu tannique et frais.'
  final List<String> pairings; // Ex: ['Volaille', 'Planches de charcuterie']
  final List<String> localDishes; // Suggestions de plats locaux français/européens
  final String icon;           // Icône ou emoji représentant le type

  PairingProfile({
    required this.type,
    required this.description,
    required this.pairings,
    required this.localDishes,
    required this.icon,
  });

  // Factory pour créer un objet à partir d'une Map (JSON)
  factory PairingProfile.fromMap(Map<String, dynamic> map) {
    return PairingProfile(
      type: map['type'] as String,
      description: map['description'] as String,
      // Les listes doivent être correctement castées
      pairings: List<String>.from(map['pairings'] as List),
      localDishes: List<String>.from(map['localDishes'] as List),
      icon: map['icon'] as String,
    );
  }
}