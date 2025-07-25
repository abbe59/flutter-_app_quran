import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:quren_app_first/model/ayah.dart';

class AyahListWidget extends StatelessWidget {
  final List<Ayah> ayat;
  final bool isDark;
  final double fontSize;

  const AyahListWidget({
    super.key,
    required this.ayat,
    required this.isDark,
    this.fontSize = 22,
  });

  @override
  Widget build(BuildContext context) {
    // فصل البسملة عن باقي الآيات
    final hasBasmala =
        ayat.isNotEmpty &&
        ayat.first.text.contains('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');

    final basmalaAyah = hasBasmala ? ayat.first : null;
    final mainAyat = hasBasmala ? ayat.sublist(1) : ayat;

    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFAFAFA), Color(0xFFF0F0F0)],
              ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.shade900.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400)
                    .withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.teal.withValues(alpha: 0.3)
                  : Colors.teal.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // عرض البسملة كعنوان مميز
                if (basmalaAyah != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.teal.shade800, Colors.teal.shade700]
                            : [Colors.teal.shade50, Colors.teal.shade100],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      basmalaAyah.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize + 4,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.teal.shade800,
                        height: 1.8,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],

                // عرض الآيات بتدفق طبيعي مثل الكتاب
                RichText(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.justify,
                  text: TextSpan(
                    children: _buildAyatSpans(mainAyat, isDark),
                    style: TextStyle(
                      fontSize: fontSize,
                      fontFamily: 'Amiri',
                      color: isDark ? Colors.white : Colors.black87,
                      height: 2.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                // مؤشر نهاية السورة
                if (mainAyat.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal.shade800.withValues(alpha: 0.3)
                          : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: isDark
                              ? Colors.teal.shade300
                              : Colors.teal.shade700,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'صدق الله العظيم',
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.teal.shade300
                                : Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.auto_awesome,
                          color: isDark
                              ? Colors.teal.shade300
                              : Colors.teal.shade700,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildAyatSpans(List<Ayah> ayatList, bool isDark) {
    final List<TextSpan> spans = [];

    for (int i = 0; i < ayatList.length; i++) {
      final ayah = ayatList[i];

      // نص الآية
      spans.add(
        TextSpan(
          text: ayah.text,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w400,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // نسخ النص عند الضغط
              Clipboard.setData(ClipboardData(text: ayah.text));
            },
        ),
      );

      // رقم الآية مع تصميم جميل
      spans.add(
        TextSpan(
          text: ' ﴿${ayah.numberInSurah}﴾ ',
          style: TextStyle(
            fontSize: fontSize * 0.75,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.teal.shade300 : Colors.teal.shade600,
            shadows: [
              Shadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.3,
                ),
                offset: const Offset(0.5, 0.5),
                blurRadius: 1,
              ),
            ],
          ),
        ),
      );

      // مسافة بين الآيات (إلا في النهاية)
      if (i < ayatList.length - 1) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    return spans;
  }
}
