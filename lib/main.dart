import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/main_shell_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TenaWiseApp());
}

/// The root application widget of TenaWise.
class TenaWiseApp extends StatelessWidget {
  const TenaWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TenaWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShellScreen(),
    );
  }
}
