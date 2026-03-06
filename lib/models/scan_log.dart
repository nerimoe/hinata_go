class ScanLog {
  final String id;
  final String value;
  final String source; // 'NFC', 'QR', 'Direct'
  final String? nfcType; // 'NfcA', 'NfcF', etc. (if source is NFC)
  final DateTime timestamp;

  ScanLog({
    required this.id,
    required this.value,
    required this.source,
    this.nfcType,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'source': source,
      'nfcType': nfcType,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanLog.fromJson(Map<String, dynamic> json) {
    return ScanLog(
      id: json['id'] as String,
      value: json['value'] as String,
      source: json['source'] as String,
      nfcType: json['nfcType'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
