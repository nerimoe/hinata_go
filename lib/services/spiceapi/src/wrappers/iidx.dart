part of '../../spiceapi.dart';

Future<String> iidxTickerGet(Connection con) async {
  final req = Request('iidx', 'ticker_get');
  final res = await con.request(req);
  return res.getData()[0] as String;
}

Future<void> iidxTickerSet(Connection con, String text) {
  final req = Request('iidx', 'ticker_set');
  req.addParam(text);
  return con.request(req);
}

Future<void> iidxTickerReset(Connection con) {
  final req = Request('iidx', 'ticker_reset');
  return con.request(req);
}
