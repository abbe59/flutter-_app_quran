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
    Ayah? basmalaAyah;
    List<Ayah> mainAyat = ayat;

    // البحث عن البسملة في الآية الأولى أو كآية منفصلة
    if (ayat.isNotEmpty) {
      final firstAyah = ayat.first;

      final basmalaText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      final cleanText = firstAyah.text.trim();

      // التحقق من وجود البسملة بطرق مختلفة
      bool hasBasmala =
          cleanText.contains(basmalaText) ||
          cleanText.contains('بسم الله الرحمن الرحيم') ||
          cleanText.startsWith('بِسْمِ') ||
          cleanText.startsWith('بسم');

      if (hasBasmala) {
        // إذا كانت الآية تحتوي على البسملة فقط
        if (cleanText == basmalaText ||
            cleanText == 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ' ||
            cleanText.replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), '').trim() ==
                basmalaText) {
          basmalaAyah = firstAyah;
          mainAyat = ayat.length > 1 ? ayat.sublist(1) : [];
        }
        // إذا كانت الآية تحتوي على البسملة مع نص إضافي
        else {
          // إنشاء آية البسملة منفصلة
          basmalaAyah = Ayah(text: basmalaText, numberInSurah: 0);

          // إزالة البسملة من النص الأصلي
          String remainingText = cleanText
              .replaceFirst(basmalaText, '')
              .replaceFirst('بسم الله الرحمن الرحيم', '')
              .replaceFirst(
                RegExp(r'بِسْمِ\s+اللَّهِ\s+الرَّحْمَٰنِ\s+الرَّحِيمِ'),
                '',
              )
              .trim();

          // تنظيف النص من المسافات الزائدة
          remainingText = remainingText.replaceAll(RegExp(r'\s+'), ' ').trim();

          if (remainingText.isNotEmpty) {
            final modifiedFirstAyah = Ayah(
              text: remainingText,
              numberInSurah: firstAyah.numberInSurah,
            );
            mainAyat = [modifiedFirstAyah, ...ayat.sublist(1)];
          } else {
            mainAyat = ayat.length > 1 ? ayat.sublist(1) : [];
          }
        }
      }
    }

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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 17),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          margin: const EdgeInsets.symmetric(horizontal: 7),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey.shade900.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : Colors.grey.shade400)
                    .withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 2),
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
                // عرض البسملة كعنوان مميز ومنفصل
                if (basmalaAyah != null) ...[
                  // مؤشر أن البسملة تم فصلها
                  if (mainAyat.length != ayat.length)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'تم فصل البسملة',
                            style: TextStyle(
                              fontSize: fontSize * 0.7,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 10,
                    ),
                    margin: const EdgeInsets.only(bottom: 25),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [Colors.teal.shade800, Colors.teal.shade600]
                            : [Colors.teal.shade100, Colors.teal.shade50],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? Colors.teal.withValues(alpha: 0.5)
                            : Colors.teal.withValues(alpha: 0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // أيقونة أو رمز للبسملة
                        Icon(
                          Icons.auto_awesome,
                          color: isDark
                              ? Colors.teal.shade300
                              : Colors.teal.shade700,
                          size: 14,
                        ),
                        const SizedBox(height: 2),
                        // نص البسملة
                        Text(
                          basmalaAyah.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize + 2,
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.teal.shade800,
                            height: 1.2,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: (isDark ? Colors.black : Colors.grey)
                                    .withValues(alpha: 0.3),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        // خط فاصل زخرفي
                        Container(
                          height: 2,
                          width: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                isDark
                                    ? Colors.teal.shade400
                                    : Colors.teal.shade600,
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
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
                      height: 1.6,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),

                // مؤشر نهاية السورة
                if (mainAyat.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.teal.shade800.withValues(alpha: 0.3)
                          : Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.teal.withValues(alpha: 0.4),
                        width: 4,
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
                        const SizedBox(width: 10),
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
            fontSize: fontSize * 0.55,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.teal.shade300 : Colors.teal.shade600,
            shadows: [
              Shadow(
                color: (isDark ? Colors.black : Colors.grey).withValues(
                  alpha: 0.8,
                ),
                offset: const Offset(0.0, 0.0),
                blurRadius: 0,
              ),
            ],
          ),
        ),
      );

      // مسافة بين الآيات (إلا في النهاية)
      if (i < ayatList.length - 1) {
        spans.add(const TextSpan(text: ''));
      }
    }

    return spans;
  }
}
