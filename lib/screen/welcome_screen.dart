import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quren_app_first/bloc/theme_bloc.dart';
import 'package:quren_app_first/services/bookmark_manager.dart';
import 'package:quren_app_first/screen/bookmarks_screen.dart';
import 'package:quren_app_first/screen/surah_ayat_screen.dart';
import 'package:quren_app_first/utils/surah_names.dart';

class _QuickAzkarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  // ignore: use_super_parameters
  const _QuickAzkarButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,

    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        // تم حذف onTap لأنه غير مستخدم
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(16),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.5), width: 1.2),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // دالة للانتقال لآخر علامة مرجعية
  void _goToLastBookmark(BuildContext context) async {
    try {
      final lastRead = await BookmarkManager.getLastReadPosition();

      if (!context.mounted) return;

      if (lastRead != null) {
        // الانتقال لآخر موضع قراءة
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurahAyatScreen(
              surahNumber: lastRead['surahNumber'],
              surahName: SurahNames.getSurahNameWithNumber(
                lastRead['surahNumber'],
              ),
            ),
          ),
        );
      } else {
        // إذا لم توجد علامات، أظهر رسالة وانتقل لصفحة العلامات
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لا توجد علامات محفوظة. ابدأ بقراءة القرآن لحفظ علامات!',
            ),
            backgroundColor: Colors.blue,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookmarksScreen()),
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      // في حالة الخطأ، اذهب لصفحة العلامات
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const BookmarksScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
        // Bloc usage
        // استدعاء bloc من السياق
        // final themeBloc = BlocProvider.of<ThemeBloc>(context);
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
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(gradient: bgGradient),
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/ic_launcher.png', // ضع المسار الصحيح لصورتك هنا
                        width: 94,
                        height: 94,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'مرحباً بك في تطبيق القرآن الكريم',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.teal.shade900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 18),
                      _FeatureRow(
                        icon: Icons.wifi_off,
                        text:
                            'عرض سور وآيات القرآن الكريم بالكامل بدون إنترنت (عدا الصوتيات)',
                      ),
                      _FeatureRow(
                        icon: Icons.record_voice_over,
                        text:
                            'دعم 10 قراء مع إمكانية اختيار القارئ وتشغيل التلاوة (الصوت يحتاج إنترنت)',
                      ),
                      _FeatureRow(
                        icon: Icons.nightlight_round,
                        text:
                            'تصميم عصري مع وضع ليلي ونهاري وحفظ التفضيل تلقائياً',
                      ),
                      _FeatureRow(
                        icon: Icons.star,
                        text: 'قائمة سور مفضلة مع إمكانية الإضافة والإزالة',
                      ),
                      _FeatureRow(
                        icon: Icons.wb_sunny,
                        text:
                            'أذكار الصباح والمساء كاملة من ملف محلي بدون إنترنت، مع تصميم جذاب وأزرار نسخ ومشاركة',
                      ),
                      _FeatureRow(
                        icon: Icons.speed,
                        text: 'تصفح سريع وتجربة مستخدم عربية بالكامل',
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'أذكار الصباح',
                                icon: Icons.wb_sunny,
                                color: Colors.orange,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/azkarMorning');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'أذكار المساء',
                                icon: Icons.nights_stay,
                                color: Colors.indigo,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/azkarEvening');
                                },
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'دعاء خاتمة',
                                icon: Icons.verified,
                                color: Colors.green,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/khatmahScreen');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'قراء القرآن',
                                icon: Icons.record_voice_over,
                                color: Colors.teal,
                                onTap: () {
                                  Navigator.of(
                                    context,
                                  ).pushNamed('/surahListScreen');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // صف جديد لزر علامة القارئ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'علامة القارئ',
                                icon: Icons.bookmark,
                                color: Colors.purple,
                                onTap: () => _goToLastBookmark(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 80,
                              child: _QuickAzkarButton(
                                label: 'جميع العلامات',
                                icon: Icons.bookmarks,
                                color: Colors.deepOrange,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BookmarksScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(flex: 1, child: Container()), // مساحة فارغة
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: isDark
                              ? Colors.white.withAlpha((0.08 * 255).toInt())
                              : Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 8),
                            Text(
                              isDark
                                  ? 'الوضع الليلي مفعل'
                                  : 'الوضع النهاري مفعل',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.amber
                                    : Colors.teal.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 8),
                            // زر تبديل الوضع الليلي
                            IconButton(
                              icon: Icon(
                                isDark
                                    ? Icons.wb_sunny
                                    : Icons.nightlight_round,
                                color: isDark
                                    ? Colors.amber
                                    : Colors.teal.shade700,
                              ),
                              tooltip: isDark
                                  ? 'تفعيل النهاري'
                                  : 'تفعيل الليلي',
                              onPressed: () {
                                context.read<ThemeBloc>().add(
                                  ToggleThemeEvent(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: isDark ? Colors.tealAccent : Colors.teal, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 17,
                color: isDark ? Colors.white : Colors.teal.shade900,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
