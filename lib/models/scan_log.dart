class ScanLog {
  final String id;
  final String value;
  final String showValue;
  final String source; // 'NFC', 'QR', 'Direct'
  final String apiType;
  final String displayType;
  final DateTime timestamp;

  ScanLog({
    required this.id,
    required this.value,
    required this.showValue,
    required this.source,
    required this.apiType,
    required this.displayType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'showValue': showValue,
      'source': source,
      'apiType': apiType,
      'displayType': displayType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    final legacyNfcType = json['nfcType'] as String?;
    final source = json['source'] as String;

    // Migrate old nfcType -> displayType/apiType fallback
    final apiType = json['apiType'] as String? ?? legacyNfcType ?? source;
    final displayType =
        json['displayType'] as String? ?? legacyNfcType ?? source;

    return ScanLog(
      id: json['id'] as String,
      value: json['value'] as String,
      showValue: json['showValue'] as String? ?? json['value'] as String,
      source: source,
      apiType: apiType,
      displayType: displayType,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
