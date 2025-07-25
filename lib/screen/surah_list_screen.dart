import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
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
    surahsFuture = fetchSurahs();
    loadFavorites();
  }

  Future<List<Surah>> fetchSurahs() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List surahsJson = data['data'];
        return surahsJson.map((json) => Surah.fromJson(json)).toList();
      }
    } catch (_) {
      // استثناء بصمت
    }

    // fallback للبيانات المحلية
    if (mounted) {
      final localString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/quran_surahs.json');
      final List surahsJson = json.decode(localString);
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    }
    return [];
  }

  /// 🔁 تحميل السور المفضلة من التخزين المحلي
  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? storedFavorites = prefs.getStringList('favoriteSurahs');
    if (storedFavorites != null) {
      setState(() {
        favoriteSurahs = storedFavorites.map(int.parse).toSet();
      });
    }
  }

  /// ⭐️ إضافة أو إزالة السورة من المفضلة
  Future<void> toggleFavorite(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteSurahs.contains(surahNumber)) {
        favoriteSurahs.remove(surahNumber);
      } else {
        favoriteSurahs.add(surahNumber);
      }
    });
    prefs.setStringList(
      'favoriteSurahs',
      favoriteSurahs.map((number) => number.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('القرآن الكريم'),
            backgroundColor: isDark
                ? Colors.teal.shade800
                : Colors.teal.shade700,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(gradient: bgGradient),
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
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: surahs.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final surah = surahs[i];

                    // تحديد ألوان البطاقة حسب الوضع
                    final cardColor = isDark
                        ? Colors.grey.shade800.withValues(alpha: 0.9)
                        : Colors.white;
                    final textColor = isDark ? Colors.white : Colors.black;
                    final subtitleColor = isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade600;

                    return Card(
                      color: cardColor,
                      elevation: isDark ? 6 : 2,
                      shadowColor: isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: isDark
                            ? BorderSide(
                                color: Colors.teal.withValues(alpha: 0.3),
                                width: 1,
                              )
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
                                favoriteSurahs.contains(surah.number)
                                    ? Icons.star
                                    : Icons.star_border,
                                color: favoriteSurahs.contains(surah.number)
                                    ? Colors.amber
                                    : Colors.grey,
                              ),
                              onPressed: () => toggleFavorite(surah.number),
                              tooltip: favoriteSurahs.contains(surah.number)
                                  ? 'إزالة من المفضلة'
                                  : 'إضافة إلى المفضلة',
                            ),
                            CircleAvatar(
                              backgroundColor: isDark
                                  ? Colors.teal.shade700.withValues(alpha: 0.8)
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
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
