### App

**Quick Navigation**

- [Main](#main)
- [Bootstrap](#bootstrap)
- [App](#app-1)
- [App View - Provider Wrapper](#app-view---provider-wrapper)
- [App Povider](#app-povider)

---

### Main

> `main.dart`

```dart
void main() => bootstrap();
```

---

### Bootstrap

> `bootstrap.dart`

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiClient = ApiClient();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              HomeProvider(StationRepository(StationApiService(apiClient)))
                ..loaded(),
        ),
      ],
      child: const App(),
    ),
  );
}
```

---

### App

> `app/app.dart`

```dart
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peng Houth Cycle',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}
```

---

### App View - Provider Wrapper

> `app/view/main_shell.dart`

```dart
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
```

---

### App Povider

> `app/providers/app_provider.dart`

```dart
class AppProvider extends ChangeNotifier {
  int _navIndex = 0;
  int get navIndex => _navIndex;

  void setNavIndex(int index) {
    if (_navIndex == index) return;
    _navIndex = index;
    notifyListeners();
  }
}
```

---
