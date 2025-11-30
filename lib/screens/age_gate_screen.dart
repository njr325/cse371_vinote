import 'package:flutter/material.dart';
import '../services/location_service.dart'; // Nécessite le service de géolocalisation
import 'package:geolocator/geolocator.dart'; // Nécessite d'importer geolocator

// Interface de l'écran (doit accepter un callback en cas de succès)
class AgeGateScreen extends StatefulWidget {
  final VoidCallback onVerificationSuccess;

  const AgeGateScreen({super.key, required this.onVerificationSuccess});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  final LocationService _locationService = LocationService();
  DateTime? _selectedDate;
  String _message = 'Veuillez entrer votre date de naissance.';
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 21)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _verifyAge() async {
    if (_selectedDate == null) {
      setState(() {
        _message = "Veuillez choisir une date de naissance.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Vérification de la localisation et de l\'âge légal...';
    });

    try {
      // 1. Obtenir la localisation actuelle
      final Position position = await _locationService.getCurrentLocation();
      // 2. Récupérer le pays et l'âge légal (logique simplifiée)
      // NOTE: La logique réelle de service est dans LocationService.dart
      final int legalAge = await _locationService.getLegalDrinkingAge(
          position.latitude, position.longitude);

      // 3. Calculer l'âge de l'utilisateur
      final now = DateTime.now();
      final userAge = now.year - _selectedDate!.year;
      final bool isLegal = userAge >= legalAge;

      if (isLegal) {
        widget.onVerificationSuccess(); // Succès : passe à l'HomeScreen
      } else {
        setState(() {
          _message = 'Accès refusé. L\'âge légal requis est de $legalAge ans.';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Erreur: Impossible de vérifier la localisation/l\'âge légal.';
      });
      print('Erreur de vérification d\'âge: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vérification d'Âge"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _message,
              textAlign: TextAlign.center,
              style: TextStyle(color: _isLoading ? Colors.blue : Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
              ),
              child: Text(
                _selectedDate == null
                    ? 'Choisir Date de Naissance'
                    : 'Date choisie: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedDate != null && !_isLoading ? _verifyAge : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirmer l\'Âge et la Localisation'),
            ),
          ],
        ),
      ),
    );
  }
}