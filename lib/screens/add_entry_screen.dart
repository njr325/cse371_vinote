import 'package:flutter/material.dart';
import '../models/wine.dart';
import '../models/tasting_entry.dart';
import '../services/database_service.dart';

// Définition d'un widget de notation simple (étoiles)
class RatingStars extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const RatingStars({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        // La note est de 0 à 5, index va de 0 à 4
        final starValue = index + 1.0;
        final icon = starValue <= rating ? Icons.star : Icons.star_border;
        final color = starValue <= rating ? Colors.amber : Colors.grey;

        return IconButton(
          icon: Icon(icon, color: color, size: 30),
          onPressed: () => onRatingChanged(starValue),
        );
      }),
    );
  }
}


class AddEntryScreen extends StatefulWidget {
  // Optionnel: Passer un objet Wine si l'entrée est créée après un scan
  final Wine? prefilledWine;
  
  const AddEntryScreen({super.key, this.prefilledWine});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = DatabaseService();

  // Contrôleurs de formulaire pour les données du vin
  late TextEditingController _nameController;
  late TextEditingController _grapeController;
  late TextEditingController _regionController;
  late TextEditingController _vintageController;
  
  // Contrôleurs/Variables pour les notes de dégustation
  late TextEditingController _aromaController;
  late TextEditingController _flavorController;
  late TextEditingController _personalNotesController;
  double _rating = 0.0;
  DateTime _tastingDate = DateTime.now();
  
  // L'ID du vin si nous l'insérons d'abord
  int? _currentWineId;

  @override
  void initState() {
    super.initState();
    // Initialiser les contrôleurs, en utilisant les données pré-remplies si disponibles
    final wine = widget.prefilledWine;
    
    _nameController = TextEditingController(text: wine?.labelName ?? '');
    _grapeController = TextEditingController(text: wine?.grapeVariety ?? '');
    _regionController = TextEditingController(text: wine?.region ?? '');
    _vintageController = TextEditingController(text: wine?.vintage.toString() ?? '');
    
    // Initialiser les notes utilisateur
    _aromaController = TextEditingController();
    _flavorController = TextEditingController();
    _personalNotesController = TextEditingController();

    // Si le vin est pré-rempli, nous l'insérons en base immédiatement
    if (wine != null) {
      _insertPrefilledWine(wine);
    }
  }
  
  // Insère le vin scanné pour obtenir son ID avant l'enregistrement de l'entrée
  void _insertPrefilledWine(Wine wine) async {
    _currentWineId = await _dbService.insertEntry(wine);
  }

  // Gère la soumission du formulaire
  void _saveTastingEntry() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // 1. Si le vin n'était pas pré-rempli, insérer un nouvel enregistrement Wine
      if (_currentWineId == null) {
        final newWine = Wine(
          labelName: _nameController.text,
          grapeVariety: _grapeController.text,
          region: _regionController.text,
          vintage: int.tryParse(_vintageController.text) ?? 0,
          tastingNotesAI: 'Saisie manuelle', // Marquer comme manuel
        );
        _currentWineId = await _dbService.insertEntry(newWine);
      }
      
      if (_currentWineId == null) {
        // Gérer l'erreur d'insertion du vin
        return;
      }

      // 2. Créer et insérer l'Entrée de Dégustation
      final newEntry = TastingEntry(
        date: _tastingDate,
        aroma: _aromaController.text,
        flavor: _flavorController.text,
        rating: _rating,
        personalNotes: _personalNotesController.text,
      );

      await _dbService.insertEntry(newEntry);
      
      // Afficher un message de succès et fermer l'écran
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dégustation enregistrée avec succès !'))
      );
      Navigator.pop(context, true); // Retourner à l'écran précédent (Journal)
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _grapeController.dispose();
    _regionController.dispose();
    _vintageController.dispose();
    _aromaController.dispose();
    _flavorController.dispose();
    _personalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une Dégustation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            
            // --- Section Informations du Vin ---
            Text(
              'Informations sur le Vin (Modifiable)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom de l\'Étiquette'),
              validator: (value) => value!.isEmpty ? 'Veuillez entrer le nom du vin.' : null,
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _grapeController,
                    decoration: const InputDecoration(labelText: 'Cépage Principal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _vintageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Millésime'),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _regionController,
              decoration: const InputDecoration(labelText: 'Région / Appellation'),
            ),
            
            const Divider(height: 40),
            
            // --- Section Notes Personnelles ---
            Text(
              'Vos Notes de Dégustation',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            
            // 1. Notation Étoiles
            const Text('Votre Note (sur 5.0)'),
            RatingStars(
              rating: _rating,
              onRatingChanged: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
            ),

            // 2. Date de Dégustation
            ListTile(
              title: Text('Date : ${_tastingDate.toLocal().toString().split(' ')[0]}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _tastingDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _tastingDate = date;
                  });
                }
              },
            ),

            // 3. Notes détaillées
            TextFormField(
              controller: _aromaController,
              decoration: const InputDecoration(labelText: 'Arômes et Nez'),
              maxLines: 2,
            ),
            TextFormField(
              controller: _flavorController,
              decoration: const InputDecoration(labelText: 'Saveur et Bouche'),
              maxLines: 2,
            ),
            TextFormField(
              controller: _personalNotesController,
              decoration: const InputDecoration(labelText: 'Notes Personnelles et Accords'),
              maxLines: 4,
            ),
            
            const SizedBox(height: 30),
            
            // --- Bouton d'Enregistrement ---
            ElevatedButton.icon(
              onPressed: _saveTastingEntry,
              icon: const Icon(Icons.save),
              label: const Text('Enregistrer la Dégustation'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}