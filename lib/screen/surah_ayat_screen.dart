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
  String? selectedText;
  bool isPlaying = false;

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

  // دالة لتشغيل الصوت للآية المحددة
  Future<void> playAyah(int ayahNumber) async {
    try {
      setState(() {
        isPlaying = true;
        selectedAyahIndex = ayahNumber;
      });

      // توليد رابط الصوت حسب القارئ المختار
      String surahStr = widget.surahNumber.toString().padLeft(3, '0');
      String ayahStr = ayahNumber.toString().padLeft(3, '0');
      String url;
      if (selectedReaderId == 'ar.alafasy') {
        url = 'https://verses.quran.com/Alafasy/mp3/$surahStr$ayahStr.mp3';
      } else if (selectedReaderId == 'ar.husary') {
        url = 'https://verses.quran.com/Husary/mp3/$surahStr$ayahStr.mp3';
      } else if (selectedReaderId == 'ar.minshawi') {
        url = 'https://verses.quran.com/Minshawi/mp3/$surahStr$ayahStr.mp3';
      } else if (selectedReaderId == 'ar.sudais') {
        url = 'https://verses.quran.com/Sudais/mp3/$surahStr$ayahStr.mp3';
      } else {
        // قارئ غير مدعوم، جرب العفاسي كخيار افتراضي
        url = 'https://verses.quran.com/Alafasy/mp3/$surahStr$ayahStr.mp3';
      }

      await player.stop();
      try {
        await player.setUrl(url);
        await player.play();
      } catch (e) {
        debugPrint('فشل في تحميل: $url - $e');
        if (selectedReaderId != 'ar.alafasy') {
          // جرب العفاسي إذا فشل القارئ المختار
          try {
            await player.setUrl('https://verses.quran.com/Alafasy/mp3/$surahStr$ayahStr.mp3');
            await player.play();
          } catch (e) {
            throw Exception('فشل في تحميل الصوت من جميع المصادر');
          }
        } else {
          throw Exception('فشل في تحميل الصوت من جميع المصادر');
        }
      }

      // الاستماع لانتهاء التشغيل
      player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() {
            isPlaying = false;
            selectedAyahIndex = null;
          });
        }
      });
    } catch (e) {
      setState(() {
        isPlaying = false;
        selectedAyahIndex = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في تشغيل الصوت للقارئ المحدد. جاري المحاولة مع العفاسي...',
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: () {
                // إعادة المحاولة مع العفاسي
                setState(() {
                  selectedReaderId = 'ar.alafasy';
                });
                playAyah(ayahNumber);
              },
            ),
          ),
        );
      }
    }
  }

  // دالة لإظهار قائمة القراء عند تحديد النص
  void showReaderSelectionDialog(String selectedText, int ayahNumber) {
    final readers = AudioUrlHelper.getAllReaders();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // مقبض السحب
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // العنوان
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'اختر القارئ لتشغيل الآية',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      selectedText,
                      style: const TextStyle(fontSize: 16, fontFamily: 'Amiri'),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),

            // قائمة القراء
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: readers.length,
                itemBuilder: (context, index) {
                  final reader = readers[index];
                  final isSelected = reader['id'] == selectedReaderId;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? Colors.teal
                          : Colors.grey.shade300,
                      child: Icon(
                        Icons.person,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                    title: Text(
                      reader['name']!,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.teal : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.teal)
                        : const Icon(Icons.play_arrow),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        selectedReaderId = reader['id']!;
                      });
                      playAyah(ayahNumber);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
                return AyahListWidget(
                  ayat: ayat,
                  isDark: isDark,
                  onTextSelected: showReaderSelectionDialog,
                  selectedAyahIndex: selectedAyahIndex,
                  isPlaying: isPlaying,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
