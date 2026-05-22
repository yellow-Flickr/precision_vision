import 'package:go_router/go_router.dart';
import 'package:precision_vision/camera_stream/presentation/camera_stream.dart';
import 'package:precision_vision/common/widgets/app_shell.dart';
import 'package:precision_vision/gallery/presentation/gallery_screen.dart';
import 'package:precision_vision/settings/presentation/model_settings.dart';

final GoRouter router = GoRouter(
  initialLocation: '/live',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        // Live branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/live',
              builder: (context, state) => const CameraStream(),
            ),
          ],
        ),
        // Models branch
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/models',
              builder: (context, state) => const ModelSettingsScreen(),
            ),
          ],
        ),
        // Gallery branch (commented out for now)
        // StatefulShellBranch(
        //   routes: [
        //     GoRoute(
        //       path: '/gallery',
        //       builder: (context, state) => const GalleryScreen(),
        //     ),
        //   ],
        // ),
      ],
    ),
  ],
);
