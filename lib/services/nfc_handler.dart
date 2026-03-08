import 'dart:async';
import 'dart:developer';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:uuid/uuid.dart';

import '../models/card/scanned_card.dart';
import '../models/card/saved_card.dart';
import '../models/scan_log.dart';
import '../providers/app_state_provider.dart';
import '../navigation/router.dart';
import 'api_service.dart';
import 'nfc_service.dart';
import 'notification_service.dart';

class NfcState {
  final bool isScanning;
  final bool isProcessing;
  final String status;

  NfcState({
    this.isScanning = false,
    this.isProcessing = false,
    this.status = 'Ready to scan',
  });

  NfcState copyWith({bool? isScanning, bool? isProcessing, String? status}) {
    return NfcState(
      isScanning: isScanning ?? this.isScanning,
      isProcessing: isProcessing ?? this.isProcessing,
      status: status ?? this.status,
    );
  }
}

final nfcHandlerProvider = NotifierProvider<NfcHandler, NfcState>(() {
  return NfcHandler();
});

class NfcHandler extends Notifier<NfcState> {
  @override
  NfcState build() {
    // Listen to tagStream for tags relayed from Android Intents (App Launch)
    FlutterNfcKit.tagStream.listen((tag) {
      _onTagDiscovered(tag);
    });

    // Pulse the native side to relay the initial tag that launched the app
    const methodChannel = MethodChannel('moe.neri.hinatago/nfc_launcher');
    methodChannel.invokeMethod('getInitialTag').catchError((e) {
      log('Error getting initial tag: $e');
    });

    return NfcState();
  }

  Future<void> startSession() async {
    if (state.isScanning) return;
    try {
      NFCAvailability availability = await FlutterNfcKit.nfcAvailability;
      if (availability == NFCAvailability.not_supported) {
        state = state.copyWith(status: 'Your device does not support NFC');
        return;
      }

      if (availability == NFCAvailability.disabled) {
        state = state.copyWith(status: 'Please enable NFC');
        return;
      }

      state = state.copyWith(isScanning: true, status: 'Listening for NFC...');

      while (state.isScanning) {
        try {
          NFCTag tag = await FlutterNfcKit.poll(
            iosAlertMessage: 'Hold your card near the top of your iPhone',
            readIso18092: true,
            readIso14443B: false,
          );
          await _onTagDiscovered(tag);
        } catch (e) {
          if (e.toString().contains('User Canceled') ||
              e.toString().contains('Session Timeout')) {
            break;
          }
          // Log error but continue polling if still scanning
        }
      }
    } catch (e) {
      state = state.copyWith(isScanning: false, status: 'Error: $e');
    } finally {
      if (state.isScanning) {
        stopSession();
      }
    }
  }

  Future<void> stopSession() async {
    state = state.copyWith(isScanning: false, status: 'Stopped');
    try {
      await FlutterNfcKit.finish();
    } catch (_) {}
  }

  Future<void> _onTagDiscovered(NFCTag tag) async {
    if (state.isProcessing) return;
    state = state.copyWith(isProcessing: true);

    try {
      final scannedCard = await handleNfcTag(tag);
      if (scannedCard != null) {
        await _processScannedCard(scannedCard);
      }
    } finally {
      state = state.copyWith(isProcessing: false);
    }
  }

  Future<void> _processScannedCard(ScannedCard scannedCard) async {
    final card = scannedCard.card;

    // 1. Create ScanLog
    final newLog = ScanLog(
      id: const Uuid().v4(),
      source: scannedCard.source,
      showValue: scannedCard.showValue,
      card: card,
      timestamp: DateTime.now(),
    );
    ref.read(scanLogsProvider.notifier).addLog(newLog);

    // 2. Auto-save to 'history_folder'
    final savedCard = SavedCard.fromScanned(
      scannedCard,
      id: const Uuid().v4(),
      folderId: 'history_folder',
    );
    ref.read(savedCardsProvider.notifier).addCard(savedCard);

    // 3. Auto-send to active instance
    final activeInstance = ref.read(activeInstanceProvider);
    final notificationService = ref.read(notificationServiceProvider);

    if (activeInstance != null) {
      notificationService.showInfo(
        'Sending ${card.name} to ${activeInstance.name}...',
      );

      final apiService = ref.read(apiServiceProvider);
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
    } else {
      notificationService.showError(
        'No active instance set. Data was not sent.',
      );
    }

    // 4. Navigate back to reader page if not there
    ref.read(routerProvider).go('/reader');
  }

  // Also expose for QR processing
  Future<void> handleExternalScan(ScannedCard scannedCard) async {
    await _processScannedCard(scannedCard);
  }
}
