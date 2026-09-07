import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ArcadeLinkInvocationService extends ChangeNotifier {
  ArcadeLinkInvocationService._();

  static final ArcadeLinkInvocationService instance =
      ArcadeLinkInvocationService._();

  static const _channel = MethodChannel('moe.neri.hinatago/arcadelink');

  String? _pendingPublicId;
  bool _initialized = false;

  String? get pendingPublicId => _pendingPublicId;

  void initialize() {
    if (_initialized || kIsWeb) return;
    _initialized = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'invocation' && call.arguments is String) {
        handleURL(call.arguments as String);
      }
    });
  }

  void handleURL(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.toLowerCase() != 'https') return;
    if (uri.host.toLowerCase() != 'link.neri.moe') return;
    if (uri.pathSegments.length != 2 || uri.pathSegments.first != 't') {
      return;
    }

    final publicId = uri.pathSegments.last;
    if (publicId.isEmpty || publicId.length > 80) return;
    _pendingPublicId = publicId;
    notifyListeners();
  }

  void clear() {
    if (_pendingPublicId == null) return;
    _pendingPublicId = null;
    notifyListeners();
  }
}

final arcadeLinkInvocationProvider = Provider<ArcadeLinkInvocationService>((
  ref,
) {
  return ArcadeLinkInvocationService.instance;
});
