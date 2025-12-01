// lib/models/pairing_profile.dart

class PairingProfile {
  final String id;
  final String name;
  final String description;

  PairingProfile({
    required this.id,
    required this.name,
    required this.description,
  });

  factory PairingProfile.fromMap(Map<String, dynamic> json) {
    return PairingProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}