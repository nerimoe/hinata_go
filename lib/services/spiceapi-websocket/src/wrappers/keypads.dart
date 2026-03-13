part of '../../spiceapi.dart';

Future<void> keypadsWrite(Connection con, int unit, String input) {
  final req = Request('keypads', 'write');
  req.addParam(unit);
  req.addParam(input);
  return con.request(req);
}

Future<void> keypadsSet(Connection con, int unit, String buttons) {
  final req = Request('keypads', 'set');
  req.addParam(unit);
  for (int i = 0; i < buttons.length; i++) {
    req.addParam(buttons[i]);
  }
  return con.request(req);
}

Future<String> keypadsGet(Connection con, int unit) async {
  final req = Request('keypads', 'get');
  req.addParam(unit);
  final res = await con.request(req);
  final buffer = StringBuffer();
  for (final obj in res.getData()) {
    buffer.write(obj);
  }
  return buffer.toString();
}
