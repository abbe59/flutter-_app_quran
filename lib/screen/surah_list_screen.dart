import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quren_app_first/model/surah.dart'; // تأكد أن لديك ملف surah.dart
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
    final localString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/quran_surahs.json');
    final List surahsJson = json.decode(localString);
    return surahsJson.map((json) => Surah.fromJson(json)).toList();
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
      favoriteSurahs.map((num) => num.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('القران الكريم'),
        backgroundColor: Colors.teal.shade700,
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFe0f7fa), Color(0xFFb2dfdb)],
          ),
        ),
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
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    title: Text(
                      surah.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    subtitle: Text(
                      'عدد الآيات: ${surah.ayahsCount}',
                      style: const TextStyle(fontSize: 14),
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
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            surah.number.toString(),
                            style: const TextStyle(color: Colors.green),
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
  }
}
