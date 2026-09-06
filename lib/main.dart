import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/persistence/local_storage.dart';
import 'core/components/web/web_mobile_frame.dart';
import 'features/splash/splash_screen.dart';
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const BuildCalcApp());
}

class BuildCalcApp extends StatelessWidget {
  final bool showSplash;

  const BuildCalcApp({
    super.key,
    this.showSplash = true,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) => WebMobileFrame(child: child!),
      home: showSplash ? const SplashScreen() : const AppShell(),
    );
  }
}
