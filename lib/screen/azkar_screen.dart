import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:quren_app_first/bloc/theme_bloc.dart';

class AzkarScreen extends StatefulWidget {
  final String azkarType; // 'morning' or 'evening'

  const AzkarScreen({Key? key, required this.azkarType}) : super(key: key);

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  late Future<List<String>> azkarFuture;

  @override
  void initState() {
    super.initState();
    azkarFuture = fetchAzkar(widget.azkarType);
  }

  Future<List<String>> fetchAzkar(String type) async {
    final url = Uri.parse('https://ahegazy.com/open_api/azkar.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      List<dynamic> list = type == 'morning'
          ? data['أذكار الصباح']
          : data['أذكار المساء'];

      // نرجع فقط النصوص
      return list.map<String>((item) => item['content'] as String).toList();
    } else {
      throw Exception('فشل تحميل الأذكار');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        final isDark = themeState.isDark;
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
                          widget.azkarType == 'morning'
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.azkarType == 'morning'
                                ? 'أذكار الصباح'
                                : 'أذكار المساء',
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
                            azkarFuture.then((azkarList) {
                              if (azkarList.isNotEmpty) {
                                // يمكنك استخدام مكتبة share_plus للمشاركة
                                // Share.share(azkarList[0]);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: FutureBuilder<List<String>>(
              future: azkarFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'حدث خطأ أثناء التحميل',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('لا توجد أذكار متاحة'));
                }

                final azkar = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(18),
                  itemCount: azkar.length,
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.97),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.13),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'ذِكر رقم ${index + 1}',
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              azkar[index],
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00695c),
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
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
