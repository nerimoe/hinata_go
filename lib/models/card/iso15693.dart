import 'card.dart';

class Iso15693 extends ICCard {
  Iso15693(super.id);

  @override
  String get name => 'ISO15693 Card';

  @override
  String? get type => 'iso15693';

  @override
  String? get value => idString;

  factory Iso15693.fromJson(Map<String, dynamic> json) {
    return Iso15693(ICCard.hexToBytes(json['id'] as String? ?? ''));
  }
}
