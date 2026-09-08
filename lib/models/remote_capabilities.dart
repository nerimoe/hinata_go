/// Capabilities advertised by a connected remote AimeIO DLL.
class RemoteCapabilities {
  const RemoteCapabilities({
    required this.cardProtocol,
    required this.clientVersion,
  });

  const RemoteCapabilities.legacy()
    : cardProtocol = 1,
      clientVersion = 'legacy';

  final int cardProtocol;
  final String clientVersion;

  /// Canonical Banapass fields are understood by the DLL released with the
  /// 1.1.1 structured-card model. Older DLLs still require block fields.
  bool get supportsCanonicalBanapass => _versionIsAtLeast(1, 1, 1);

  bool _versionIsAtLeast(int major, int minor, int patch) {
    final normalized = clientVersion.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final versionPart = normalized.split(RegExp(r'[+-]')).first;
    final numbers = versionPart
        .split('.')
        .map(int.tryParse)
        .toList(growable: false);
    if (numbers.length < 3 || numbers.any((value) => value == null)) {
      return false;
    }

    final required = [major, minor, patch];
    for (var index = 0; index < required.length; index++) {
      final current = numbers[index]!;
      if (current != required[index]) {
        return current > required[index];
      }
    }
    return true;
  }

  factory RemoteCapabilities.fromJson(Map<String, dynamic> json) {
    final rawProtocol = json['cardProtocol'] ?? json['card_protocol'];
    final protocol = switch (rawProtocol) {
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };
    final rawVersion = json['clientVersion'] ?? json['client_version'];

    return RemoteCapabilities(
      cardProtocol: protocol ?? 1,
      clientVersion: rawVersion is String && rawVersion.isNotEmpty
          ? rawVersion
          : 'legacy',
    );
  }

  factory RemoteCapabilities.fromResponseJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid remote capabilities response');
    }

    final rawAgents = value['agents'];
    if (rawAgents == null) {
      return RemoteCapabilities.fromJson(value);
    }
    if (rawAgents is! List || rawAgents.isEmpty) {
      throw const FormatException('No remote DLL is connected');
    }

    final agents = rawAgents
        .whereType<Map<String, dynamic>>()
        .map(RemoteCapabilities.fromJson)
        .toList(growable: false);
    if (agents.isEmpty) {
      throw const FormatException('Invalid remote capabilities response');
    }

    var lowestProtocol = agents.first.cardProtocol;
    final versions = <String>{};
    for (final agent in agents) {
      if (agent.cardProtocol < lowestProtocol) {
        lowestProtocol = agent.cardProtocol;
      }
      versions.add(agent.clientVersion);
    }

    return RemoteCapabilities(
      cardProtocol: lowestProtocol,
      clientVersion: versions.length == 1 ? versions.first : 'multiple',
    );
  }
}
