import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:quren_app_first/model/ayah.dart';

class AyahListWidget extends StatelessWidget {
  final List<Ayah> ayat;
  final bool isDark;
  final double fontSize;
  final Function(String selectedText, int ayahNumber)? onTextSelected;
  final int? selectedAyahIndex;
  final bool isPlaying;

  const AyahListWidget({
    super.key,
    required this.ayat,
    required this.isDark,
    this.fontSize = 22,
    this.onTextSelected,
    this.selectedAyahIndex,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    // عرض البسملة في العنوان وفصلها من بداية الآيات
    Ayah? basmalaAyah;
    List<Ayah> mainAyat = [];

    // إنشاء البسملة للعنوان
    basmalaAyah = Ayah(
      text: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
      numberInSurah: 0,
    );

    // معالجة الآيات وإزالة البسملة من بدايتها
    for (final ayah in ayat) {
      final cleanText = ayah.text.trim();

      // قائمة بأشكال البسملة المختلفة
      final basmalaVariations = [
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        'بِسْمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
        'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'بسم الله الرحمن الرحيم',
      ];

      bool basmalaFound = false;
      String remainingText = cleanText;

      // البحث عن أي شكل من أشكال البسملة وإزالته
      for (String basmala in basmalaVariations) {
        if (cleanText.startsWith(basmala)) {
          remainingText = cleanText.replaceFirst(basmala, '').trim();
          basmalaFound = true;
          break;
        } else if (cleanText == basmala) {
          // إذا كانت البسملة لوحدها، تخطيها
          basmalaFound = true;
          remainingText = '';
          break;
        }
      }

      if (basmalaFound) {
        if (remainingText.isNotEmpty) {
          mainAyat.add(
            Ayah(text: remainingText, numberInSurah: ayah.numberInSurah),
          );
        }
        // إذا كانت البسملة لوحدها، لا نضيف شيء
      } else {
        // آية عادية بدون بسملة
        mainAyat.add(ayah);
      }
    }

    // إذا لم توجد آيات، استخدم القائمة الأصلية
    if (mainAyat.isEmpty && ayat.isNotEmpty) {
      mainAyat = ayat;
    }

    // للسور التي لا تحتاج بسملة (سورة التوبة فقط)
    bool isSuratTawbah = ayat.any(
      (ayah) =>
          ayah.text.contains('براءة') ||
          ayah.text.contains('التوبة') ||
          ayah.text.contains('قاتلوا الذين لا يؤمنون'),
    );

    // إذا كانت سورة التوبة، لا تعرض البسملة
    if (isSuratTawbah) {
      basmalaAyah = null;
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
                // عرض البسملة كعنوان مميز لكل السور (عدا التوبة)
                if (basmalaAyah != null) ...[
                  // مؤشر أن البسملة تم فصلها من الآيات

                  // عرض البسملة الفعلية
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

                // رسالة توضيحية للمستخدم
                if (onTextSelected != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.touch_app, color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'اضغط على أي آية لاختيار القارئ وتشغيل الصوت',
                            style: TextStyle(
                              fontSize: fontSize * 0.7,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

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

      // عرض النص كما هو (البسملة تم معالجتها مسبقاً حسب نوع السورة)
      final ayahText = ayah.text.trim();

      // تخطي الآيات الفارغة أو القصيرة جداً
      if (ayahText.isEmpty || ayahText.length < 2) {
        continue;
      }

      // نص الآية مع إمكانية التحديد والتشغيل
      final isCurrentlyPlaying =
          selectedAyahIndex == ayah.numberInSurah && isPlaying;

      spans.add(
        TextSpan(
          text: ayahText,
          style: TextStyle(
            color: isCurrentlyPlaying
                ? (isDark ? Colors.teal.shade300 : Colors.teal.shade700)
                : (isDark ? Colors.white : Colors.black87),
            fontWeight: isCurrentlyPlaying ? FontWeight.w600 : FontWeight.w400,
            backgroundColor: isCurrentlyPlaying
                ? (isDark
                      ? Colors.teal.withValues(alpha: 0.2)
                      : Colors.teal.withValues(alpha: 0.1))
                : null,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              // إظهار قائمة القراء عند الضغط على النص
              if (onTextSelected != null) {
                onTextSelected!(ayahText, ayah.numberInSurah);
              } else {
                // نسخ النص كبديل
                Clipboard.setData(ClipboardData(text: ayahText));
              }
            },
        ),
      );

      // رقم الآية مع تصميم جميل ومؤشر التشغيل
      final ayahNumberText = isCurrentlyPlaying
          ? ' ﴿${ayah.numberInSurah}﴾ 🔊 '
          : ' ﴿${ayah.numberInSurah}﴾ ';

      spans.add(
        TextSpan(
          text: ayahNumberText,
          style: TextStyle(
            fontSize: fontSize * 0.55,
            fontWeight: FontWeight.bold,
            color: isCurrentlyPlaying
                ? (isDark ? Colors.orange.shade300 : Colors.orange.shade600)
                : (isDark ? Colors.teal.shade300 : Colors.teal.shade600),
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
