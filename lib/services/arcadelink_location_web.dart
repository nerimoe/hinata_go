import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart';

import 'arcadelink_location_stub.dart';

export 'arcadelink_location_stub.dart'
    show ArcadeLinkLocationException, ArcadeLinkLocationSample;

Future<ArcadeLinkLocationSample> currentArcadeLinkLocation() {
  final completer = Completer<ArcadeLinkLocationSample>();
  final geolocation = window.navigator.geolocation;

  geolocation.getCurrentPosition(
    ((GeolocationPosition position) {
      if (completer.isCompleted) return;
      final coordinates = position.coords;
      completer.complete(
        ArcadeLinkLocationSample(
          latitude: coordinates.latitude,
          longitude: coordinates.longitude,
          accuracy: coordinates.accuracy,
        ),
      );
    }).toJS,
    ((GeolocationPositionError error) {
      if (completer.isCompleted) return;
      completer.completeError(ArcadeLinkLocationException(_messageFor(error)));
    }).toJS,
    PositionOptions(enableHighAccuracy: true, timeout: 10000, maximumAge: 0),
  );

  return completer.future;
}

String _messageFor(GeolocationPositionError error) {
  switch (error.code) {
    case GeolocationPositionError.PERMISSION_DENIED:
      return '需要允许浏览器定位权限';
    case GeolocationPositionError.TIMEOUT:
      return '获取位置超时，请稍后重试';
    default:
      return '当前无法获取位置';
  }
}
