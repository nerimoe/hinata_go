import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_go/models/card/banapass.dart';
import 'package:hinata_go/models/card/card.dart';

void main() {
  final card = Banapass(
    Uint8List.fromList([1, 2, 3, 4]),
    8,
    0x0400,
    Uint8List(16),
    null,
  );

  test('serializes with the Banapass domain type', () {
    expect(card.toJson()['type'], 'banapass');
  });

  test('still reads legacy Mifare payloads', () {
    final decoded = ICCard.fromJson({...card.toJson(), 'type': 'mifare'});

    expect(decoded, isA<Banapass>());
  });

  test('reconstructs Access Code from a physical dual-key block', () {
    final physicalBlock2 = ICCard.hexToBytes(
      '00000000000030746056644448171490',
    );
    final reconstructed = Banapass.fromBlocks(
      card.id,
      card.sak,
      card.atqa,
      block1: Uint8List(16),
      block2: physicalBlock2,
    );

    expect(reconstructed.dualKey, isTrue);
    expect(reconstructed.accessCodeString, '30746056644448171490');
    expect(reconstructed.toJson()['accessCode'], '30746056644448171490');
  });

  test('keeps canonical construction and single-key intent', () {
    final reconstructed = Banapass.fromAccessCode(
      card.id,
      card.sak,
      card.atqa,
      accessCode: '30746056644448171490',
      serial: 205050,
      keyNumber: 6,
      unknown04: 0,
      unknown06: 3,
      appData: 0,
      dualKey: false,
    );

    expect(reconstructed.serial, 205050);
    expect(reconstructed.keyNumber, 6);
    expect(reconstructed.dualKey, isFalse);
    expect(reconstructed.effectiveBlock2, isNull);
    expect(reconstructed.toJson(), containsPair('serial', 205050));
    expect(reconstructed.toJson(), containsPair('keyNumber', 6));
    expect(reconstructed.toJson(), containsPair('dualKey', false));
  });

  test('treats a flat Access Code as an access-code-only card', () {
    final reconstructed =
        ICCard.fromTypeAndValue('banapass', '30746056644448171490') as Banapass;

    expect(reconstructed.dualKey, isTrue);
    expect(reconstructed.effectiveBlock2, hasLength(16));
    expect(reconstructed.effectiveBlock1, isNull);
  });
}
