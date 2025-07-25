class Surah {
  final int number;
  final String name;
  final String englishName;
  final int ayahsCount;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.ayahsCount,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      ayahsCount: json['numberOfAyahs'],
    );
  }
}
