part of '../spiceapi.dart';

class Response {
  final String json;
  final int id;
  final List<Object?> errors;
  final List<Object?> data;

  Response.fromJson(this.json)
    : assert(json.isNotEmpty),
      id = (jsonDecode(json) as Map<String, dynamic>)['id'] as int,
      errors = List<Object?>.from(
        ((jsonDecode(json) as Map<String, dynamic>)['errors'] as List?) ??
            const <Object?>[],
      ),
      data = List<Object?>.from(
        ((jsonDecode(json) as Map<String, dynamic>)['data'] as List?) ??
            const <Object?>[],
      );

  void validate() {
    if (errors.isNotEmpty) {
      throw APIError(errors.first.toString());
    }
  }

  List<Object?> getData() => data;

  String toJson() => json;
}
