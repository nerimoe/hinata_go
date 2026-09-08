import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/arcadelink_api.dart';

/// Presentation only: the page owns authentication and machine requests.
class ArcadeLinkMachineContent extends StatelessWidget {
  const ArcadeLinkMachineContent({
    required this.session,
    required this.cards,
    required this.authRequired,
    required this.authenticating,
    required this.passkeyAuthenticating,
    required this.loggingIn,
    required this.success,
    required this.webAuthStarted,
    required this.error,
    required this.onAuthenticate,
    required this.onAuthenticatePasskey,
    required this.onReloadCards,
    required this.onLogin,
    required this.onContinue,
    this.loadingCards = false,
    this.browserOnly = false,
    this.passkeyAvailable = false,
    this.passkeyActionLabel = '使用 Passkey 登录',
    this.nativeMunetAvailable = false,
    this.activeCardId,
    super.key,
  });

  final ArcadeLinkMachineSession session;
  final List<ArcadeLinkCard> cards;
  final bool authRequired,
      authenticating,
      passkeyAuthenticating,
      loggingIn,
      success,
      webAuthStarted;
  final bool loadingCards, browserOnly, passkeyAvailable, nativeMunetAvailable;
  final String passkeyActionLabel;
  final String? activeCardId;
  final Object? error;
  final VoidCallback onAuthenticate,
      onAuthenticatePasskey,
      onReloadCards,
      onContinue;
  final ValueChanged<ArcadeLinkCard> onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final busy =
        authenticating || passkeyAuthenticating || loggingIn || loadingCards;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card.filled(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.sports_esports_outlined,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  session.machine.shopName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.machine.name,
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (success)
          const ArcadeLinkStatusPanel(
            title: '已登录',
            message: '本次会话已结束',
            icon: Icons.check_circle_outline,
          )
        else ...[
          if (browserOnly) ...[
            Text('在浏览器继续', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '当前平台通过 ArcadeLink 网页完成账号登录、选卡和位置确认。',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _TouchAction(
              label: '继续登录',
              icon: Icons.open_in_browser,
              onPressed: onContinue,
            ),
          ] else if (authRequired) ...[
            Text('登录账号', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '登录后选择卡片，即可登录这台机台。',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (passkeyAvailable) ...[
              _TouchAction(
                label: passkeyAuthenticating ? '正在验证...' : passkeyActionLabel,
                icon: Icons.fingerprint,
                busy: passkeyAuthenticating,
                onPressed: busy ? null : onAuthenticatePasskey,
              ),
              const SizedBox(height: 12),
            ],
            _TouchAction(
              label: authenticating
                  ? '正在打开...'
                  : nativeMunetAvailable
                  ? '使用 MuNET 登录'
                  : passkeyAvailable
                  ? '打开网页登录'
                  : '使用 MuNET 登录',
              icon: browserOnly ? Icons.open_in_browser : Icons.person_outline,
              secondary: passkeyAvailable,
              busy: authenticating,
              onPressed: busy ? null : onAuthenticate,
            ),
            if (webAuthStarted) ...[
              const SizedBox(height: 16),
              Text('完成授权后，返回这里刷新卡片。', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 12),
              _TouchAction(
                label: '刷新卡片',
                icon: Icons.refresh,
                secondary: true,
                busy: loadingCards,
                onPressed: busy ? null : onReloadCards,
              ),
            ],
          ] else if (loadingCards)
            const ArcadeLinkStatusPanel(title: '正在读取卡片...', busy: true)
          else if (cards.isEmpty && error != null)
            ArcadeLinkStatusPanel(title: '无法读取卡片', onRetry: onReloadCards)
          else if (cards.isEmpty)
            const ArcadeLinkStatusPanel(
              title: '还没有添加卡片',
              message: '请在 ArcadeLink 网页中添加或同步卡片，再返回这里刷新。',
              icon: Icons.credit_card_off_outlined,
            )
          else ...[
            Text('选择卡片', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '登录时需要确认你位于店内。',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            for (final card in cards) ...[
              _CardLoginTile(
                card: card,
                busy: loggingIn && card.id == activeCardId,
                onPressed: busy ? null : () => onLogin(card),
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (error != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    error is PlatformException
                        ? (error as PlatformException).message ?? '操作失败，请重试'
                        : error.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ),
          ],
          if (!browserOnly) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            _TouchAction(
              label: '打开网页版',
              icon: Icons.open_in_browser,
              secondary: true,
              onPressed: busy ? null : onContinue,
            ),
            if (!authRequired &&
                cards.isEmpty &&
                error == null &&
                !loadingCards) ...[
              const SizedBox(height: 12),
              _TouchAction(
                label: '刷新卡片',
                icon: Icons.refresh,
                secondary: true,
                onPressed: onReloadCards,
              ),
            ],
          ],
        ],
      ],
    );
  }
}

class _TouchAction extends StatelessWidget {
  const _TouchAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.secondary = false,
    this.busy = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool secondary, busy;

  @override
  Widget build(BuildContext context) {
    final style = FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(56),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      textStyle: Theme.of(context).textTheme.titleMedium,
      visualDensity: VisualDensity.standard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
    final symbol = busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon);
    return secondary
        ? OutlinedButton.icon(
            style: style,
            onPressed: onPressed,
            icon: symbol,
            label: Text(label, textAlign: TextAlign.center),
          )
        : FilledButton.icon(
            style: style,
            onPressed: onPressed,
            icon: symbol,
            label: Text(label, textAlign: TextAlign.center),
          );
  }
}

class _CardLoginTile extends StatelessWidget {
  const _CardLoginTile({
    required this.card,
    required this.busy,
    required this.onPressed,
  });
  final ArcadeLinkCard card;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tail = card.accessCode.length > 4
        ? card.accessCode.substring(card.accessCode.length - 4)
        : card.accessCode;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(88),
        padding: const EdgeInsets.all(20),
        visualDensity: VisualDensity.standard,
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          const Icon(Icons.credit_card_outlined, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.label, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '尾号 $tail',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  busy ? '正在登录...' : '登录',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (busy)
            const SizedBox.square(
              dimension: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class ArcadeLinkStatusPanel extends StatelessWidget {
  const ArcadeLinkStatusPanel({
    required this.title,
    this.message,
    this.icon = Icons.error_outline,
    this.busy = false,
    this.onRetry,
    super.key,
  });
  final String title;
  final String? message;
  final IconData icon;
  final bool busy;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (busy)
            const Center(child: CircularProgressIndicator())
          else
            Icon(icon, size: 40, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 20),
            _TouchAction(label: '重试', icon: Icons.refresh, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}
