part of '../../spiceapi.dart';

Future<int> coinGet(Connection con) async {
  final req = Request('coin', 'get');
  final res = await con.request(req);
  return res.getData()[0] as int;
}

Future<void> coinSet(Connection con, int amount) {
  final req = Request('coin', 'set');
  req.addParam(amount);
  return con.request(req);
}

Future<void> coinInsert(Connection con, [int amount = 1]) {
  final req = Request('coin', 'insert');
  if (amount != 1) {
    req.addParam(amount);
  }
  return con.request(req);
}
