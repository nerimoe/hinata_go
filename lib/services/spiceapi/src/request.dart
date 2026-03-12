part of '../spiceapi.dart';

class Request {
  static int _lastID = 0;

  final int id;
  final String module;
  final String function;
  final List<Object?> params;

  Request(this.module, this.function, {int? id})
    : id = _nextId(id),
      params = <Object?>[];

  static int _nextId(int? id) {
    if (id == null) {
      if (++_lastID >= 0x100000000) {
        _lastID = 1;
      }
      return _lastID;
    } else {
      _lastID = id;
      return id;
    }
  }

  String toJson() => jsonEncode(<String, Object?>{
    'id': id,
    'module': module,
    'function': function,
    'params': params,
  });

  void addParam(Object? param) {
    params.add(param);
  }
}
