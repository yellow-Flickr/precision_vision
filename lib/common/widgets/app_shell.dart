import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:precision_vision/common/theme/app_typography.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface.withAlpha(200),
        elevation: 0,
        title: Row(
          children: [
            Text(
              'PrecisionVision',
              style: PVTypography.headlineMd.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: cs.primary,
            onPressed: () => context.go('/models'),
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
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view),
                label: 'Gallery',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
