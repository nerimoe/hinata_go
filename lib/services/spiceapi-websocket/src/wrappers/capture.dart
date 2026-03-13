part of '../../spiceapi.dart';

class CaptureData {
  int? timestamp;
  int? width;
  int? height;
  Uint8List? data;
}

final Base64Decoder _base64DecoderInstance = Base64Decoder();

Future<List<Object?>> captureGetScreens(Connection con) async {
  final req = Request('capture', 'get_screens');
  final res = await con.request(req);
  return res.getData();
}

Future<CaptureData> captureGetJPG(
  Connection con, {
  int screen = 0,
  int quality = 60,
  int divide = 1,
}) {
  final req = Request('capture', 'get_jpg');
  req.addParam(screen);
  req.addParam(quality);
  req.addParam(divide);
  return con.request(req).then((res) {
    final captureData = CaptureData();
    final data = res.getData();
    if (data.isNotEmpty) captureData.timestamp = data[0] as int;
    if (data.length > 1) captureData.width = data[1] as int;
    if (data.length > 2) captureData.height = data[2] as int;
    if (data.length > 3) {
      captureData.data = _base64DecoderInstance.convert(data[3] as String);
    }
    return captureData;
  });
}
