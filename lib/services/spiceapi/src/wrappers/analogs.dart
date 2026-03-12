part of '../../spiceapi.dart';

class AnalogState {
  final String name;
  final double state;
  final bool active;

  AnalogState(this.name, this.state) : active = true;
  AnalogState._fromRead(this.name, this.state, this.active);
}

Future<List<AnalogState>> analogsRead(Connection con) async {
  final req = Request('analogs', 'read');
  final res = await con.request(req);
  return res.getData().map((state) {
    final values = List<Object?>.from(state as List);
    return AnalogState._fromRead(
      values[0] as String,
      (values[1] as num).toDouble(),
      values[2] as bool,
    );
  }).toList();
}

Future<void> analogsWrite(Connection con, List<AnalogState> states) {
  final req = Request('analogs', 'write');
  for (var state in states) {
    final obj = <Object>[state.name, state.state];
    req.addParam(obj);
  }

  return con.request(req);
}

Future<void> analogsWriteReset(Connection con, List<String> names) {
  final req = Request('analogs', 'write_reset');
  for (var name in names) {
    req.addParam(name);
  }
  return con.request(req);
}
