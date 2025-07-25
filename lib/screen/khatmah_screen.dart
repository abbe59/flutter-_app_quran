import 'package:flutter/material.dart';

class KhatmahScreen extends StatelessWidget {
  const KhatmahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF23272F), Color(0xFF181C23)],
          )
        : const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFe0f7fa), Color(0xFFb2dfdb)],
          );
    const khatmahText = '''
اللهم ارحمني بالقرآن، واجعله لي إمامًا ونورًا وهدًى ورحمة.
اللهم ذكرني منه ما نسيت، وعلمني منه ما جهلت، وارزقني تلاوته آناء الليل وأطراف النهار، واجعله لي حجة يا رب العالمين.
اللهم أصلح لي ديني الذي هو عصمة أمري، وأصلح لي دنياي التي فيها معاشي، وأصلح لي آخرتي التي فيها معادي، واجعل الحياة زيادة لي في كل خير، واجعل الموت راحة لي من كل شر.
اللهم اجعل خير عمري آخره، وخير عملي خواتمه، وخير أيامي يوم ألقاك فيه.
اللهم إني أسألك عيشة هنية، وميتة سوية، ومردًا غير مخزٍ ولا فاضح.
اللهم اجعلنا من الذين يتلون كتابك حق تلاوته، ويتبعون أوامرك، ويجتنبون نواهيك، وارزقنا شفاعة القرآن يوم القيامة.
''';
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'دعاء ختم القرآن',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              color: isDark
                  ? Colors.white.withAlpha((0.07 * 255).toInt())
                  : Colors.white.withAlpha((0.95 * 255).toInt()),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Text(
                    khatmahText,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF00695c),
                      height: 1.7,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
