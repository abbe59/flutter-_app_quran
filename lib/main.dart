import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quren_app_first/bloc/theme_bloc.dart';
import 'package:quren_app_first/screen/azkar_screen.dart';
import 'package:quren_app_first/screen/khatmah_screen.dart';
import 'package:quren_app_first/screen/surah_list_screen.dart';
import 'package:quren_app_first/screen/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'تطبيق القرآن الكريم',
            theme: state.themeData,
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/khatmahScreen': (context) => const KhatmahScreen(),
              '/surahListScreen': (context) => const SurahListScreen(),
              '/azkarMorning': (context) =>
                  const AzkarScreen(azkarType: 'morning'),
              '/azkarEvening': (context) =>
                  const AzkarScreen(azkarType: 'evening'),
            },
          );
        },
      ),
    );
  }
}
