import 'card/card.dart';

class ScanLog {
  final String id;
  final String source; // 'NFC', 'QR', 'Direct'
  final ICCard card;
  final DateTime timestamp;
  final String? _legacyShowValue;

  ScanLog({
    required this.id,
    required this.source,
    required this.card,
    required this.timestamp,
    String? showValue,
  }) : _legacyShowValue = showValue;

  /// User-facing display value based on card type.
  String get showValue =>
      card.showedValue.isNotEmpty ? card.showedValue : (_legacyShowValue ?? '');

  // Backward compatibility getters
  String get value => card.gamePayload ?? '';
  String get apiType => card.type ?? 'unknown';
  String get displayType => card.name;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'card': card.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    final source = json['source'] as String;

    // Check if we have the new 'card' object or legacy fields
    ICCard card;
    if (json.containsKey('card')) {
      card = ICCard.fromJson(json['card'] as Map<String, dynamic>);
    } else {
      // Legacy reconstruction
      final apiType =
          json['apiType'] as String? ?? json['nfcType'] as String? ?? source;
      final value = json['value'] as String? ?? '';
      card = ICCard.fromTypeAndValue(apiType, value);
    }

    return ScanLog(
      id: json['id'] as String,
      source: source,
      card: card,
      timestamp: DateTime.parse(json['timestamp'] as String),
      showValue: json['showValue'] as String?,
    );
  }
}
