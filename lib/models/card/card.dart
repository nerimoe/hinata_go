import 'dart:typed_data';

class ICCard {
  final Uint8List id;
  ICCard(this.id);
  String get idString =>
      id.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
  String get name => "Generic IC Card";

  String? get type => null;

  String? get value => null;
}
