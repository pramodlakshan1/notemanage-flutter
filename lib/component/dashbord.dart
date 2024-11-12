import 'package:flutter/material.dart';
import 'package:note_manager/database/database_helper.dart';
import 'package:note_manager/model/note_model.dart';
import 'notepad.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  TextEditingController searchController = TextEditingController();
  final DatabaseHelper dbHelper = DatabaseHelper();

  void addOrEditNote(
      {String? initialTitle, String? initialContent, int? index}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Notepad(
          initialTitle: initialTitle,
          initialContent: initialContent,
        ),
      ),
    );

    if (result != null) {
      final newNote = Note(
        id: index != null ? notes[index].id : null,
        note_title: result['title'],
        content: result['content'],

      );

      if (index != null) {
        await dbHelper.updateNote(newNote);
        notes[index] = newNote;
      } else {
        await dbHelper.insertNote(newNote);
        // notes.add(newNote);
      }
      await loadNotes();
    }
  }

  void deleteNoteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Note"),
          content: const Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await dbHelper.deleteNote(notes[index].id!);
                setState(() {
                  notes.removeAt(index);
                  filteredNotes = notes;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Yes, delete it"),
            ),
          ],
        );
      },
    );
  }

  void searchNotes(String query) {
    final results = notes
        .where((note) =>
        note.note_title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {
      filteredNotes = results;
    });
  }

  @override
  void initState() {
    super.initState();
    loadNotes();
    // filteredNotes = notes;
    searchController.addListener(() {
      searchNotes(searchController.text);
    });
  }

  Future<void> loadNotes() async {
    notes = await dbHelper.retrieveNotes();
    setState(() {
      filteredNotes = notes;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black12,
      appBar: AppBar(
        backgroundColor: Colors.black26,
        title: const Text('Note List', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                filled: true,
                fillColor: Colors.black12,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2,
                ),
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => addOrEditNote(
                      initialTitle: filteredNotes[index].note_title,
                      initialContent: filteredNotes[index].content,
                      index: notes.indexOf(filteredNotes[index]),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.white),
                                  onPressed: () => addOrEditNote(
                                    initialTitle:
                                    filteredNotes[index].note_title,
                                    initialContent:
                                    filteredNotes[index].content,
                                    index: notes.indexOf(filteredNotes[index]),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () =>
                                      deleteNoteConfirmation(index),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text(
                              filteredNotes[index].note_title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addOrEditNote(), // Open Notepad for new note
        child: const Icon(Icons.add),
      ),
    );
  }
}