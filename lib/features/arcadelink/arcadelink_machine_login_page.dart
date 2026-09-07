import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/arcadelink_api.dart';
import '../../services/arcadelink_invocation_service.dart';
import '../../services/arcadelink_native_service.dart';

class ArcadeLinkMachineLoginPage extends ConsumerStatefulWidget {
  const ArcadeLinkMachineLoginPage({required this.publicId, super.key});

  final String publicId;

  @override
  ConsumerState<ArcadeLinkMachineLoginPage> createState() =>
      _ArcadeLinkMachineLoginPageState();
}

class _ArcadeLinkMachineLoginPageState
    extends ConsumerState<ArcadeLinkMachineLoginPage> {
  final _api = ArcadeLinkAPI();
  final _native = ArcadeLinkNativeService();
  ArcadeLinkMachineSession? _session;
  List<ArcadeLinkCard> _cards = const [];
  Object? _error;
  bool _loading = true;
  bool _authRequired = false;
  bool _authenticating = false;
  bool _loggingIn = false;
  bool _webAuthStarted = false;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(arcadeLinkInvocationProvider).clear();
    });
    _loadMachine();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  Future<void> _loadMachine() async {
    try {
      final session = await _api.startMachineSession(widget.publicId);
      if (!mounted) return;
      setState(() {
        _session = session;
        _loading = false;
      });
      if (kIsWeb || ArcadeLinkNativeService.isAvailable) {
        await _loadCards();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _openWebFallback() async {
    final session = _session;
    if (session == null) return;
    await launchUrl(
      _api.webFallbackURL(session.ticket),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _loadCards() async {
    try {
      final cards = kIsWeb ? await _api.cards() : await _native.loadCards();
      if (!mounted) return;
      setState(() {
        _cards = cards;
        _authRequired = false;
        _error = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _authRequired = true;
        _error = error;
      });
    }
  }

  Future<void> _authenticate() async {
    if (ArcadeLinkNativeService.isAvailable) {
      setState(() {
        _authenticating = true;
        _error = null;
      });
      try {
        await _native.authenticateWithMunet();
        await _loadCards();
      } catch (error) {
        if (!mounted) return;
        setState(() => _error = error);
      } finally {
        if (mounted) setState(() => _authenticating = false);
      }
      return;
    }

    if (kIsWeb) {
      final launched = await launchUrl(
        _api.munetLoginURL(widget.publicId),
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      setState(() {
        _webAuthStarted = launched;
        if (!launched) _error = '无法打开 MuNET 登录页面';
      });
      return;
    }

    await _openWebFallback();
  }

  Future<void> _login(ArcadeLinkCard card) async {
    final session = _session;
    if (session == null) return;
    setState(() {
      _loggingIn = true;
      _error = null;
    });
    try {
      if (ArcadeLinkNativeService.isAvailable) {
        await _native.loginMachine(cardId: card.id, ticket: session.ticket);
      } else {
        await _api.loginMachine(cardId: card.id, ticket: session.ticket);
      }
      if (!mounted) return;
      setState(() {
        _loggingIn = false;
        _success = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loggingIn = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    return Scaffold(
      appBar: AppBar(title: const Text('ArcadeLink')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _loading
              ? const CircularProgressIndicator()
              : session == null
              ? _ErrorView(error: _error?.toString() ?? '无法读取机台信息')
              : _MachineView(
                  session: session,
                  cards: _cards,
                  authRequired: _authRequired,
                  authenticating: _authenticating,
                  loggingIn: _loggingIn,
                  success: _success,
                  webAuthStarted: _webAuthStarted,
                  error: _error,
                  onAuthenticate: _authenticate,
                  onReloadCards: _loadCards,
                  onLogin: _login,
                  onContinue: _openWebFallback,
                ),
        ),
      ),
    );
  }
}

class _MachineView extends StatelessWidget {
  const _MachineView({
    required this.session,
    required this.cards,
    required this.authRequired,
    required this.authenticating,
    required this.loggingIn,
    required this.success,
    required this.webAuthStarted,
    required this.error,
    required this.onAuthenticate,
    required this.onReloadCards,
    required this.onLogin,
    required this.onContinue,
  });

  final ArcadeLinkMachineSession session;
  final List<ArcadeLinkCard> cards;
  final bool authRequired;
  final bool authenticating;
  final bool loggingIn;
  final bool success;
  final bool webAuthStarted;
  final Object? error;
  final VoidCallback onAuthenticate;
  final VoidCallback onReloadCards;
  final ValueChanged<ArcadeLinkCard> onLogin;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.sports_esports, size: 56),
        const SizedBox(height: 16),
        Text(
          session.machine.shopName,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(session.machine.name, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (success) ...[
          const Icon(Icons.check_circle, color: Colors.green, size: 56),
          const SizedBox(height: 12),
          Text(
            '登录成功',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('可以开始游戏了。', textAlign: TextAlign.center),
        ] else if (authRequired) ...[
          const Text(
            '登录 ArcadeLink 后即可选择 Aime 卡片。',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          if (authenticating)
            const Center(child: CircularProgressIndicator())
          else ...[
            FilledButton(
              onPressed: onAuthenticate,
              child: const Text('使用 MuNET 登录'),
            ),
            if (webAuthStarted) ...[
              const SizedBox(height: 8),
              Text(
                '完成登录后返回此页面，再点击刷新卡片。',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onReloadCards,
                child: const Text('刷新卡片'),
              ),
            ],
          ],
        ] else if (cards.isEmpty) ...[
          const Text('当前账号没有可用卡片。', textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onContinue, child: const Text('在浏览器继续登录')),
        ] else ...[
          Text(
            '选择要登录的 Aime',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final card in cards) ...[
            OutlinedButton(
              onPressed: loggingIn ? null : () => onLogin(card),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(card.label),
                        const SizedBox(height: 4),
                        Text(
                          '尾号 ${card.accessCode.substring(card.accessCode.length - 4)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (loggingIn)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton(onPressed: onContinue, child: const Text('打开网页版')),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.warning_amber_rounded, size: 48),
        const SizedBox(height: 12),
        const Text('无法进入机台会话'),
        const SizedBox(height: 8),
        Text(error, textAlign: TextAlign.center),
      ],
    );
  }
}
