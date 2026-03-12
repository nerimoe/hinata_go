part of '../spiceapi.dart';

class RC4 {
  int _a = 0;
  int _b = 0;
  final List<int> _sBox = List<int>.generate(256, (index) => index);

  RC4(List<int> key) {
    int j = 0;
    for (int i = 0; i < 256; i++) {
      j = (j + _sBox[i] + key[i % key.length]) % 256;
      final tmp = _sBox[i];
      _sBox[i] = _sBox[j];
      _sBox[j] = tmp;
    }
  }

  void crypt(List<int> inData) {
    for (int i = 0; i < inData.length; i++) {
      _a = (_a + 1) % 256;
      _b = (_b + _sBox[_a]) % 256;
      final tmp = _sBox[_a];
      _sBox[_a] = _sBox[_b];
      _sBox[_b] = tmp;
      inData[i] ^= _sBox[(_sBox[_a] + _sBox[_b]) % 256];
    }
  }
}
