import '../models/remote_instance.dart';
import '../services/spiceapi/spiceapi.dart';

class Validators {
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.isScheme('http') || uri.isScheme('https')) &&
        uri.host.isNotEmpty;
  }

  static bool isValidInstanceUrl(String url, InstanceType type) {
    if (type == InstanceType.hinataIo) {
      return isValidUrl(url);
    }
    
    if (type == InstanceType.spiceApi) {
      return isValidSpiceApiUrl(url, allowWs: false);
    }

    if (type == InstanceType.spiceApiWebSocket) {
      return isValidSpiceApiUrl(url, allowWs: true);
    }
    
    return false;
  }

  static bool isValidSpiceApiUrl(String url, {required bool allowWs}) {
    try {
      SpiceApiEndpoint.parse(url);
      final uri = Uri.tryParse(url);
      if (uri != null) {
          if (allowWs) {
              return uri.isScheme('ws') || uri.isScheme('wss') || uri.isScheme('http') || uri.isScheme('https');
          } else {
              return uri.isScheme('tcp') || uri.isScheme('http') || uri.isScheme('https') || !url.contains('://');
          }
      }
      return true;
    } on FormatException {
      return false;
    }
  }
}
