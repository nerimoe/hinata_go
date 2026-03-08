import 'dart:typed_data';

import 'felica.dart';

class Aic extends Felica {
  final Uint8List accessCode;
  Aic(super.id, super.pmm, super.systemCode, this.accessCode);

  String get accessCodeString =>
      accessCode.map((e) => e.toRadixString(16).padLeft(2, '0')).join();

  String get manufacturer {
    final prefix = accessCodeString.substring(0, 3);

    return switch (prefix) {
      '500' || '501' => 'SEGA',
      '510' => 'Bandai Namco',
      '520' => 'KONAMI',
      '530' => 'Taito',
      _ => 'Unknown',
    };
  }

  @override
  String get name => "Amusement IC";

  @override
  String? get type => "aic";

  @override
  String? get value => "$idString:$accessCodeString";
}

extension ToAIC on Felica {
  Aic toAic(Uint8List accessCode) => Aic(id, pmm, systemCode, accessCode);
}
