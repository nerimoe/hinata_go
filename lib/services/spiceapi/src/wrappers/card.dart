part of '../../spiceapi.dart';

Future<void> cardInsert(Connection con, int unit, String cardId) {
  final req = Request('card', 'insert');
  req.addParam(unit);
  req.addParam(cardId);
  return con.request(req);
}
