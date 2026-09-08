import 'dart:typed_data';

class NbgiAccessCodeResult {
  const NbgiAccessCodeResult(this.accessCode, this.serial);

  final String accessCode;
  final int serial;

  @override
  String toString() => "('$accessCode', $serial)";
}

/// Data-only integration types for the private Banapass implementation.
///
/// The public package intentionally contains no key material or cipher
/// implementation. A private build can provide the same API while keeping the
/// algorithm out of the public package.
class BanapassDecodedSector {
  const BanapassDecodedSector({
    required this.serial,
    required this.keyNumber,
    required this.unknown04,
    required this.unknown06,
  });

  final int serial;
  final int keyNumber;
  final int unknown04;
  final int unknown06;
}

class BanapassDecodedAccessCode {
  const BanapassDecodedAccessCode({
    required this.serial,
    required this.keyNumber,
    required this.appData,
  });

  final int serial;
  final int keyNumber;
  final int appData;
}

class BanapassCipher {
  const BanapassCipher._();

  static BanapassDecodedSector? decodeSector(Uint8List block1) => null;

  static BanapassDecodedAccessCode? decodeAccessCode(String accessCode) => null;

  static Uint8List? encodeSector({
    required int serial,
    required int keyNumber,
    required int unknown04,
    required int unknown06,
  }) => null;

  static String? encodeAccessCode({
    required int serial,
    required int keyNumber,
    required int appData,
  }) => null;
}

NbgiAccessCodeResult? nbgiGetAccessCode(Uint8List headerData) {
  return null;
}
