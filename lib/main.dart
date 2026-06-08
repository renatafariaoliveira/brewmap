import 'package:brewmap/core/config/locator.dart';
import 'package:brewmap/core/storage/hive_service.dart';
import 'package:brewmap/core/theme/theme.dart';
import 'package:brewmap/features/breweries/map_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrap();
  final initialThemeMode = await getIt<HiveStorageService>().loadThemeMode();
  runApp(BrewMap(initialThemeMode: initialThemeMode));
}

class BrewMap extends StatefulWidget {
  const BrewMap({super.key, this.initialThemeMode = ThemeMode.dark});

  final ThemeMode initialThemeMode;

  @override
  State<BrewMap> createState() => _BrewMapState();
}

class _BrewMapState extends State<BrewMap> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  Future<void> _toggleTheme() async {
    final nextMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() => _themeMode = nextMode);
    await getIt<HiveStorageService>().saveThemeMode(nextMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BrewMap',
      debugShowCheckedModeBanner: false,
      theme: buildBrewLightTheme(),
      darkTheme: buildBrewDarkTheme(),
      themeMode: _themeMode,
      home: MapScreen(onToggleTheme: _toggleTheme),
    );
  }
}
