import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_provider.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(() {
  return SettingsNotifier();
});

class AppSettings {
  final bool enableCamera;
  final bool enableSecondaryConfirmation;

  AppSettings({
    required this.enableCamera,
    required this.enableSecondaryConfirmation,
  });

  AppSettings copyWith({
    bool? enableCamera,
    bool? enableSecondaryConfirmation,
  }) {
    return AppSettings(
      enableCamera: enableCamera ?? this.enableCamera,
      enableSecondaryConfirmation:
          enableSecondaryConfirmation ?? this.enableSecondaryConfirmation,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(storageProvider).getSettings();
  }

  void updateEnableCamera(bool value) {
    state = state.copyWith(enableCamera: value);
    ref.read(storageProvider).saveSettings(state);
  }

  void updateEnableSecondaryConfirmation(bool value) {
    state = state.copyWith(enableSecondaryConfirmation: value);
    ref.read(storageProvider).saveSettings(state);
  }
}
