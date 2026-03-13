part of '../../spiceapi.dart';

class TouchState {
  final int id;
  final int x;
  final int y;
  bool active = true;
  bool updated = true;

  TouchState(this.id, this.x, this.y);
}

Future<List<TouchState>> touchRead(Connection con) async {
  final req = Request('touch', 'read');
  final res = await con.request(req);
  return res.getData().map((state) {
    final values = List<Object?>.from(state as List);
    return TouchState(values[0] as int, values[1] as int, values[2] as int);
  }).toList();
}

Future<void> touchWrite(Connection con, List<TouchState> states) async {
  if (states.isEmpty) return;
  final req = Request('touch', 'write');

  for (var state in states) {
    final obj = <Object>[state.id, state.x, state.y];
    req.addParam(obj);
  }

  await con.request(req);
}

Future<void> touchWriteReset(Connection con, List<TouchState> states) async {
  if (states.isEmpty) return;
  final req = Request('touch', 'write_reset');

  for (var state in states) {
    req.addParam(state.id);
  }

  await con.request(req);
}

Future<void> touchWriteResetIDs(Connection con, List<int> touchIDs) async {
  if (touchIDs.isEmpty) return;
  final req = Request('touch', 'write_reset');

  for (var id in touchIDs) {
    req.addParam(id);
  }

  await con.request(req);
}
