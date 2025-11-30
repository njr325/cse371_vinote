import 'package:flutter/material.dart';
import '../models/tasting_entry.dart';
import '../services/database_service.dart';
import 'add_entry_screen.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final DatabaseService _dbService = DatabaseService();
  late Future<List<TastingEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    // Charge les entrées au démarrage de l'écran
    _entriesFuture = _dbService.getEntries();
  }

  // Force le rechargement de la liste (utilisé après l'ajout ou la suppression)
  void _refreshJournal() {
    setState(() {
      _entriesFuture = _dbService.getEntries();
    });
  }

  void _deleteEntry(int id) async {
    await _dbService.deleteEntry(id);
    _refreshJournal(); // Recharger la liste après suppression
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrée supprimée du journal.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<TastingEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Votre journal est vide. Scannez une étiquette pour commencer!',
                textAlign: TextAlign.center,
              ),
            );
          } else {
            // Affichage de la liste des entrées
            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final entry = snapshot.data![index];
                return Dismissible(
                  key: Key(entry.id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteEntry(entry.id!);
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: Text(entry.rating.toStringAsFixed(1)),
                      ),
                      title: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${entry.region} - ${entry.vintage}\n${entry.notes}'),
                      isThreeLine: true,
                      onTap: () {
                        // Ici, vous pourriez naviguer vers un écran de détail
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // Bouton flottant pour ajouter manuellement (optionnel)
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Naviguer vers l'écran d'ajout et rafraîchir en retour
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          );
          _refreshJournal();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}