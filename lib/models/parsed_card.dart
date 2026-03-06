class ParsedCard {
  final String value;
  final String showValue;
  final String source; // 'NFC', 'QR', 'Direct'
  final String apiType; // 'aic', 'aime', 'mifare', 'QR', 'Direct'
  final String
  displayType; // 'Amusement IC', 'Aime', 'Banapass', 'QR Code', 'Manual Entry'

  const ParsedCard({
    required this.value,
    required this.showValue,
    required this.source,
    required this.apiType,
    required this.displayType,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'showValue': showValue,
      'source': source,
      'apiType': apiType,
      'displayType': displayType,
    };
  }

  factory ParsedCard.fromJson(Map<String, dynamic> json) {
    return ParsedCard(
      value: json['value'] as String,
      showValue: json['showValue'] as String? ?? json['value'] as String,
      source: json['source'] as String,
      apiType: json['apiType'] as String,
      displayType: json['displayType'] as String,
    );
  }
}
