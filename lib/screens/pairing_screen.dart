import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vinote/models/pairing_profile.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  late Future<List<PairingProfile>> _pairingsFuture;

  @override
  void initState() {
    super.initState();
    _pairingsFuture = _loadPairingData();
  }

  // Charge le fichier JSON local
  Future<List<PairingProfile>> _loadPairingData() async {
    // 1. Charger la chaîne JSON du fichier
    final String response = await rootBundle.loadString('assets/wine_pairings.json');
    // 2. Décoder la chaîne en liste d'objets Map
    final List<dynamic> data = json.decode(response);
    // 3. Convertir chaque Map en objet PairingProfile
    return data.map((json) => PairingProfile.fromMap(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas besoin d'AppBar car elle est dans HomeScreen
      body: FutureBuilder<List<PairingProfile>>(
        future: _pairingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des accords : ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun profil d\'accord trouvé.'));
          }

          final profiles = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 15),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du Profil
                      Text(
                        '${profile.icon} ${profile.type}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Description
                      Text(
                        profile.description,
                        style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                      ),
                      const Divider(height: 20),
                      
                      // Accords Classiques
                      Text(
                        'Accords Classiques :',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade500),
                      ),
                      Text(profile.pairings.join(', ')),
                      const SizedBox(height: 10),

                      // Suggestions Locales
                      Text(
                        'Suggestions Locales 🇫🇷/🇪🇺 :',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple.shade500),
                      ),
                      Text(profile.localDishes.join(', ')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}