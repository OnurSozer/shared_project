import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';

class NoteDatabase {
  static final NoteDatabase instance = NoteDatabase._init();
  static Database? _database;

  NoteDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Increment version for changes
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('CREATE TABLE categories (name TEXT PRIMARY KEY)');
          await db.execute(
              'ALTER TABLE notes ADD COLUMN category TEXT NOT NULL DEFAULT "General"');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
  CREATE TABLE notes ( 
    id $idType, 
    title $textType,
    content $textType,
    category $textType,  // Store category as a string in the notes table
    isChecked $boolType
  )
  ''');

    await db.execute('''
  CREATE TABLE categories ( 
    name $textType PRIMARY KEY  // Create a table for categories
  )
  ''');
  }

  Future<void> create(Note note) async {
    final db = await instance.database;
    await db.insert('notes', {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'isChecked': note.isChecked ? 1 : 0,
    });
  }

  Future<void> addCategory(String category) async {
    final db = await instance.database;
    await db.insert('categories', {'name': category});
  }

  Future<List<String>> readAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result
        .map((json) => Note(
              id: json['id'] as String,
              title: json['title'] as String,
              content: json['content'] as String,
              category: json['category'] as String, 
              isChecked:
                  json['isChecked'] == 1, // Convert integer (1 or 0) to boolean
            ))
        .toList();
  }

  Future<void> update(Note note) async {
    final db = await instance.database;

    await db.update(
      'notes',
      {
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'isChecked': note.isChecked ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<void> delete(String id) async {
    final db = await instance.database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
