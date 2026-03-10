import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/scan_log.dart';
import '../../providers/app_state_provider.dart';
import '../../l10n/l10n.dart';
import '../ui_text.dart';
import '../widgets/save_card_dialog.dart';

class ScanLogsPage extends HookConsumerWidget {
  const ScanLogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final logs = ref.watch(scanLogsProvider);
    final reversedLogs = logs.reversed.toList();

    void showSaveToBagDialog(ScanLog log) {
      showDialog(
        context: context,
        builder: (context) =>
            SaveCardDialog(card: log.card, source: log.source),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanHistoryLogs),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: l10n.clearHistory,
            onPressed: () {
              ref.read(scanLogsProvider.notifier).clearLogs();
            },
          ),
        ],
      ),
      body: reversedLogs.isEmpty
          ? Center(child: Text(l10n.noScanHistoryYet))
          : ListView.builder(
              itemCount: reversedLogs.length,
              itemBuilder: (context, index) => _buildLogItem(
                context,
                reversedLogs[index],
                showSaveToBagDialog,
              ),
            ),
    );
  }

  Widget _buildLogItem(
    BuildContext context,
    ScanLog log,
    void Function(ScanLog) onSave,
  ) {
    final displaySource = scanSourceDisplayName(context, log);

    IconData sourceIcon = Icons.qr_code;
    if (log.source == 'NFC') sourceIcon = Icons.nfc;
    if (log.source == 'Direct') sourceIcon = Icons.credit_card;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          sourceIcon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        log.showValue,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${context.l10n.sourceLine(displaySource)}\n${context.l10n.timeLine(log.timestamp.toString().substring(0, 19))}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.save_alt),
        tooltip: context.l10n.saveToSavedCards,
        onPressed: () => onSave(log),
      ),
      onTap: () => context.push('/card_detail', extra: log.card),
    );
  }
}
