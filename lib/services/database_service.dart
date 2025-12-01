import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tasting_entry.dart';
import '../models/wine.dart';

class DatabaseService {
  static Database? _database;
  static const String tastingTableName = 'tasting_journal';
  static const String wineTableName = 'wines';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vinote_journal.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Crée les deux tables : Vins et Entrées de Dégustation
  Future<void> _createDB(Database db, int version) async {
    // 1. Table des Vins
    await db.execute('''
      CREATE TABLE $wineTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        labelName TEXT NOT NULL,
        grapeVariety TEXT,
        region TEXT,
        vintage INTEGER,
        tastingNotesAI TEXT
      )
    ''');
    
    // 2. Table du Journal (avec les nouveaux champs et la clé étrangère)
    await db.execute('''
      CREATE TABLE $tastingTableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        wineId INTEGER NOT NULL, 
        name TEXT NOT NULL,
        region TEXT NOT NULL,
        vintage INTEGER NOT NULL,
        rating REAL NOT NULL,
        aroma TEXT, 
        flavor TEXT, 
        personalNotes TEXT, 
        date TEXT NOT NULL,
        FOREIGN KEY (wineId) REFERENCES $wineTableName(id)
      )
    ''');
  }

  // --- Opérations CRUD ---

  // Insère un Vin (utilisé par add_entry_screen.dart pour obtenir l'ID)
  Future<int> insertWine(Wine wine) async {
    final db = await database;
    return await db.insert(
      wineTableName,
      wine.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Insère une nouvelle entrée de dégustation
  Future<int> insertTastingEntry(TastingEntry entry) async {
    final db = await database;
    return await db.insert(
      tastingTableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupère toutes les entrées du journal
  Future<List<TastingEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tastingTableName, 
      orderBy: 'date DESC', 
    );

    return List.generate(maps.length, (i) {
      return TastingEntry.fromMap(maps[i]);
    });
  }

  // Supprime une entrée par ID
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      tastingTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}