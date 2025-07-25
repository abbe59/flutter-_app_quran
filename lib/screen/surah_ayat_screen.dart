import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quren_app_first/bloc/theme_bloc.dart';
import 'package:quren_app_first/model/ayah.dart';
import 'dart:convert';

import 'package:quren_app_first/model/reader.dart';

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
  int? selectedAyahIndex;
  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  late Future<List<Ayah>> ayatFuture;
  late Future<List<Reader>> readersFuture;
  String? selectedReaderId;
  String? selectedReaderName;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    ayatFuture = fetchAyat(widget.surahNumber, readerId: 'ar.alafasy');
    readersFuture = loadReaders();
    selectedReaderId = 'ar.alafasy';
    selectedReaderName = 'مشاري راشد العفاسي';
  }

  Future<List<Ayah>> fetchAyat(
    int surahNumber, {
    required String readerId,
    bool forceApi = false,
  }) async {
    if (forceApi) {
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
    // الصوت يحتاج إنترنت دائماً، أما النصوص فجرب من الإنترنت ثم من الملف المحلي
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
    // fallback: من الملف المحلي
    final localString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/quran_ayahs.json');
    final Map ayatMap = json.decode(localString);
    final List ayatJson = ayatMap[surahNumber.toString()] ?? [];
    return ayatJson.map((json) => Ayah.fromJson(json)).toList();
  }

  Future<List<Reader>> loadReaders() async {
    final yamlString = await rootBundle.loadString('assets/readers.yaml');
    final yaml = const LineSplitter().convert(yamlString.replaceAll('\r', ''));
    final List<Reader> readers = [];
    for (var line in yaml) {
      if (line.trim().startsWith('- id:')) {
        final id = line.split(':')[1].trim();
        final nameLine = yaml[yaml.indexOf(line) + 1];
        final name = nameLine.split(':')[1].trim().replaceAll('"', '');
        readers.add(Reader(id: id, name: name));
      }
    }
    // إضافة القارئ الافتراضي (العفاسي)
    readers.insert(3, Reader(id: 'ar.alafasy', name: 'مشاري راشد العفاسي'));
    return readers;
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
                        Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'قائمة السور القران الكريم',
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
                          icon: const Icon(
                            Icons.share_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            // azkarFuture.then((azkarList) {
                            // if (azkarList.isNotEmpty) {
                            //   // يمكنك استخدام مكتبة share_plus للمشاركة
                            //   //  Share.share(azkarList[0]);
                            // }
                            // });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                FutureBuilder<List<Reader>>(
                  future: readersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: LinearProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('خطأ في تحميل القراء'),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('لا يوجد قراء'),
                      );
                    }
                    final readers = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(right: 8, bottom: 4),
                            child: Icon(Icons.add_ic_call_rounded),
                          ),
                          SizedBox(
                            height: 48,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: readers.length,
                              separatorBuilder: (context, i) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, i) {
                                final reader = readers[i];
                                final isSelected =
                                    reader.id == selectedReaderId;
                                return ChoiceChip(
                                  label: Text(
                                    reader.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedColor: Colors.teal.shade700,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).chipTheme.backgroundColor,
                                  elevation: isSelected ? 4 : 0,
                                  pressElevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.green.shade700
                                          : Colors.grey.shade300,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        selectedReaderId = reader.id;
                                        selectedReaderName = reader.name;
                                        ayatFuture = fetchAyat(
                                          widget.surahNumber,
                                          readerId: selectedReaderId!,
                                          forceApi: true,
                                        );
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
                  child: FutureBuilder<List<Ayah>>(
                    future: ayatFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                color: Colors.red,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'تعذر جلب الآيات من الإنترنت لهذا القارئ.\nيرجى التأكد من الاتصال بالإنترنت أو اختيار قارئ آخر.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('لا توجد آيات'));
                      }
                      final ayat = snapshot.data!;
                      final isDark =
                          Theme.of(context).brightness == Brightness.dark;
                      final bgGradient = isDark
                          ? const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFF23272F), Color(0xFF121212)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFFe8f5e9), Color(0xFFb2dfdb)],
                            );
                      final cardColor = isDark
                          ? Theme.of(context).cardColor
                          : Colors.white.withAlpha((0.95 * 255).toInt());
                      final textColor = isDark
                          ? Colors.white
                          : const Color(0xFF00695c);
                      final numberBg = isDark
                          ? Colors.teal.shade900
                          : Colors.teal.shade100;
                      final numberColor = isDark
                          ? Colors.white
                          : const Color(0xFF00695c);
                      return Container(
                        decoration: BoxDecoration(gradient: bgGradient),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: ayat.length,
                          itemBuilder: (context, i) {
                            final ayah = ayat[i];
                            final isSelected = selectedAyahIndex == i;
                            return GestureDetector(
                              onTap: () async {
                                setState(() {
                                  selectedAyahIndex = i;
                                });
                                final surah = widget.surahNumber
                                    .toString()
                                    .padLeft(3, '0');
                                final ayahNum = ayah.numberInSurah
                                    .toString()
                                    .padLeft(3, '0');
                                String url =
                                    'https://verses.quran.com/Alafasy/mp3/$surah$ayahNum.mp3';
                                await player.setUrl(url);
                                await player.play();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? Colors.green.shade900.withAlpha(
                                                (0.35 * 255).toInt(),
                                              )
                                            : Colors.green.shade100.withAlpha(
                                                (0.7 * 255).toInt(),
                                              ))
                                      : cardColor,
                                  borderRadius: BorderRadius.circular(22),
                                  border: isSelected
                                      ? Border.all(
                                          color: Colors.green,
                                          width: 2.5,
                                        )
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.teal.withAlpha(
                                        (0.10 * 255).toInt(),
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 24,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: numberBg,
                                        child: Text(
                                          ayah.numberInSurah.toString(),
                                          style: TextStyle(
                                            color: numberColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          ayah.text,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            height: 1.7,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Icon(
                                        isSelected
                                            ? Icons.play_circle_fill
                                            : Icons.play_circle_outline,
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.teal,
                                        size: 38,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
