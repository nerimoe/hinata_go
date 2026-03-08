import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card/card.dart';
import '../models/remote_instance.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'app_state_provider.dart';

final cardSenderProvider = NotifierProvider<CardSender, bool>(() {
  return CardSender();
});

class CardSender extends Notifier<bool> {
  @override
  bool build() {
    return false; // isSending
  }

  Future<bool> sendCard(ICCard card, {RemoteInstance? targetInstance}) async {
    if (state) return false;

    final activeInstance = targetInstance ?? ref.read(activeInstanceProvider);
    final notificationService = ref.read(notificationServiceProvider);
    final apiService = ref.read(apiServiceProvider);

    if (activeInstance == null) {
      notificationService.showError('No active instance selected.');
      return false;
    }

    state = true;
    try {
      notificationService.showInfo('Sending to ${activeInstance.name}...');

      final success = await apiService.sendCardData(
        instance: activeInstance,
        type: card.type ?? 'unknown',
        value: card.value ?? '',
      );

      if (success) {
        notificationService.showSuccess(
          'Success: Sent to ${activeInstance.name}',
        );
      } else {
        notificationService.showError(
          'Failed: Could not send to ${activeInstance.name}',
        );
      }
      return success;
    } finally {
      state = false;
    }
  }
}
