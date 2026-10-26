import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/localization/app_language.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/animated_fav_launcher.dart';
import '../core/widgets/fade_indexed_stack.dart';
import 'home/home_screen.dart';
import 'cycle/cycle_screen.dart';
import 'library/library_screen.dart';
import 'assistant/assistant_screen.dart';

/// MainShellScreen hosts the primary bottom navigation bar and coordinates
/// state preservation across all four core modules of TenaWise.
/// Enhanced with Apple-style tactile haptic selection feedback and fluid
/// cross-fade transitions between modules.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppLanguage.isAmharicNotifier,
      builder: (context, isAmharic, _) {
        return Scaffold(
          // FadeIndexedStack preserves state while smoothly cross-fading and gliding between tabs
          body: FadeIndexedStack(
            index: _currentIndex,
            children: [
              HomeScreen(onNavigateToTab: _onTabSelected),
              const CycleScreen(),
              const LibraryScreen(),
              const AssistantScreen(),
            ],
          ),
          floatingActionButton: _currentIndex != 3
              ? AnimatedFavLauncher(
                  onTap: () => _onTabSelected(3),
                  isAmharic: isAmharic,
                )
              : null,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppColors.outlineVariant.withValues(alpha: 0.35),
                  width: 0.8,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.secondaryContainer,
              elevation: 0,
              height: 68,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primary),
                  label: isAmharic ? 'መነሻ' : 'Home',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.calendar_month_outlined),
                  selectedIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                  label: isAmharic ? 'ዑደት' : 'Cycle',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.menu_book_outlined),
                  selectedIcon: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                  label: isAmharic ? 'ቤተ-መጽሐፍት' : 'Library',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.auto_awesome_outlined),
                  selectedIcon: const Icon(Icons.auto_awesome, color: AppColors.primary),
                  label: isAmharic ? 'ጤና ዋይዝ' : 'TenaWise AI',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
