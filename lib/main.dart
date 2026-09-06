import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/persistence/local_storage.dart';
import 'app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.instance.init();
  runApp(const BuildCalcApp());
}

class BuildCalcApp extends StatelessWidget {
  const BuildCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BuildCalc',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}
