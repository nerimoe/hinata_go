/// Capabilities advertised by a connected remote AimeIO DLL.
class RemoteCapabilities {
  const RemoteCapabilities({required this.clientVersion});

  const RemoteCapabilities.legacy() : clientVersion = 'legacy';

  final String clientVersion;

  /// Canonical Banapass fields are understood by the DLL released with the
  /// 1.1.3 structured-card model. Older DLLs still require block fields.
  bool get supportsCanonicalBanapass => _versionIsAtLeast(1, 1, 3);

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
    final rawVersion = json['clientVersion'] ?? json['client_version'];

    return RemoteCapabilities(
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

    final versions = <String>{};
    for (final agent in agents) {
      versions.add(agent.clientVersion);
    }

    return RemoteCapabilities(
      clientVersion: versions.length == 1 ? versions.first : 'multiple',
    );
  }
}
