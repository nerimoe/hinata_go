import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'settings_provider.dart';
import 'nfc_provider.dart';

class ReaderViewState {
  final bool isCameraActive;
  final MobileScannerException? cameraError;

  ReaderViewState({this.isCameraActive = false, this.cameraError});

  ReaderViewState copyWith({
    bool? isCameraActive,
    MobileScannerException? cameraError,
  }) {
    return ReaderViewState(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      cameraError: cameraError ?? this.cameraError,
    );
  }
}

final readerViewModelProvider =
    NotifierProvider<ReaderViewModel, ReaderViewState>(() {
      return ReaderViewModel();
    });

class ReaderViewModel extends Notifier<ReaderViewState>
    with WidgetsBindingObserver {
  late MobileScannerController cameraController;

  @override
  ReaderViewState build() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      autoStart: false,
    );

    // Watch for camera setting changes
    ref.listen(settingsProvider.select((s) => s.enableCamera), (
      previous,
      next,
    ) {
      if (next) {
        _safeStartCamera();
      } else {
        _safeStopCamera();
      }
    });

    // We need to register ourselves as an observer
    WidgetsBinding.instance.addObserver(this);

    // Cleanup on dispose
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
      _safeStopCamera();
      // Future.delayed to ensure native cleanup
      Future.delayed(const Duration(milliseconds: 200), () {
        cameraController.dispose();
      });
    });

    return ReaderViewState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Note: We don't have BuildContext here, so we can't check 'isCurrent' easily.
    // However, the Notifier is scoped to the app.
    // Usually, we only want to manage this if the Reader tab is active.
    // For now, let's assume if it's alive, it should handle it.

    if (state == AppLifecycleState.resumed) {
      if (ref.read(settingsProvider).enableCamera) {
        _safeStartCamera();
      }
      ref.read(nfcProvider.notifier).startSession();
    } else if (state == AppLifecycleState.paused) {
      _safeStopCamera();
      ref.read(nfcProvider.notifier).stopSession();
    }
  }

  void _safeStartCamera() {
    try {
      if (cameraController.value.isStarting ||
          cameraController.value.isRunning) {
        return;
      }
      cameraController.start();
      state = state.copyWith(isCameraActive: true, cameraError: null);
    } catch (e) {
      state = state.copyWith(isCameraActive: false);
    }
  }

  void _safeStopCamera() {
    try {
      if (cameraController.value.isRunning) {
        cameraController.stop();
      }
      state = state.copyWith(isCameraActive: false);
    } catch (e) {
      // ignore
    }
  }

  // Method to be called by UI when it becomes visible/hidden
  // to coordinate scanning if the Notifier persists across tabs
  void onVisibilityChanged(bool isVisible) {
    if (isVisible) {
      if (ref.read(settingsProvider).enableCamera) {
        _safeStartCamera();
      }
      ref.read(nfcProvider.notifier).startSession();
    } else {
      _safeStopCamera();
      ref.read(nfcProvider.notifier).stopSession();
    }
  }
}
