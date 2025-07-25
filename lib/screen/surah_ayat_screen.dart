import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:quren_app_first/model/ayah.dart';
import 'package:quren_app_first/widget/gradient_scaffold.dart';
import 'package:quren_app_first/widget/ayah_list_widget.dart';
import 'package:quren_app_first/widget/reader_selector.dart';
import 'dart:convert';

class SurahAyatScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahAyatScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahAyatScreen> createState() => _SurahAyatScreenState();
}

class _SurahAyatScreenState extends State<SurahAyatScreen> {
  late Future<List<Ayah>> ayatFuture;
  String selectedReaderId = 'ar.alafasy';
  final AudioPlayer player = AudioPlayer();
  int? selectedAyahIndex;

  @override
  void initState() {
    super.initState();
    ayatFuture = fetchAyat(widget.surahNumber, readerId: selectedReaderId);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  Future<List<Ayah>> fetchAyat(
    int surahNumber, {
    required String readerId,
    bool forceApi = false,
  }) async {
    if (forceApi || readerId != 'ar.alafasy') {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/$readerId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayatJson = data['data']['ayahs'];
        return ayatJson.map((json) => Ayah.fromJson(json)).toList();
      } else {
        throw Exception('فشل في جلب الآيات من الإنترنت');
      }
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/$readerId'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List ayatJson = data['data']['ayahs'];
        return ayatJson.map((json) => Ayah.fromJson(json)).toList();
      }
    } catch (_) {}

    if (mounted) {
      final localString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/quran_ayahs.json');
      final Map ayatMap = json.decode(localString);
      final List ayatJson = ayatMap[surahNumber.toString()] ?? [];
      return ayatJson.map((json) => Ayah.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      title: ' ${widget.surahName}',
      child: Column(
        children: [
          ReaderSelector(
            selectedReaderId: selectedReaderId,
            onReaderSelected: (id, name) {
              setState(() {
                selectedReaderId = id;
                ayatFuture = fetchAyat(
                  widget.surahNumber,
                  readerId: selectedReaderId,
                  forceApi: true,
                );
              });
            },
          ),
          Expanded(
            child: FutureBuilder<List<Ayah>>(
              future: ayatFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'تعذر جلب الآيات. تحقق من الاتصال أو اختر قارئ آخر.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد آيات'));
                }

                final ayat = snapshot.data!;
                return AyahListWidget(ayat: ayat, isDark: isDark);
              },
            ),
          ),
        ],
      ),
    );
  }
}
