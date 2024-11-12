class Note {
  final int? id;
  final String note_title;
  final String content;

  Note({
    this.id,
    required this.note_title,
    required this.content,
  });

  Note.fromMap(Map<String, dynamic> res)
      : id = res["id"],
        note_title = res["note_title"],
        content = res["content"];


  Map<String, Object?> toMap() {
    return {
      'id': id,
      'note_title': note_title,
      'content': content,
    };
  }

  copyWith({required String note_title, required String content}) {}
}
