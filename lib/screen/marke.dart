import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkeScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? lastAyahIndex;
  const MarkeScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.lastAyahIndex,
  });

  @override
  State<MarkeScreen> createState() => _MarkeScreenState();
}

class _MarkeScreenState extends State<MarkeScreen> {
  int? lastAyahIndex;

  @override
  void initState() {
    super.initState();
    _loadMarke();
  }

  Future<void> _loadMarke() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      lastAyahIndex = prefs.getInt('marke_${widget.surahNumber}') ?? widget.lastAyahIndex;
    });
  }

  Future<void> _saveMarke(int ayahIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('marke_${widget.surahNumber}', ayahIndex);
    setState(() {
      lastAyahIndex = ayahIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('علامتي في سورة ${widget.surahName}'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lastAyahIndex != null
                  ? 'آخر آية وصلت إليها: رقم $lastAyahIndex'
                  : 'لم يتم وضع علامة بعد',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.bookmark_add),
              label: const Text('وضع علامة عند الآية الحالية'),
              onPressed: () {
                // مثال: ضع علامة عند آية رقم 5 (يمكنك تمرير رقم الآية من الشاشة الأخرى)
                _saveMarke(widget.lastAyahIndex ?? 1);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: const Text('الرجوع للآية المحددة'),
              onPressed: lastAyahIndex != null
                  ? () {
                      Navigator.of(context).pop(lastAyahIndex);
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
