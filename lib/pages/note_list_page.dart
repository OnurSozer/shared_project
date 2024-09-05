import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/note_provider.dart';
import '../models/note.dart';

class NoteListPage extends StatefulWidget {
  @override
  _NoteListPageState createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  String selectedCategory = "All";
  
  @override
  void initState() {
    super.initState();
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    noteProvider.loadNotes();
    noteProvider.loadCategories();
  }

  // A method to display a dialog for adding a new note
  Future<void> _addNoteDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final categoryController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Note'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures the dialog is sized properly
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
              TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                final newNote = Note(
                  id: DateTime.now().toString(), // Unique id for each note
                  title: titleController.text,
                  content: contentController.text,
                  category: categoryController.text, 
                  isChecked: false,
                );
                Provider.of<NoteProvider>(context, listen: false)
                    .addNoteFromUser(newNote);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  // A method to display a dialog for updating an existing note
  Future<void> _updateNoteDialog(BuildContext context, Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    final categoryController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                final updatedNote = Note(
                  id: note.id,
                  title: titleController.text,
                  content: contentController.text,
                  category: categoryController.text,
                  isChecked: note.isChecked, // Preserve the checkmark status
                );
                Provider.of<NoteProvider>(context, listen: false)
                    .updateNote(updatedNote);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context);
    final notesToShow = selectedCategory == "All"
        ? noteProvider.notes
        : noteProvider.notes.where((note) => note.category == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notlar'),
      ),
      body: Column(
        children: [
          // Category selection dropdown that spans the full width
          Container(
            padding: const EdgeInsets.fromLTRB(30,0,30,0),
            child: DropdownButton<String>(
              isExpanded: true, // Make sure the dropdown itself can expand
              value: selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue!;
                });
              },
              items: <String>['All', ...noteProvider.categories]
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: notesToShow.isEmpty
                ? const Center(child: Text('No notes available.'))
                : ListView.builder(
                    itemCount: notesToShow.length,
                    itemBuilder: (context, index) {
                      final note = notesToShow[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.content),
                        leading: Checkbox(
                          value: note.isChecked,
                          onChanged: (bool? value) {
                            final updatedNote = Note(
                              id: note.id,
                              title: note.title,
                              content: note.content,
                              category: note.category, 
                              isChecked: value!,
                            );
                            noteProvider.updateNote(updatedNote);
                          },
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            noteProvider.deleteNote(note.id);
                          },
                        ),
                        onTap: () => _updateNoteDialog(context, note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNoteDialog(context); // Open the add note dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
