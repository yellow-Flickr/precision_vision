import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:precision_vision/common/theme/themes.dart';
import 'package:precision_vision/router/app_router.dart';
import 'package:precision_vision/settings/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    child: const MainApp(),
  ));
}


class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeOption = ref.watch(themeProvider);
    final themeMode = switch (themeModeOption) {
      ThemeModeOption.light => ThemeMode.light,
      ThemeModeOption.dark => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: PVTheme.light,
      darkTheme: PVTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
