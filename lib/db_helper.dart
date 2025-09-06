// lib/db_helper.dart
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  DBHelper._privateConstructor();
  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    await init();
    return _db!;
  }

  Future<void> init() async {
    if (_db != null) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(docsDir.path, 'notes_app.db');
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER,
        updated_at INTEGER,
        user_id INTEGER
      );
    ''');
  }

  // ---------- Users ----------
  Future<bool> hasAnyUser() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM users');
    final count = Sqflite.firstIntValue(res) ?? 0;
    return count > 0;
  }

  Future<Map<String, Object?>?> getUserByUsername(String username) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return res.first;
  }

  Future<int> createUser(String username, String password) async {
    final db = await database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  // ---------- Notes (CRUD) ----------
  Future<List<Map<String, dynamic>>> getNotes({int? userId}) async {
    final db = await database;
    if (userId != null) {
      return await db.query(
        'notes',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'updated_at DESC, created_at DESC',
      );
    } else {
      return await db.query(
        'notes',
        orderBy: 'updated_at DESC, created_at DESC',
      );
    }
  }

  Future<Map<String, dynamic>?> getNoteById(int id) async {
    final db = await database;
    final res = await db.query('notes', where: 'id = ?', whereArgs: [id], limit: 1);
    if (res.isEmpty) return null;
    return res.first;
  }


  Future<int> insertNote(Map<String, dynamic> note) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final toInsert = <String, dynamic>{
      'title': note['title'] ?? '',
      'content': note['content'] ?? '',
      'created_at': note['created_at'] ?? now,
      'updated_at': note['updated_at'] ?? now,
      'user_id': note['user_id'] ?? 0,
    };
    return await db.insert('notes', toInsert);
  }

  Future<int> updateNote(Map<String, dynamic> note) async {
    if (note['id'] == null) {
      throw ArgumentError('La note doit contenir une clé "id" pour la mise à jour.');
    }
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final toUpdate = <String, dynamic>{
      'title': note['title'] ?? '',
      'content': note['content'] ?? '',
      'updated_at': note['updated_at'] ?? now,
      'user_id': note['user_id'] ?? 0,
    };
    return await db.update('notes', toUpdate, where: 'id = ?', whereArgs: [note['id']]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
