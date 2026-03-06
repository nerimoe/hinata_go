class BagCard {
  final String id;
  final String name;
  final String value;
  final String folderId;

  BagCard({
    required this.id,
    required this.name,
    required this.value,
    required this.folderId,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'value': value, 'folderId': folderId};
  }

  factory BagCard.fromJson(Map<String, dynamic> json) {
    return BagCard(
      id: json['id'] as String,
      name: json['name'] as String,
      value: json['value'] as String,
      folderId: json['folderId'] as String,
    );
  }

  BagCard copyWith({
    String? id,
    String? name,
    String? value,
    String? folderId,
  }) {
    return BagCard(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      folderId: folderId ?? this.folderId,
    );
  }
}
