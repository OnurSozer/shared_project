class Note {
  String id;
  String title;
  String content;
  bool isChecked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isChecked = false,
  });
}
