import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../model/note_model.dart';
import 'dashbord.dart';
// import 'package:intl/intl.dart';

class Notepad extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;

  const Notepad({super.key, this.initialTitle, this.initialContent});

  @override
  NotepadState createState() => NotepadState();
}

class NotepadState extends State<Notepad> {
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  // String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool _isChanged = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.initialTitle ?? '';
    noteController.text = widget.initialContent ?? '';
    titleController.addListener(_onTextChanged);
    noteController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {
      _isChanged = true;
    });
  }

  Future<void> saveNote() async {

    final DatabaseHelper dbHelper = DatabaseHelper();
    Note note = Note(
      note_title: titleController.text,
      content: noteController.text,
    );
    await dbHelper.insertNote(note);
    // Navigator.pop(context);
    Navigator.pop(context,titleController.text);
  }

  Future<bool> _onWillPop() async {
    if (!_isChanged) {
      return true;
    } else {
      return await _showConfirmationDialog(
        title: 'Unsaved Changes',
        content: 'You have unsaved changes. Do you want to go back without saving?',
      );
    }
  }

  Future<bool> _showConfirmationDialog({required String title, required String content}) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: const Text('Notepad', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
                icon: const Icon(Icons.save, color: Colors.white),
                onPressed: () async {
                  saveNote; {
                    Navigator.of(context).pop();
                  }
                }
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'Start writing your note...',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}