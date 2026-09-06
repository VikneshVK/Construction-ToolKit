import 'package:flutter/material.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'features/home/home_screen.dart';
import 'features/materials/materials_screen.dart';
import 'features/roofing/roofing_screen.dart';
import 'features/stairs/stairs_screen.dart';
import 'features/measurements/measurements_screen.dart';
import 'features/history/history_screen.dart';

/// Main Application Shell managing bottom navigation and category switching.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onSelectCategory: _navigateToIndex),
      const MaterialsScreen(),
      const RoofingScreen(),
      const StairsScreen(),
      const MeasurementsScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1.0)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateToIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.bgSurface,
          selectedItemColor: AppColors.brandGold,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: AppTypography.badgeText.copyWith(fontSize: 10),
          unselectedLabelStyle: AppTypography.helperText.copyWith(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.foundation_outlined),
              activeIcon: Icon(Icons.foundation),
              label: 'Materials',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.roofing_outlined),
              activeIcon: Icon(Icons.roofing),
              label: 'Roofing',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stairs_outlined),
              activeIcon: Icon(Icons.stairs),
              label: 'Stairs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.straighten_outlined),
              activeIcon: Icon(Icons.straighten),
              label: 'Measure',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Logs',
            ),
          ],
        ),
      ),
    );
  }
}
