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
    version: 2, // Increment the database version
    onCreate: _createDB,
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute('ALTER TABLE notes ADD COLUMN isChecked INTEGER NOT NULL DEFAULT 0');
      }
    },
  );
}


  Future _createDB(Database db, int version) async {
  const idType = 'TEXT PRIMARY KEY';
  const textType = 'TEXT NOT NULL';
  const boolType = 'INTEGER NOT NULL'; // Use INTEGER for boolean values

  await db.execute('''
CREATE TABLE notes ( 
  id $idType, 
  title $textType,
  content $textType,
  isChecked $boolType
  )
''');
}


  Future<void> create(Note note) async {
    final db = await instance.database;
    await db.insert('notes', {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'isChecked': note.isChecked ? 1 : 0,
    });
  }

  Future<List<Note>> readAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result 
        .map((json) => Note(
              id: json['id'] as String,
              title: json['title'] as String,
              content: json['content'] as String,
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
