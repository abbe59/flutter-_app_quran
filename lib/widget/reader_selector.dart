// الملف الجديد: reader_selector_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import '../model/reader.dart';

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
    readers.insert(3, Reader(id: 'ar.alafasy', name: 'مشاري راشد العفاسي'));
    return readers;
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
