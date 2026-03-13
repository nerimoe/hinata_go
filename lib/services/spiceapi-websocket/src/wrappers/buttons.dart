part of '../../spiceapi.dart';

class ButtonState {
  final String name;
  final double state;
  final bool active;

  ButtonState(this.name, this.state) : active = true;
  ButtonState._fromRead(this.name, this.state, this.active);
}

Future<List<ButtonState>> buttonsRead(Connection con) async {
  final req = Request('buttons', 'read');
  final res = await con.request(req);
  return res.getData().map((state) {
    final values = List<Object?>.from(state as List);
    return ButtonState._fromRead(
      values[0] as String,
      (values[1] as num).toDouble(),
      values[2] as bool,
    );
  }).toList();
}

Future<void> buttonsWrite(Connection con, List<ButtonState> states) {
  final req = Request('buttons', 'write');
  for (var state in states) {
    final obj = <Object>[state.name, state.state];
    req.addParam(obj);
  }

  return con.request(req);
}

Future<void> buttonsWriteReset(Connection con, List<String> names) {
  final req = Request('buttons', 'write_reset');
  for (var name in names) {
    req.addParam(name);
  }
  return con.request(req);
}
