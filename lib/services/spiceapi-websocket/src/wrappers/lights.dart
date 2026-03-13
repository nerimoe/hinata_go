part of '../../spiceapi.dart';

class LightState {
  final String name;
  final double state;
  final bool active;

  LightState(this.name, this.state) : active = true;
  LightState._fromRead(this.name, this.state, this.active);
}

Future<List<LightState>> lightsRead(Connection con) async {
  final req = Request('lights', 'read');
  final res = await con.request(req);
  return res.getData().map((state) {
    final values = List<Object?>.from(state as List);
    return LightState._fromRead(
      values[0] as String,
      (values[1] as num).toDouble(),
      values[2] as bool,
    );
  }).toList();
}

Future<void> lightsWrite(Connection con, List<LightState> states) {
  final req = Request('lights', 'write');
  for (var state in states) {
    final obj = <Object>[state.name, state.state];
    req.addParam(obj);
  }

  return con.request(req);
}

Future<void> lightsWriteReset(Connection con, List<String> names) {
  final req = Request('lights', 'write_reset');
  for (var name in names) {
    req.addParam(name);
  }
  return con.request(req);
}
