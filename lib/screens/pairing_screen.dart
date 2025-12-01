import 'package:flutter/material.dart';
import '../services/pairing_logic_service.dart';
import '../models/wine.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  final PairingLogicService _pairingService = PairingLogicService();
  Map<String, List<String>> _suggestions = {};
  bool _isLoading = true;

  // Simuler un vin pour la démo
  final Wine _testWine = Wine(
    labelName: 'Un Grand Vin Rouge Corsé',
    grapeVariety: 'Cabernet Sauvignon',
    region: 'Napa Valley',
    vintage: 2019,
    tastingNotesAI: 'Notes de cerise noire et de chêne.',
  );

  @override
  void initState() {
    super.initState();
    _fetchPairings();
  }

  void _fetchPairings() async {
    setState(() {
      _isLoading = true;
    });
    
    final results = await _pairingService.getPairingSuggestions(_testWine);
    
    setState(() {
      _suggestions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accords Suggérés pour : ${_testWine.labelName}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Profil de Saveur: ${_suggestions['profile_name']?.first ?? 'Inconnu'}',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.purple),
                  ),
                  const Divider(height: 30),

                  // 1. Suggestions Locales
                  _buildSuggestionSection(
                    context,
                    title: 'Plats Locaux Recommandés 🌍',
                    icon: Icons.location_on,
                    pairings: _suggestions['local']!,
                  ),
                  const SizedBox(height: 20),

                  // 2. Suggestions Générales
                  _buildSuggestionSection(
                    context,
                    title: 'Accords Classiques 🍽️',
                    icon: Icons.restaurant,
                    pairings: _suggestions['general']!,
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildSuggestionSection(BuildContext context, {required String title, required IconData icon, required List<String> pairings}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pairings.map((dish) => Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
            child: Text('• $dish', style: const TextStyle(fontSize: 16)),
          )).toList(),
        ),
      ],
    );
  }
}