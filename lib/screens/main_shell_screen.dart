import 'package:flutter/material.dart';
import '../core/localization/app_language.dart';
import '../core/theme/app_colors.dart';
import 'home/home_screen.dart';
import 'cycle/cycle_screen.dart';
import 'library/library_screen.dart';
import 'assistant/assistant_screen.dart';

/// MainShellScreen hosts the primary bottom navigation bar and coordinates
/// state preservation across all four core modules of TenaWise.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          // IndexedStack preserves state across screens (scroll positions, form inputs, etc.)
          body: IndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateToTab: _onTabSelected),
              const CycleScreen(),
              const LibraryScreen(),
              const AssistantScreen(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.secondaryContainer,
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home, color: AppColors.primary),
                label: isAmharic ? 'መነሻ' : 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: const Icon(Icons.calendar_month, color: AppColors.primary),
                label: isAmharic ? 'ዑደት' : 'Cycle',
              ),
              NavigationDestination(
                icon: const Icon(Icons.menu_book_outlined),
                selectedIcon: const Icon(Icons.menu_book, color: AppColors.primary),
                label: isAmharic ? 'ቤተ-መጽሐፍት' : 'Library',
              ),
              NavigationDestination(
                icon: const Icon(Icons.question_answer_outlined),
                selectedIcon: const Icon(Icons.question_answer, color: AppColors.primary),
                label: isAmharic ? 'ጤና ዋይዝ' : 'Ask TenaWise',
              ),
            ],
          ),
        );
      },
    );
  }
}
