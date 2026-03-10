import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/navigation_provider.dart';
import '../providers/app_update_provider.dart';
import '../l10n/l10n.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _handleSwipe(DragEndDetails details) {
    // Determine the swipe velocity
    final double velocity = details.primaryVelocity ?? 0.0;

    // We only care about noticeable swipes
    if (velocity.abs() < 300) return;

    final int currentIndex = navigationShell.currentIndex;

    if (velocity > 0) {
      // Swiped right -> go to previous tab (left)
      if (currentIndex > 0) {
        _goBranch(currentIndex - 1);
      }
    } else {
      // Swiped left -> go to next tab (right)
      if (currentIndex < 2) {
        // 2 is the max index (Settings)
        _goBranch(currentIndex + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    // Check if the current route containing this scaffold is actually the top-most route.
    // If something (like a dialog or CardDetail) is pushed on the root navigator,
    // isCurrent will be false, signaling that the scaffold is covered.
    final bool isScaffoldVisible = ModalRoute.of(context)?.isCurrent ?? false;

    // Update the coverage provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(isScaffoldCoveredProvider) == isScaffoldVisible) {
        // isScaffoldCoveredProvider tracks if it's COVERED, so invert visible.
        ref
            .read(isScaffoldCoveredProvider.notifier)
            .setCovered(!isScaffoldVisible);
      }
    });

    // Proactively update the active branch index provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(activeBranchProvider) != navigationShell.currentIndex) {
        ref
            .read(activeBranchProvider.notifier)
            .setIndex(navigationShell.currentIndex);
      }
    });

    return GestureDetector(
      onHorizontalDragEnd: _handleSwipe,
      behavior: HitTestBehavior.translucent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Use NavigationBar strictly for mobile layout
            return Scaffold(
              body: navigationShell,
              bottomNavigationBar: NavigationBar(
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _goBranch,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.nfc),
                    label: l10n.reader,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.credit_card),
                    label: l10n.cards,
                  ),
                  NavigationDestination(
                    icon: Badge(
                      isLabelVisible: ref.watch(appUpdateProvider).hasUpdate,
                      child: const Icon(Icons.settings),
                    ),
                    label: l10n.settings,
                  ),
                ],
              ),
            );
          } else {
            // Use NavigationRail for wider screens (Tablets, Foldables, LandScape)
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _goBranch,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.nfc),
                        label: Text(l10n.reader),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.credit_card),
                        label: Text(l10n.cards),
                      ),
                      NavigationRailDestination(
                        icon: Badge(
                          isLabelVisible: ref
                              .watch(appUpdateProvider)
                              .hasUpdate,
                          child: const Icon(Icons.settings),
                        ),
                        label: Text(l10n.settings),
                      ),
                    ],
                  ),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(child: navigationShell),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
