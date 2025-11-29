import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/wine.dart';
import '../models/tasting_entry.dart';
import 'add_entry_screen.dart'; // Import du nouvel écran de saisie

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final DatabaseService _dbService = DatabaseService();
  Future<List<Map<String, dynamic>>>? _journalFuture;

  @override
  void initState() {
    super.initState();
    _refreshJournal();
  }

  // Fonction pour recharger les données du journal
  void _refreshJournal() {
    setState(() {
      _journalFuture = _dbService.getJournalEntries();
    });
  }

  // Fonction pour naviguer vers l'écran d'ajout réel
  void _navigateToAddEntry() async {
    // Naviguer vers l'écran de formulaire et attendre le résultat
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        // Navigation vers l'écran de saisie (sans vin pré-rempli pour une saisie manuelle)
        builder: (context) => const AddEntryScreen(), 
      ),
    );

    // Si le résultat est 'true', cela signifie qu'une nouvelle entrée a été enregistrée.
    if (result == true) { 
      _refreshJournal(); // Recharger le journal pour afficher la nouvelle entrée
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mon Journal de Dégustation")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _journalFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Votre journal est vide. Ajoutez votre première dégustation !',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          final entries = snapshot.data!;
          
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: const Icon(Icons.wine_bar, color: Colors.purple),
                  title: Text('${entry['labelName']} (${entry['vintage']})'),
                  subtitle: Text(
                    'Note: ${entry['rating']} / 5.0 | Région: ${entry['region']}\n'
                    'Notes: ${entry['personalNotes']}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    // Formatage de la date
                    DateTime.parse(entry['date'].toString()).toLocal().toString().split(' ')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEntry,
        tooltip: 'Ajouter une dégustation',
        child: const Icon(Icons.add),
      ),
    );
  }
}