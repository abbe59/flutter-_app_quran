import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/theme_bloc.dart'; // تأكد من المسار الصحيح

class GradientScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showThemeToggle;
  final PreferredSizeWidget? customAppBar;

  // ignore: use_super_parameters
  const GradientScaffold({
    Key? key,
    required this.child,
    required this.title,
    this.showThemeToggle = true,
    this.customAppBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [Color(0xFF181C23), Color(0xFF23272F), Color(0xFF1A1A1A)]
                  : [Color(0xFFe0f7fa), Color(0xFFb2dfdb), Color(0xFFe8f5e9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar:
                customAppBar ??
                PreferredSize(
                  preferredSize: const Size.fromHeight(90),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade700, Colors.teal.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 35),
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (showThemeToggle)
                              IconButton(
                                icon: Icon(
                                  isDark
                                      ? Icons.wb_sunny
                                      : Icons.nightlight_round,
                                  color: isDark
                                      ? Colors.amber
                                      : Colors.teal.shade700,
                                ),
                                onPressed: () {
                                  context.read<ThemeBloc>().add(
                                    ToggleThemeEvent(),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            body: child,
          ),
        );
      },
    );
  }
}
