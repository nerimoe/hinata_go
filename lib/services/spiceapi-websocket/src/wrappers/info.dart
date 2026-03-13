part of '../../spiceapi.dart';

Future<Map<String, dynamic>> infoAVS(Connection con) async {
  final req = Request('info', 'avs');
  final res = await con.request(req);
  return Map<String, dynamic>.from(res.getData()[0] as Map);
}

Future<Map<String, dynamic>> infoLauncher(Connection con) async {
  final req = Request('info', 'launcher');
  final res = await con.request(req);
  return Map<String, dynamic>.from(res.getData()[0] as Map);
}

Future<Map<String, dynamic>> infoMemory(Connection con) async {
  final req = Request('info', 'memory');
  final res = await con.request(req);
  return Map<String, dynamic>.from(res.getData()[0] as Map);
}
