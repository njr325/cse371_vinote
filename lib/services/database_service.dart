import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tasting_entry.dart';

class DatabaseService {
  static Database? _database;
  static const String tableName = 'tasting_journal';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    // Obtient le chemin où la DB doit être stockée
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vinote_journal.db');

    // Ouvre la base de données (crée le fichier s'il n'existe pas)
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Crée la table du journal lors de la première ouverture de la DB
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        region TEXT NOT NULL,
        vintage INTEGER NOT NULL,
        rating REAL NOT NULL,
        notes TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  // --- Opérations CRUD ---

  // Insère une nouvelle entrée dans le journal
  Future<int> insertEntry(TastingEntry entry) async {
    final db = await database;
    // La méthode 'insert' convertit la Map en ligne SQL
    return await db.insert(
      tableName,
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Récupère toutes les entrées du journal
  Future<List<TastingEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName, 
      orderBy: 'date DESC', // Trie par date récente
    );

    // Convertit la List<Map> en List<TastingEntry>
    return List.generate(maps.length, (i) {
      return TastingEntry.fromMap(maps[i]);
    });
  }

  // Supprime une entrée par ID
  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}