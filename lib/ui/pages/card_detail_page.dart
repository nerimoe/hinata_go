import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/card/card.dart';
import '../../models/card/aic.dart';
import '../../models/card/aime.dart';
import '../../models/card/banapass.dart';
import '../../models/card/felica.dart';
import '../../models/card/iso14443a.dart';
import '../../providers/card_sender.dart';
import '../../providers/settings_provider.dart';
import '../../services/notification_service.dart';
import '../../l10n/l10n.dart';
import '../widgets/save_card_dialog.dart';

class CardDetailPage extends HookConsumerWidget {
  final ICCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSavingState = useState(false);
    final enableSecondaryConfirmation = ref
        .watch(settingsProvider)
        .enableSecondaryConfirmation;

    Future<void> saveCard() async {
      final success = await showDialog<bool>(
        context: context,
        builder: (context) => SaveCardDialog(card: card, source: 'Scanned'),
      );

      if (success == true) {
        // Dialog already shows snackbar and adds card
      }
    }

    Future<void> sendCard() async {
      if (enableSecondaryConfirmation) {
        final shouldSend = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.confirmSend),
            content: Text(context.l10n.confirmSendToActiveInstance(card.name)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(context.l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(context.l10n.send),
              ),
            ],
          ),
        );
        if (shouldSend != true) return;
      }

      await ref.read(cardSenderProvider.notifier).sendCard(card);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cardDetails(card.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: card.value ?? ''));
              ref
                  .read(notificationServiceProvider)
                  .showSuccess(context.l10n.valueCopiedToClipboard);
            },
            tooltip: context.l10n.copyValue,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(card: card),
                  const SizedBox(height: 24),
                  ..._buildCardSections(context, card),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _BottomAction(
            onSend: sendCard,
            onSave: saveCard,
            isSending: ref.watch(cardSenderProvider).isSending,
            isSaving: isSavingState.value,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCardSections(BuildContext context, ICCard card) {
    final List<Widget> sections = [];

    if (card is Aic) {
      sections.add(
        _InfoSection(
          title: context.l10n.amusementIcInfo,
          children: [
            _InfoRow(
              label: context.l10n.accessCode,
              value: card.accessCodeString,
            ),
            _InfoRow(
              label: context.l10n.manufacturer,
              value: card.manufacturer,
            ),
          ],
        ),
      );
    }

    if (card is Aime && card is! Aic) {
      sections.add(
        _InfoSection(
          title: context.l10n.aimeInfo,
          children: [
            _InfoRow(
              label: context.l10n.accessCode,
              value: card.accessCodeString,
            ),
          ],
        ),
      );
    }

    if (card is Felica) {
      sections.add(
        _InfoSection(
          title: context.l10n.felicaDetails,
          children: [
            _InfoRow(label: context.l10n.idm, value: card.idString),
            _InfoRow(label: context.l10n.pmm, value: card.pmmString),
            _InfoRow(
              label: context.l10n.systemCode,
              value: card.systemCode
                  .map((e) => e.toRadixString(16).padLeft(4, '0').toUpperCase())
                  .join(', '),
            ),
          ],
        ),
      );
    }

    if (card is Banapass) {
      sections.add(
        _InfoSection(
          title: context.l10n.banapassData,
          children: [
            _InfoRow(
              label: context.l10n.block1,
              value: card.value?.substring(0, 32) ?? '',
            ),
            if (card.block2 != null)
              _InfoRow(
                label: context.l10n.block2,
                value: card.value?.substring(32) ?? '',
              ),
          ],
        ),
      );
    }

    if (card is Iso14443) {
      sections.add(
        _InfoSection(
          title: context.l10n.iso14443Details,
          children: [
            _InfoRow(label: context.l10n.uid, value: card.idString),
            _InfoRow(
              label: context.l10n.sak,
              value:
                  '0x${card.sak.toRadixString(16).padLeft(2, '0').toUpperCase()}',
            ),
            _InfoRow(
              label: context.l10n.atqa,
              value:
                  '0x${card.atqa.toRadixString(16).padLeft(4, '0').toUpperCase()}',
            ),
          ],
        ),
      );
    }

    if (card is! Felica && card is! Iso14443) {
      sections.add(
        _InfoSection(
          title: context.l10n.technicalDetails,
          children: [
            _InfoRow(
              label: context.l10n.idOrValue,
              value: card.value ?? card.idString,
            ),
          ],
        ),
      );
    }

    return sections;
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ICCard card;

  const _HeaderCard({required this.card});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 4,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.credit_card,
                size: 48,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              card.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final VoidCallback onSend;
  final VoidCallback onSave;
  final bool isSending;
  final bool isSaving;

  const _BottomAction({
    required this.onSend,
    required this.onSave,
    required this.isSending,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = MediaQuery.of(context).padding;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: padding.bottom > 0 ? padding.bottom : 24,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: isSaving || isSending ? null : onSave,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.folder_special),
              label: Text(
                isSaving ? context.l10n.savingUpper : context.l10n.saveUpper,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: isSending || isSaving ? null : onSend,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(
                isSending ? context.l10n.sendingUpper : context.l10n.sendUpper,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
