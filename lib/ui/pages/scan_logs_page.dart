import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../models/card/saved_card.dart';
import '../../models/scan_log.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/snackbar_utils.dart';

class ScanLogsPage extends ConsumerStatefulWidget {
  const ScanLogsPage({super.key});

  @override
  ConsumerState<ScanLogsPage> createState() => _ScanLogsPageState();
}

class _ScanLogsPageState extends ConsumerState<ScanLogsPage> {
  void _showSaveToBagDialog(ScanLog log) {
    showDialog(
      context: context,
      builder: (context) => _SaveToBagDialog(log: log),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(scanLogsProvider);
    final reversedLogs = logs.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () {
              ref.read(scanLogsProvider.notifier).clearLogs();
            },
          ),
        ],
      ),
      body: reversedLogs.isEmpty
          ? const Center(child: Text('No scan history yet.'))
          : ListView.builder(
              itemCount: reversedLogs.length,
              itemBuilder: (context, index) =>
                  _buildLogItem(reversedLogs[index]),
            ),
    );
  }

  Widget _buildLogItem(ScanLog log) {
    String displaySource = log.source;
    if (log.source == 'NFC') {
      if (log.apiType != 'nfc') {
        displaySource = 'NFC (${log.displayType})';
      }
    } else if (log.source == 'Direct') {
      displaySource = 'Saved Cards';
    }

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
        'Source: $displaySource\nTime: ${log.timestamp.toString().substring(0, 19)}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        icon: const Icon(Icons.save_alt),
        tooltip: 'Save to Saved Cards',
        onPressed: () => _showSaveToBagDialog(log),
      ),
      onTap: () => context.push('/card_detail', extra: log.card),
    );
  }
}

class _SaveToBagDialog extends ConsumerStatefulWidget {
  final ScanLog log;
  const _SaveToBagDialog({required this.log});

  @override
  ConsumerState<_SaveToBagDialog> createState() => _SaveToBagDialogState();
}

class _SaveToBagDialogState extends ConsumerState<_SaveToBagDialog> {
  late TextEditingController _nameController;
  late String _selectedFolderId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _selectedFolderId = 'favorites_folder';

    // Initial folder selection logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final folders = ref
          .read(cardFoldersProvider)
          .where((f) => f.id != 'history_folder')
          .toList();
      if (folders.isNotEmpty) {
        setState(() {
          if (folders.any((f) => f.id == 'favorites_folder')) {
            _selectedFolderId = 'favorites_folder';
          } else {
            _selectedFolderId = folders.first.id;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref
        .watch(cardFoldersProvider)
        .where((f) => f.id != 'history_folder')
        .toList();

    return AlertDialog(
      title: const Text('Save to Saved Cards'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name / Description'),
            autofocus: true,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _selectedFolderId,
            decoration: const InputDecoration(labelText: 'Folder'),
            items: folders.map((folder) {
              return DropdownMenuItem(
                value: folder.id,
                child: Text(folder.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedFolderId = val;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final newCard = SavedCard(
                id: const Uuid().v4(),
                name: _nameController.text,
                card: widget.log.card,
                folderId: _selectedFolderId,
                source: widget.log.source,
              );
              ref.read(savedCardsProvider.notifier).addCard(newCard);
              ScaffoldMessenger.of(context).showQuickSnackBar(
                SnackBar(
                  content: Text(
                    'Saved "${_nameController.text}" to saved cards.',
                  ),
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
