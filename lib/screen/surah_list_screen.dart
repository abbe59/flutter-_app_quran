import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'package:quren_app_first/widget/gradient_scaffold.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quren_app_first/bloc/theme_bloc.dart';
import 'package:quren_app_first/model/surah.dart';
import 'package:quren_app_first/screen/surah_ayat_screen.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  late Future<List<Surah>> surahsFuture;
  Set<int> favoriteSurahs = {};

  @override
  void initState() {
    super.initState();
    surahsFuture = _fetchSurahs();
    _loadFavorites();
  }

  Future<List<Surah>> _fetchSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahsJson = data['data'];
        return surahsJson.map((json) => Surah.fromJson(json)).toList();
      }
    } catch (_) {}
    // fallback
    if (mounted) {
      final localString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/quran_surahs.json');
      final List surahsJson = json.decode(localString);
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('favoriteSurahs');
    if (stored != null) {
      setState(() => favoriteSurahs = stored.map(int.parse).toSet());
    }
  }

  Future<void> _toggleFavorite(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteSurahs.contains(surahNumber)
          ? favoriteSurahs.remove(surahNumber)
          : favoriteSurahs.add(surahNumber);
    });
    prefs.setStringList(
      'favoriteSurahs',
      favoriteSurahs.map((n) => n.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: 'قائمة السور القران الكريم',
      child: FutureBuilder<List<Surah>>(
        future: surahsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد بيانات'));
          }

          final surahs = snapshot.data!;
          final isDark = context.read<ThemeBloc>().state.isDark;

          return AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: surahs.length,
              separatorBuilder: (context, i) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final surah = surahs[i];
                return AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  child: SlideAnimation(
                    verticalOffset: 70.0,
                    curve: Curves.easeInOut,
                    child: FadeInAnimation(
                      child: _SurahCard(
                        surah: surah,
                        isFavorite: favoriteSurahs.contains(surah.number),
                        isDark: isDark,
                        onFavorite: () => _toggleFavorite(surah.number),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SurahAyatScreen(
                                surahNumber: surah.number,
                                surahName: surah.name,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Surah surah;
  final bool isFavorite;
  final bool isDark;
  final VoidCallback onFavorite;
  final VoidCallback onTap;
  const _SurahCard({
    required this.surah,
    required this.isFavorite,
    required this.isDark,
    required this.onFavorite,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final cardColor = isDark
        // ignore: deprecated_member_use
        ? Colors.grey.shade800.withOpacity(0.9)
        : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.grey.shade300 : Colors.grey.shade600;
    return Card(
      color: cardColor,
      elevation: isDark ? 6 : 2,
      shadowColor: isDark
          // ignore: deprecated_member_use
          ? Colors.black.withOpacity(0.5)
          // ignore: deprecated_member_use
          : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDark
            // ignore: deprecated_member_use
            ? BorderSide(color: Colors.teal.withOpacity(0.3), width: 1)
            : BorderSide.none,
      ),
      child: ListTile(
        title: Text(
          surah.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
          ),
        ),
        subtitle: Text(
          'عدد الآيات: ${surah.ayahsCount}',
          style: TextStyle(fontSize: 14, color: subtitleColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                color: isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onFavorite,
              tooltip: isFavorite ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            ),
            CircleAvatar(
              backgroundColor: isDark
                  // ignore: deprecated_member_use
                  ? Colors.teal.shade700.withOpacity(0.8)
                  : Colors.green.shade100,
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
