import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/persistence/local_storage.dart';
import 'core/components/web/web_mobile_frame.dart';
import 'features/splash/splash_screen.dart';
import 'features/disclaimer/disclaimer_screen.dart';
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const BuildCalcApp());
}

class BuildCalcApp extends StatelessWidget {
  final bool showSplash;
  final bool? overrideDisclaimerAccepted;

  const BuildCalcApp({
    super.key,
    this.showSplash = true,
    this.overrideDisclaimerAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final hasAccepted = overrideDisclaimerAccepted ?? LocalStorageService.instance.hasAcceptedDisclaimer;

    return MaterialApp(
      title: 'BuildCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      builder: (context, child) => WebMobileFrame(child: child!),
      home: showSplash
          ? SplashScreen(overrideDisclaimerAccepted: overrideDisclaimerAccepted)
          : (hasAccepted ? const AppShell() : const DisclaimerScreen()),
    );
  }
}
