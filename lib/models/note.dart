class Note {
  String id;
  String title;
  String content;
  String category; // Add category field
  bool isChecked;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category, // Initialize category in the constructor
    this.isChecked = false,
  });

  // Factory method to create a Note object from JSON (for database retrieval)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String, // Parse the category from JSON
      isChecked: json['isChecked'] == 1, // Convert int to bool
    );
  }

  // Method to convert Note object to JSON (for database storage)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category, // Store category in JSON
      'isChecked': isChecked ? 1 : 0, // Convert bool to int
    };
  }
}
