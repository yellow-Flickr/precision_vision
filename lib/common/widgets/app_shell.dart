import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:precision_vision/common/theme/app_typography.dart';
import 'package:precision_vision/settings/providers.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final themeMode = ref.watch(themeProvider);

    final iconData = switch (themeMode) {
      ThemeModeOption.system => Icons.brightness_auto,
      ThemeModeOption.light => Icons.light_mode,
      ThemeModeOption.dark => Icons.dark_mode,
    };

    final tooltip = switch (themeMode) {
      ThemeModeOption.system => 'Follow system theme',
      ThemeModeOption.light => 'Light theme',
      ThemeModeOption.dark => 'Dark theme',
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface.withAlpha(200),
        elevation: 0,
        title: Row(
          children: [
            Text(
              'PrecisionVision',
              style: PVTypography.headlineSm.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(iconData),
            color: cs.primary,
            tooltip: tooltip,
            onPressed: () {
              final notifier = ref.read(themeProvider.notifier);
              final next = ThemeModeOption.values[(themeMode.index + 1) % 3];
              notifier.setThemeMode(next);
            },
          ),
        ],
      ),
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface.withAlpha(200),
          border: Border(
            top: BorderSide(color: cs.outlineVariant.withAlpha(25)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: navigationShell.currentIndex,
            onTap: (index) => navigationShell.goBranch(index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: cs.secondary,
            unselectedItemColor: cs.onSurfaceVariant,
            selectedLabelStyle: PVTypography.labelCaps,
            unselectedLabelStyle: PVTypography.labelCaps,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.videocam),
                label: 'Live',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.model_training),
                label: 'Models',
              ),
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.grid_view),
              //   label: 'Gallery',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
