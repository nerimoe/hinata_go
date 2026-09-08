import 'dart:typed_data';

import 'package:cardcipher/bana.dart';

import 'card.dart';
import 'iso14443a.dart';

/// Canonical Banapass fields returned by a private cipher implementation.
///
/// The public cardcipher package deliberately leaves the implementation empty;
/// this value type keeps the application model independent from the cipher
/// representation and gives the private build a stable integration point.
class BanapassSectorFields {
  const BanapassSectorFields({
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

class BanapassAccessCodeFields {
  const BanapassAccessCodeFields({
    required this.serial,
    required this.keyNumber,
    required this.appData,
  });

  final int serial;
  final int keyNumber;
  final int appData;
}

/// Banapass domain object.
///
/// Physical blocks, Access Code and the canonical fields are alternate
/// serializations of one card. Construction accepts any representation, while
/// derivation and reverse derivation are kept on the object itself.
class Banapass extends Iso14443 implements HasAccessCode {
  Banapass(
    super.id,
    super.sak,
    super.atqa,
    Uint8List block1,
    Uint8List? block2, {
    String? persistedAccessCode,
    int? serial,
    int? keyNumber,
    int? unknown04,
    int? unknown06,
    int? appData,
    bool? dualKey,
    super.tags,
  }) : _storedBlock1 = _copy(block1),
       _storedBlock2 = _copy(block2),
       _persistedAccessCode = persistedAccessCode,
       _serial = serial,
       _keyNumber = keyNumber,
       _unknown04 = unknown04,
       _unknown06 = unknown06,
       _appData = appData,
       _dualKeyOverride = dualKey;

  Banapass.fromBlocks(
    Uint8List id,
    int sak,
    int atqa, {
    required Uint8List block1,
    Uint8List? block2,
    String? accessCode,
    int? serial,
    int? keyNumber,
    int? unknown04,
    int? unknown06,
    int? appData,
    bool? dualKey,
    List<CardTag> tags = const [],
  }) : this(
         id,
         sak,
         atqa,
         block1,
         block2,
         persistedAccessCode: accessCode,
         serial: serial,
         keyNumber: keyNumber,
         unknown04: unknown04,
         unknown06: unknown06,
         appData: appData,
         dualKey: dualKey,
         tags: tags,
       );

  Banapass.fromAccessCode(
    Uint8List id,
    int sak,
    int atqa, {
    required String accessCode,
    required bool dualKey,
    int? serial,
    int? keyNumber,
    int? unknown04,
    int? unknown06,
    int? appData,
    List<CardTag> tags = const [],
  }) : this.fromCanonical(
         id,
         sak,
         atqa,
         accessCode: accessCode,
         serial: serial,
         keyNumber: keyNumber,
         unknown04: unknown04,
         unknown06: unknown06,
         appData: appData,
         dualKey: dualKey,
         tags: tags,
       );

  Banapass.fromCanonical(
    super.id,
    super.sak,
    super.atqa, {
    Uint8List? block1,
    Uint8List? block2,
    String? accessCode,
    int? serial,
    int? keyNumber,
    int? unknown04,
    int? unknown06,
    int? appData,
    bool? dualKey,
    super.tags = const [],
  }) : _storedBlock1 = _copy(block1),
       _storedBlock2 = _copy(block2),
       _persistedAccessCode = accessCode,
       _serial = serial,
       _keyNumber = keyNumber,
       _unknown04 = unknown04,
       _unknown06 = unknown06,
       _appData = appData,
       _dualKeyOverride = dualKey;

  final Uint8List? _storedBlock1;
  final Uint8List? _storedBlock2;
  final String? _persistedAccessCode;
  final int? _serial;
  final int? _keyNumber;
  final int? _unknown04;
  final int? _unknown06;
  final int? _appData;
  final bool? _dualKeyOverride;

  /// The effective first block, derived from canonical fields when available.
  Uint8List? get effectiveBlock1 =>
      _copy(_storedBlock1) ?? _deriveBlock1FromFields();

  /// The effective second block. Single-key cards intentionally have no block2.
  Uint8List? get effectiveBlock2 {
    if (!dualKey) return null;
    if (_storedBlock2 != null) return _copy(_storedBlock2);
    return _deriveBlock2FromAccessCode();
  }

  /// Legacy accessor retained for callers that already have a physical block.
  /// Canonical-only cards return an empty block when the private implementation
  /// is unavailable; the write path validates this and reports a clear error.
  Uint8List get block1 => effectiveBlock1 ?? Uint8List(0);

  Uint8List? get block2 => effectiveBlock2;

  String get block1Hex => _hex(effectiveBlock1);

  String get block2Hex => _hex(effectiveBlock2);

  @override
  String? get accessCodeString =>
      _persistedAccessCode ??
      _accessCodeFromBlock2() ??
      _legacyAccessCodeFromBlock1() ??
      _deriveAccessCodeFromFields();

  int? get serial =>
      _serial ?? _sectorFields?.serial ?? _accessCodeFields?.serial;

  int? get keyNumber =>
      _keyNumber ?? _sectorFields?.keyNumber ?? _accessCodeFields?.keyNumber;

  int? get unknown04 => _unknown04 ?? _sectorFields?.unknown04;

  int? get unknown06 => _unknown06 ?? _sectorFields?.unknown06;

  int? get appData => _appData ?? _accessCodeFields?.appData;

  bool get dualKey =>
      _dualKeyOverride ?? _storedBlock2 != null || _storedBlock1 == null;

  @override
  String get showedValue =>
      accessCodeString?.toUpperCase() ?? idString.toUpperCase();

  @override
  String get name => 'Banapass';

  @override
  String? get type => 'banapass';

  @override
  String? get gamePayload => '$block1Hex$block2Hex';

  @override
  Map<String, dynamic> toJson() {
    final resolvedBlock1 = effectiveBlock1;
    final resolvedBlock2 = effectiveBlock2;
    final accessCode = accessCodeString;
    final resolvedSerial = serial;
    final resolvedKeyNumber = keyNumber;
    final resolvedUnknown04 = unknown04;
    final resolvedUnknown06 = unknown06;
    final resolvedAppData = appData;

    final payload = <String, dynamic>{
      ...super.toJson(),
      'block1': resolvedBlock1 == null ? null : _hex(resolvedBlock1),
      'block2': resolvedBlock2 == null ? null : _hex(resolvedBlock2),
    };
    if (accessCode != null) payload['accessCode'] = accessCode;
    if (resolvedSerial != null) payload['serial'] = resolvedSerial;
    if (resolvedKeyNumber != null) payload['keyNumber'] = resolvedKeyNumber;
    if (resolvedUnknown04 != null) payload['unknown04'] = resolvedUnknown04;
    if (resolvedUnknown06 != null) payload['unknown06'] = resolvedUnknown06;
    if (resolvedAppData != null) payload['appData'] = resolvedAppData;
    if (_dualKeyOverride != null) payload['dualKey'] = dualKey;
    return payload;
  }

  /// Serializes the card for the structured remote packet while keeping the
  /// pre-canonical Banapass field set available to older DLLs.
  Map<String, dynamic> toRemoteJson({required bool includeCanonicalFields}) {
    if (includeCanonicalFields) {
      return toJson();
    }

    final resolvedBlock1 = effectiveBlock1;
    if (resolvedBlock1 == null || resolvedBlock1.length != 16) {
      throw const FormatException(
        'Banapass block1 cannot be reconstructed for the remote DLL',
      );
    }
    final resolvedBlock2 = effectiveBlock2;
    return {
      ...super.toJson(),
      'block1': _hex(resolvedBlock1),
      'block2': resolvedBlock2 == null ? null : _hex(resolvedBlock2),
      if (accessCodeString != null) 'accessCode': accessCodeString,
    };
  }

  factory Banapass.fromJson(Map<String, dynamic> json) {
    final iso = Iso14443.fromJson(json);
    return Banapass.fromCanonical(
      iso.id,
      iso.sak,
      iso.atqa,
      block1: _parseOptionalBlock(json['block1']),
      block2: _parseOptionalBlock(json['block2']),
      accessCode: json['accessCode'] as String?,
      serial: json['serial'] as int?,
      keyNumber: json['keyNumber'] as int?,
      unknown04: json['unknown04'] as int?,
      unknown06: json['unknown06'] as int?,
      appData: json['appData'] as int?,
      dualKey: json['dualKey'] as bool?,
      tags: iso.tags,
    );
  }

  BanapassSectorFields? get _sectorFields {
    final block = _storedBlock1;
    if (block == null || block.length != 16) return null;
    final decoded = BanapassCipher.decodeSector(block);
    return decoded == null
        ? null
        : BanapassSectorFields(
            serial: decoded.serial,
            keyNumber: decoded.keyNumber,
            unknown04: decoded.unknown04,
            unknown06: decoded.unknown06,
          );
  }

  BanapassAccessCodeFields? get _accessCodeFields {
    final code = _decodableAccessCode;
    if (code == null) return null;
    final decoded = BanapassCipher.decodeAccessCode(code);
    return decoded == null
        ? null
        : BanapassAccessCodeFields(
            serial: decoded.serial,
            keyNumber: decoded.keyNumber,
            appData: decoded.appData,
          );
  }

  String? get _decodableAccessCode =>
      _persistedAccessCode ??
      _accessCodeFromBlock2() ??
      _legacyAccessCodeFromBlock1();

  String? _legacyAccessCodeFromBlock1() {
    final block = _storedBlock1;
    if (block == null || block.length != 16) return null;
    try {
      return nbgiGetAccessCode(block)?.accessCode;
    } catch (_) {
      return null;
    }
  }

  String? _accessCodeFromBlock2() {
    final block = _storedBlock2;
    if (block == null || block.length != 16) return null;
    final code = _hex(block.sublist(6, 16));
    return RegExp(r'^\d{20}$').hasMatch(code) ? code : null;
  }

  String? _deriveAccessCodeFromFields() {
    final resolvedSerial = _serial;
    final resolvedKeyNumber = _keyNumber;
    if (resolvedSerial == null || resolvedKeyNumber == null) return null;
    return BanapassCipher.encodeAccessCode(
      serial: resolvedSerial,
      keyNumber: resolvedKeyNumber,
      appData: _appData ?? 0,
    );
  }

  Uint8List? _deriveBlock1FromFields() {
    final resolvedSerial = serial;
    final resolvedKeyNumber = keyNumber;
    if (resolvedSerial == null || resolvedKeyNumber == null) return null;
    return BanapassCipher.encodeSector(
      serial: resolvedSerial,
      keyNumber: resolvedKeyNumber,
      unknown04: unknown04 ?? 0,
      unknown06: unknown06 ?? 3,
    );
  }

  Uint8List? _deriveBlock2FromAccessCode() {
    final accessCode = accessCodeString;
    if (accessCode == null || !RegExp(r'^\d{20}$').hasMatch(accessCode)) {
      return null;
    }
    final accessBytes = ICCard.hexToBytes(accessCode);
    if (accessBytes.length != 10) return null;
    final block = Uint8List(16);
    block.setRange(6, 16, accessBytes);
    return block;
  }

  static Uint8List? _parseOptionalBlock(Object? value) {
    if (value is! String || value.isEmpty) return null;
    try {
      return ICCard.hexToBytes(value);
    } catch (_) {
      return null;
    }
  }

  static Uint8List? _copy(Uint8List? value) =>
      value == null ? null : Uint8List.fromList(value);

  static String _hex(Uint8List? value) =>
      value?.map((e) => e.toRadixString(16).padLeft(2, '0')).join() ?? '';
}

extension ToBanapass on Iso14443 {
  Banapass toBanapass(
    Uint8List block1,
    Uint8List? block2, {
    List<CardTag>? tags,
  }) => Banapass.fromBlocks(
    id,
    sak,
    atqa,
    block1: block1,
    block2: block2,
    tags: tags ?? this.tags,
  );
}
