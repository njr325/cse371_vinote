import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart'; // Importez votre écran d'accueil

class AgeGateScreen extends StatefulWidget {
  const AgeGateScreen({super.key});

  @override
  State<AgeGateScreen> createState() => _AgeGateScreenState();
}

class _AgeGateScreenState extends State<AgeGateScreen> {
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;
  String _message = 'Veuillez entrer votre date de naissance pour vérifier l\'âge légal.';

  // Affiche un sélecteur de date (date picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(DateTime.now().year - 21), // Initialiser à 21 ans en arrière
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _message = 'Date sélectionnée: ${_selectedDate!.toLocal().toString().split(' ')[0]}';
      });
    }
  }

  // Lance la vérification de l'âge
  void _submitAge(BuildContext context) async {
    if (_selectedDate == null) {
      setState(() {
        _message = 'Veuillez sélectionner une date de naissance.';
      });
      return;
    }

    // Montrer un indicateur de chargement pendant la vérification de la géolocalisation
    setState(() {
      _message = 'Vérification de la conformité légale en cours...';
    });

    final int requiredAge = await _authService.verifyLegalAge(_selectedDate!);

    if (requiredAge > 0) {
      // Succès: L'utilisateur est conforme.
      // Naviguer vers l'écran principal (Home)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      // Échec: L'utilisateur n'a pas l'âge légal.
      setState(() {
        final int userAge = _authService._calculateAge(_selectedDate!);
        _message = 'Accès refusé. Vous avez $userAge ans. L\'âge légal requis est de 21 ans (par défaut) ou celui de votre région.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bienvenue sur Vinote')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.wine_bar, size: 80, color: Colors.purple),
              const SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(color: requiredAge > 0 ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: const Text('Sélectionner ma Date de Naissance'),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Date de naissance: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.verified_user),
                  label: const Text('Confirmer et Accéder'),
                  onPressed: () => _submitAge(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}