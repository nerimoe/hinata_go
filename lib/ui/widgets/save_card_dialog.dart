import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:uuid/uuid.dart';

import '../../models/card/card.dart';
import '../../models/card/saved_card.dart';
import '../../providers/app_state_provider.dart';
import '../../utils/snackbar_utils.dart';

class SaveCardDialog extends HookConsumerWidget {
  final ICCard card;
  final String? initialName;
  final String source;

  const SaveCardDialog({
    super.key,
    required this.card,
    this.initialName,
    required this.source,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(
      text: initialName ?? card.name,
    );
    final selectedFolderIdState = useState('favorites_folder');

    final folders = ref
        .watch(cardFoldersProvider)
        .where((f) => f.id != 'history_folder')
        .toList();

    useEffect(() {
      if (folders.isNotEmpty) {
        if (folders.any((f) => f.id == 'favorites_folder')) {
          selectedFolderIdState.value = 'favorites_folder';
        } else {
          selectedFolderIdState.value = folders.first.id;
        }
      }
      return null;
    }, []);

    return AlertDialog(
      title: const Text('Save to Folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name / Description'),
            autofocus: true,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: selectedFolderIdState.value,
            decoration: const InputDecoration(labelText: 'Folder'),
            items: folders.map((folder) {
              return DropdownMenuItem(
                value: folder.id,
                child: Text(folder.name),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                selectedFolderIdState.value = val;
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
            if (nameController.text.isNotEmpty) {
              final newCard = SavedCard(
                id: const Uuid().v4(),
                name: nameController.text,
                card: card,
                folderId: selectedFolderIdState.value,
                source: source,
              );
              ref.read(savedCardsProvider.notifier).addCard(newCard);
              ScaffoldMessenger.of(context).showQuickSnackBar(
                SnackBar(
                  content: Text(
                    'Saved "${nameController.text}" to ${folders.firstWhere((f) => f.id == selectedFolderIdState.value).name}.',
                  ),
                ),
              );
              Navigator.pop(context, true);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
