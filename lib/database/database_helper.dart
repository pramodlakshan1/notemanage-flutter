import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note_model.dart';

class DatabaseHelper {
  get note => null;

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'note.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, note_title TEXT NOT NULL, content  TEXT NOT NULL )",
        );
      },
      version: 1,
    );
  }

  Future<int> insertNote(Note notes) async {
    final db = await initializeDB();
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> retrieveNotes() async {
    final db = await initializeDB();
    final List<Map<String, dynamic>> maps = await db.query('notes');
    return List.generate(maps.length, (i) {
      return Note(
        id: maps[i]['id'],
        note_title: maps[i]['note_title'],
        content: maps[i]['content'],
      );
    });
  }

  Future<int> updateNote(Note note) async {
    final db = await initializeDB();
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  Future<int> deleteNote(int id) async {
    final db = await initializeDB();
    return await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
