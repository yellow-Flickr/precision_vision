import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:precision_vision/common/theme/themes.dart';
import 'package:precision_vision/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(
    child: const MainApp(),
  ));
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: PVTheme.light,
      darkTheme: PVTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
