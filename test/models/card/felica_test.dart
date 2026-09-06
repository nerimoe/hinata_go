import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_go/models/card/felica.dart';
import 'package:hinata_go/models/card/iso15693.dart';
import 'package:hinata_go/models/scan_log.dart';

void main() {
  group('Felica Model Tests', () {
    test('computes fakeAccessCode and epass correctly from id (IDm)', () {
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
      // In public builds cardcipher throws UnsupportedError and epass is null
      expect(card.epass, isNull);
    });

    test(
      'does not serialize pure derived fields (fakeAccessCode, epass) into toJson',
      () {
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

        expect(json.containsKey('fakeAccessCode'), isFalse);
        expect(json.containsKey('epass'), isFalse);

        final reconstructed = Felica.fromJson(json);
        expect(reconstructed.fakeAccessCode, '00085087425607784056');
        expect(reconstructed.epass, card.epass);
      },
    );
  });

  group('Iso15693 Model Tests', () {
    test('computes epass without serializing it', () {
      final uid = Uint8List.fromList([
        0xe0,
        0x04,
        0x01,
        0x08,
        0x12,
        0x34,
        0x56,
        0x78,
      ]);
      final card = Iso15693(uid);
      // In public builds cardcipher throws UnsupportedError and epass is null
      expect(card.epass, isNull);

      final json = card.toJson();
      expect(json.containsKey('epass'), isFalse);

      final reconstructed = Iso15693.fromJson(json);
      expect(reconstructed.epass, card.epass);
    });
  });

  group('ScanLog Model Tests', () {
    test('derives showValue dynamically and does not persist it in toJson', () {
      final idm = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
      final card = Felica(idm, Uint8List(8), Uint16List.fromList([0x88b4]));
      final log = ScanLog(
        id: 'test-log-1',
        source: 'NFC',
        card: card,
        timestamp: DateTime(2026, 1, 1),
      );

      expect(log.showValue, card.showedValue);

      final json = log.toJson();
      expect(json.containsKey('showValue'), isFalse);

      final reconstructed = ScanLog.fromJson(json);
      expect(reconstructed.showValue, card.showedValue);
    });

    test('supports legacy ScanLog json with showValue', () {
      final json = {
        'id': 'legacy-log',
        'source': 'NFC',
        'showValue': 'OLD_VALUE',
        'apiType': 'felica',
        'value': '0102030405060708',
        'timestamp': '2026-01-01T00:00:00.000',
      };

      final log = ScanLog.fromJson(json);
      expect(log.id, 'legacy-log');
      expect(log.showValue, 'OLD_VALUE');
    });
  });
}
