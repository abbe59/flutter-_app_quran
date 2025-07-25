import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quren_app_first/bloc/theme_bloc.dart';

class KhatmahScreen extends StatelessWidget {
  const KhatmahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const khatmahText = '''
اللهم ارحمني بالقرآن، واجعله لي إمامًا ونورًا وهدًى ورحمة.
اللهم ذكرني منه ما نسيت، وعلمني منه ما جهلت، وارزقني تلاوته آناء الليل وأطراف النهار، واجعله لي حجة يا رب العالمين.
اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي فيها معادي، واجعل الحياة زيادة لي في كل خير، واجعل الموت راحة لي من كل شر.
اللهم اجعل خير عمري آخره، وخير عملي خواتمه، وخير أيامي يوم ألقاك فيه.
اللهم إني أسألك عيشة هنية، وميتة سوية، ومردًا غير مخزٍ ولا فاضح.
اللهم اجعلنا من الذين يتلون كتابك حق تلاوته، ويتبعون أوامرك، ويجتنبون نواهيك، وارزقنا شفاعة القرآن يوم القيامة.
''';
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;

        // تحديد ألوان الخلفية حسب الوضع
        final bgGradient = isDark
            ? const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF181C23), Color(0xFF23272F)],
              )
            : const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFe0f7fa), Color(0xFFb2dfdb)],
              );
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Color(0xFF181C23),
                      Color(0xFF23272F),
                      Color(0xFF1A1A1A),
                    ] // الوضع الليلي
                  : [
                      Color(0xFFe0f7fa),
                      Color(0xFFb2dfdb),
                      Color(0xFFe8f5e9),
                    ], // الوضع النهاري
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: PreferredSize(
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
                      color: Colors.teal.withOpacity(0.18),
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
                            'دعاءالخاتمة',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isDark ? Icons.wb_sunny : Icons.nightlight_round,
                            color: isDark ? Colors.amber : Colors.teal.shade700,
                          ),
                          onPressed: () {
                            context.read<ThemeBloc>().add(ToggleThemeEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Container(
              decoration: BoxDecoration(gradient: bgGradient),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    color: isDark
                        ? Colors.white.withAlpha((0.07 * 255).toInt())
                        : Colors.white.withAlpha((0.95 * 255).toInt()),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: SingleChildScrollView(
                        child: Text(
                          khatmahText,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF00695c),
                            height: 1.7,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
