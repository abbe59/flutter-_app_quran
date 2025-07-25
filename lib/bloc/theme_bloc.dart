import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class SetThemeEvent extends ThemeEvent {
  final bool isDark;
  SetThemeEvent(this.isDark);
}

// States
class ThemeState {
  final ThemeData themeData;
  final bool isDark;

  const ThemeState({required this.themeData, required this.isDark});

  ThemeState copyWith({ThemeData? themeData, bool? isDark}) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      isDark: isDark ?? this.isDark,
    );
  }
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'theme_mode';

  ThemeBloc() : super(_getInitialState()) {
    on<ToggleThemeEvent>(_onToggleTheme);
    on<SetThemeEvent>(_onSetTheme);
    _loadTheme();
  }

  static ThemeState _getInitialState() {
    return ThemeState(themeData: _getLightTheme(), isDark: false);
  }

  void _onToggleTheme(ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDark;
    final newTheme = newIsDark ? _getDarkTheme() : _getLightTheme();

    emit(ThemeState(themeData: newTheme, isDark: newIsDark));

    await _saveTheme(newIsDark);
  }

  void _onSetTheme(SetThemeEvent event, Emitter<ThemeState> emit) async {
    final newTheme = event.isDark ? _getDarkTheme() : _getLightTheme();

    emit(ThemeState(themeData: newTheme, isDark: event.isDark));

    await _saveTheme(event.isDark);
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themeKey) ?? false;
      add(SetThemeEvent(isDark));
    } catch (e) {
      add(SetThemeEvent(false));
    }
  }

  Future<void> _saveTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, isDark);
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  static ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  static ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
