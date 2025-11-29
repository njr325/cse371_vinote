import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wine.dart';
import '../models/tasting_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Obtenir le chemin de la base de données
    String path = join(await getDatabasesPath(), 'vinote_journal.db');
    
    // Ouvrir la base de données et créer les tables si nécessaire
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // Crée les tables Wine et TastingEntry
  Future<void> _createTables(Database db, int version) async {
    // 1. Table Wine
    await db.execute('''
      CREATE TABLE wines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        labelName TEXT,
        grapeVariety TEXT,
        region TEXT,
        vintage INTEGER,
        tastingNotesAI TEXT
      )
    ''');

    // 2. Table TastingEntry (avec Clé Étrangère vers wines)
    await db.execute('''
      CREATE TABLE tasting_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wineId INTEGER,
        date TEXT,
        aroma TEXT,
        flavor TEXT,
        rating REAL,
        personalNotes TEXT,
        FOREIGN KEY (wineId) REFERENCES wines(id) ON DELETE CASCADE
      )
    ''');
  }

  // --- CRUD Opérations ---

  // Ajoute un nouveau vin et retourne son ID
  Future<int> insertWine(Wine wine) async {
    final db = await database;
    return await db.insert('wines', wine.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Ajoute une nouvelle entrée de journal
  Future<int> insertTastingEntry(TastingEntry entry) async {
    final db = await database;
    return await db.insert('tasting_entries', entry.toMap(), 
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Récupère toutes les entrées de dégustation avec les détails du vin
  Future<List<Map<String, dynamic>>> getJournalEntries() async {
    final db = await database;
    // Utilise une jointure pour récupérer toutes les données pertinentes
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        T.*, 
        W.labelName, W.region, W.grapeVariety, W.vintage 
      FROM tasting_entries T
      JOIN wines W ON T.wineId = W.id
      ORDER BY T.date DESC
    ''');
    return result;
  }
  
  // Implémentez d'autres fonctions (getWineById, deleteEntry, etc.) au besoin
}