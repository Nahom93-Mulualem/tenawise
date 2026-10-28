import 'package:flutter/material.dart';
import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_mode.dart';
import 'screens/main_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppLanguage.init();
  await AppThemeMode.init();
  runApp(const TenaWiseApp());
}

/// The root application widget of TenaWise (ጤና ዋይዝ).
/// Supports light and dark mode with persistent user choice.
class TenaWiseApp extends StatelessWidget {
  const TenaWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeMode.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'TenaWise',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const MainShellScreen(),
        );
      },
    );
  }
}
