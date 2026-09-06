import 'package:cardcipher/epass.dart';

import 'card.dart';

class Iso15693 extends ICCard implements HasEPass {
  Iso15693(super.id, {super.tags});

  @override
  late final String? epass = _computeEpass();

  @override
  String get name => 'ISO15693 Card';

  @override
  String? get type => 'iso15693';

  @override
  String? get gamePayload => idString;

  factory Iso15693.fromJson(Map<String, dynamic> json) {
    return Iso15693(
      ICCard.hexToBytes(json['id'] as String? ?? ''),
      tags:
          (json['tags'] as List<dynamic>?)?.map(CardTag.fromJson).toList() ??
          const [],
    );
  }

  String? _computeEpass() {
    try {
      return EPass.encode(idString.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}
