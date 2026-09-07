import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

http.Client createArcadeLinkHttpClient() =>
    BrowserClient()..withCredentials = true;
