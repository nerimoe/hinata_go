import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../providers/settings_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _appName = 'Loading...';
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appName = info.appName;
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Camera'),
            subtitle: const Text('Show QR Code scanner on Reader page'),
            value: settings.enableCamera,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateEnableCamera(val);
            },
          ),
          SwitchListTile(
            title: const Text('Secondary Confirmation'),
            subtitle: const Text(
              'Ask for confirmation before sending card data',
            ),
            value: settings.enableSecondaryConfirmation,
            onChanged: (val) {
              ref
                  .read(settingsProvider.notifier)
                  .updateEnableSecondaryConfirmation(val);
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            subtitle: Text('$_appName v$_appVersion'),
            leading: const Icon(Icons.info_outline),
          ),
        ],
      ),
    );
  }
}
