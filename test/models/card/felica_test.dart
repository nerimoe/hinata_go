import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_go/models/card/felica.dart';

void main() {
  group('Felica Model Tests', () {
    test('computes fakeAccessCode correctly from id (IDm)', () {
      final idm = Uint8List.fromList([
        0x01,
        0x2e,
        0x4a,
        0x90,
        0x12,
        0x34,
        0x56,
        0x78,
      ]);
      final pmm = Uint8List(8);
      final systemCode = Uint16List.fromList([0x88b4]);

      final card = Felica(idm, pmm, systemCode);

      expect(card.fakeAccessCodeString, '00085087425607784056');
      expect(card.fakeAccessCode, card.fakeAccessCodeString);
      expect(card.fakeAccessCode.length, 20);
    });

    test('serializes fakeAccessCode into toJson', () {
      final idm = Uint8List.fromList([
        0x01,
        0x2e,
        0x4a,
        0x90,
        0x12,
        0x34,
        0x56,
        0x78,
      ]);
      final pmm = Uint8List(8);
      final systemCode = Uint16List.fromList([0x88b4]);

      final card = Felica(idm, pmm, systemCode);
      final json = card.toJson();

      expect(json['fakeAccessCode'], '00085087425607784056');
    });
  });
}
