part of '../../spiceapi.dart';

Future<void> controlRaise(Connection con, String signal) {
  final req = Request('control', 'raise');
  req.addParam(signal);
  return con.request(req);
}

Future<void> controlExit(Connection con, int code) {
  final req = Request('control', 'exit');
  req.addParam(code);
  return con.request(req);
}

Future<void> controlRestart(Connection con) {
  final req = Request('control', 'restart');
  return con.request(req);
}

Future<void> controlRefreshSession(Connection con) async {
  final rnd = Random();
  final req = Request(
    'control',
    'session_refresh',
    id: rnd.nextInt(0x100000000),
  );
  final res = await con.request(req);
  con.changePass(res.getData()[0] as String);
}

Future<void> controlShutdown(Connection con) {
  final req = Request('control', 'shutdown');
  return con.request(req);
}

Future<void> controlReboot(Connection con) {
  final req = Request('control', 'reboot');
  return con.request(req);
}
