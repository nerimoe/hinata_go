part of '../spiceapi.dart';

class APIError implements Exception {
  final String cause;

  APIError(this.cause);

  @override
  String toString() => cause;
}
