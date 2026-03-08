import 'dart:typed_data';

import 'iso14443a.dart';

class Banapass extends Iso14443 {
  final Uint8List block1;
  final Uint8List? block2;
  Banapass(super.id, super.sak, super.atqa, this.block1, this.block2);

  @override
  String get name => "Banapass";

  @override
  String? get type => "mifare";

  @override
  String? get value => "$block1${block2 ?? "00000000000000000000000000000000"}";
}

extension ToBanapass on Iso14443 {
  Banapass toBanapass(Uint8List block1, Uint8List? block2) =>
      Banapass(id, sak, atqa, block1, block2);
}
