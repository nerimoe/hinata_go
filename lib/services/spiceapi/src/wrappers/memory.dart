part of '../../spiceapi.dart';

Future<void> memoryWrite(
  Connection con,
  String dllName,
  String data,
  int offset,
) {
  final req = Request('memory', 'write');
  req.addParam(dllName);
  req.addParam(data);
  req.addParam(offset);
  return con.request(req);
}

Future<String> memoryRead(
  Connection con,
  String dllName,
  int offset,
  int size,
) async {
  final req = Request('memory', 'read');
  req.addParam(dllName);
  req.addParam(offset);
  req.addParam(size);
  final res = await con.request(req);
  return res.getData()[0] as String;
}

Future<int> memorySignature(
  Connection con,
  String dllName,
  String signature,
  String replacement,
  int offset,
  int usage,
) async {
  final req = Request('memory', 'signature');
  req.addParam(dllName);
  req.addParam(signature);
  req.addParam(replacement);
  req.addParam(offset);
  req.addParam(usage);
  final res = await con.request(req);
  return res.getData()[0] as int;
}
