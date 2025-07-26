// الملف الجديد: reader_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../model/reader.dart';

// دالة مساعدة لإنشاء URLs للقراء
class AudioUrlHelper {
  static List<String> getAudioUrls(
    String readerId,
    int surahNumber,
    int ayahNumber,
  ) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayahNum = ayahNumber.toString().padLeft(3, '0');

    // تحديد مجلد القارئ
    String readerFolder;
    switch (readerId) {
      case 'ar.alafasy':
        readerFolder = 'Alafasy';
        break;
      case 'ar.abdurrahmaansudais':
        readerFolder = 'Abdurrahmaan_As-Sudais';
        break;
      case 'ar.mahermuaiqly':
        readerFolder = 'Maher_AlMuaiqly';
        break;
      case 'ar.saoodshuraym':
        readerFolder = 'Saood_ash-Shuraym';
        break;
      case 'ar.abdulbasitmurattal':
        readerFolder = 'Abdul_Basit_Murattal';
        break;
      case 'ar.hanirifai':
        readerFolder = 'Hani_Rifai';
        break;
      case 'ar.shaatree':
        readerFolder = 'Abu_Bakr_Ash-Shaatree';
        break;
      case 'ar.idrisabkar':
        readerFolder = 'Idris_Abkar';
        break;
      case 'ar.sobhi':
        readerFolder = 'Sobhi';
        break;
      default:
        readerFolder = 'Alafasy';
    }

    // إرجاع قائمة URLs للتجربة
    return [
      'https://verses.quran.com/$readerFolder/mp3/$surah$ayahNum.mp3',
      'https://cdn.islamic.network/quran/audio/128/$readerId/$ayahNumber.mp3',
      'https://audio.qurancdn.com/$readerId/$ayahNumber.mp3',
    ];
  }

  static List<Map<String, String>> getAllReaders() {
    return [
      {'id': 'ar.alafasy', 'name': 'مشاري العفاسي'},
      {'id': 'ar.abdurrahmaansudais', 'name': 'عبد الرحمن السديس'},
      {'id': 'ar.mahermuaiqly', 'name': 'ماهر المعيقلي'},
      {'id': 'ar.saoodshuraym', 'name': 'سعود الشريم'},
      {'id': 'ar.abdulbasitmurattal', 'name': 'عبد الباسط عبد الصمد'},
      {'id': 'ar.hanirifai', 'name': 'هاني الرفاعي'},
      {'id': 'ar.shaatree', 'name': 'أبو بكر الشاطري'},
      {'id': 'ar.idrisabkar', 'name': 'إدريس أبكر'},
      {'id': 'ar.sobhi', 'name': 'صبحي'},
    ];
  }
}

class ReaderSelector extends StatelessWidget {
  final String? selectedReaderId;
  final Function(String id, String name) onReaderSelected;

  const ReaderSelector({
    super.key,
    required this.selectedReaderId,
    required this.onReaderSelected,
  });

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
    // إضافة القراء المشهورين مع القراء الجدد
    final popularReaders = [
      Reader(id: 'ar.alafasy', name: 'مشاري راشد العفاسي'),
      Reader(id: 'ar.abdurrahmaansudais', name: 'عبد الرحمن السديس'),
      Reader(id: 'ar.mahermuaiqly', name: 'ماهر المعيقلي'),
      Reader(id: 'ar.saoodshuraym', name: 'سعود الشريم'),
      Reader(id: 'ar.abdulbasitmurattal', name: 'عبد الباسط عبد الصمد'),
      Reader(id: 'ar.hanirifai', name: 'هاني الرفاعي'),
      Reader(id: 'ar.shaatree', name: 'أبو بكر الشاطري'),
      Reader(id: 'ar.idrisabkar', name: 'إدريس أبكر'),
      Reader(id: 'ar.sobhi', name: 'صبحي'),
    ];

    // دمج القراء المشهورين مع القراء من الملف
    final allReaders = <Reader>[];
    allReaders.addAll(popularReaders);

    // إضافة القراء الآخرين من الملف (تجنب التكرار)
    for (var reader in readers) {
      if (!popularReaders.any((popular) => popular.id == reader.id)) {
        allReaders.add(reader);
      }
    }

    return allReaders;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Reader>>(
      future: loadReaders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8, bottom: 4),
                child: Icon(Icons.record_voice_over),
              ),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: readers.length,
                  separatorBuilder: (context, i) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final reader = readers[i];
                    final isSelected = reader.id == selectedReaderId;
                    return ChoiceChip(
                      label: Text(
                        reader.name,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
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
                          onReaderSelected(reader.id, reader.name);
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
    );
  }
}
