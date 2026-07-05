import 'package:flutter/material.dart';
import 'package:peng_houth_cycle/features/home/presentation/screens/home_screen.dart';
import 'package:peng_houth_cycle/features/settings/presentation/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _screens = [
    //
    HomeScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navIndex = context.watch<AppProvider>().navIndex;

    return Scaffold(
      body: IndexedStack(index: navIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,
        onDestinationSelected: context.read<AppProvider>().setNavIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
