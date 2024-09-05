import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/note_database.dart';

class NoteProvider extends ChangeNotifier {
  List<Note> _notes = [];
  List<String> _categories = [];

  List<Note> get notes => _notes;
  List<String> get categories => _categories;

  Future<void> loadNotes() async {
    _notes = await NoteDatabase.instance.readAllNotes();
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await NoteDatabase.instance.readAllCategories();
    notifyListeners();
  }

  Future<void> addNoteFromUser(Note newNote) async {
    await NoteDatabase.instance.create(newNote);
    _notes.add(newNote);
    await _addCategoryIfNew(newNote.category);
    notifyListeners(); // This will notify the UI to update
  }

  Future<void> _addCategoryIfNew(String category) async {
    if (!_categories.contains(category)) {
      await NoteDatabase.instance.addCategory(category);
      _categories.add(category);
    }
  }

  Future<void> updateNote(Note note) async {
    await NoteDatabase.instance.update(note);
    int index = _notes.indexWhere((n) => n.id == note.id);
    _notes[index] = note;
    notifyListeners();
  }


  Future<void> deleteNote(String id) async {
    await NoteDatabase.instance.delete(id);
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
}
