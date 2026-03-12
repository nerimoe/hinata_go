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

    try {
      SpiceApiEndpoint.parse(url);
      return true;
    } on FormatException {
      return false;
    }
  }
}
