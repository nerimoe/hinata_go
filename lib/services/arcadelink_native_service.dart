import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'arcadelink_api.dart';

class ArcadeLinkNativeService {
  static const _channel = MethodChannel('moe.neri.hinatago/arcadelink_native');

  static bool get isAvailable =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> authenticateWithMunet() async {
    await _channel.invokeMethod<void>('authenticateMunet');
  }

  Future<List<ArcadeLinkCard>> loadCards() async {
    final raw = await _channel.invokeMethod<List<dynamic>>('cards') ?? const [];
    return raw
        .map(
          (value) => ArcadeLinkCard.fromJson(
            Map<String, dynamic>.from(value as Map<dynamic, dynamic>),
          ),
        )
        .toList(growable: false);
  }

  Future<void> loginMachine({
    required String cardId,
    required String ticket,
  }) async {
    await _channel.invokeMethod<void>('loginMachine', {
      'cardId': cardId,
      'ticket': ticket,
    });
  }
}
