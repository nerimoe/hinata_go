class CardFolder {
  final String id;
  final String name;

  CardFolder({required this.id, required this.name});

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }

  factory CardFolder.fromJson(Map<String, dynamic> json) {
    return CardFolder(id: json['id'] as String, name: json['name'] as String);
  }

  CardFolder copyWith({String? id, String? name}) {
    return CardFolder(id: id ?? this.id, name: name ?? this.name);
  }
}
