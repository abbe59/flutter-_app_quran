import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// نموذج للعلامة المرجعية
class Bookmark {
  final int surahNumber;
  final String surahName;
  final int ayahNumber;
  final String ayahText;
  final DateTime createdAt;
  final String? note;

  Bookmark({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.createdAt,
    this.note,
  });

  // تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'surahName': surahName,
      'ayahNumber': ayahNumber,
      'ayahText': ayahText,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  // تحويل من JSON
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      surahNumber: json['surahNumber'],
      surahName: json['surahName'],
      ayahNumber: json['ayahNumber'],
      ayahText: json['ayahText'],
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }

  // مفتاح فريد للعلامة
  String get uniqueKey => '${surahNumber}_$ayahNumber';
}

// مدير العلامات المرجعية
class BookmarkManager {
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _lastReadKey = 'last_read_position';

  // حفظ علامة مرجعية
  static Future<bool> saveBookmark(Bookmark bookmark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getAllBookmarks();
      
      // إزالة العلامة القديمة إذا كانت موجودة
      bookmarks.removeWhere((b) => b.uniqueKey == bookmark.uniqueKey);
      
      // إضافة العلامة الجديدة
      bookmarks.add(bookmark);
      
      // تحويل إلى JSON وحفظ
      final bookmarksJson = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_bookmarksKey, json.encode(bookmarksJson));
      
      return true;
    } catch (e) {
      print('خطأ في حفظ العلامة: $e');
      return false;
    }
  }

  // الحصول على جميع العلامات
  static Future<List<Bookmark>> getAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksString = prefs.getString(_bookmarksKey);
      
      if (bookmarksString == null) return [];
      
      final bookmarksJson = json.decode(bookmarksString) as List;
      return bookmarksJson.map((json) => Bookmark.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في تحميل العلامات: $e');
      return [];
    }
  }

  // حذف علامة مرجعية
  static Future<bool> deleteBookmark(String uniqueKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = await getAllBookmarks();
      
      bookmarks.removeWhere((b) => b.uniqueKey == uniqueKey);
      
      final bookmarksJson = bookmarks.map((b) => b.toJson()).toList();
      await prefs.setString(_bookmarksKey, json.encode(bookmarksJson));
      
      return true;
    } catch (e) {
      print('خطأ في حذف العلامة: $e');
      return false;
    }
  }

  // التحقق من وجود علامة
  static Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks.any((b) => 
      b.surahNumber == surahNumber && b.ayahNumber == ayahNumber);
  }

  // حفظ آخر موضع قراءة
  static Future<bool> saveLastReadPosition(int surahNumber, int ayahNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastRead = {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'timestamp': DateTime.now().toIso8601String(),
      };
      await prefs.setString(_lastReadKey, json.encode(lastRead));
      return true;
    } catch (e) {
      print('خطأ في حفظ آخر موضع: $e');
      return false;
    }
  }

  // الحصول على آخر موضع قراءة
  static Future<Map<String, dynamic>?> getLastReadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastReadString = prefs.getString(_lastReadKey);
      
      if (lastReadString == null) return null;
      
      return json.decode(lastReadString) as Map<String, dynamic>;
    } catch (e) {
      print('خطأ في تحميل آخر موضع: $e');
      return null;
    }
  }

  // مسح جميع العلامات
  static Future<bool> clearAllBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bookmarksKey);
      return true;
    } catch (e) {
      print('خطأ في مسح العلامات: $e');
      return false;
    }
  }

  // الحصول على العلامات مرتبة حسب التاريخ
  static Future<List<Bookmark>> getBookmarksSortedByDate() async {
    final bookmarks = await getAllBookmarks();
    bookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bookmarks;
  }

  // البحث في العلامات
  static Future<List<Bookmark>> searchBookmarks(String query) async {
    final bookmarks = await getAllBookmarks();
    return bookmarks.where((bookmark) =>
      bookmark.surahName.contains(query) ||
      bookmark.ayahText.contains(query) ||
      (bookmark.note?.contains(query) ?? false)
    ).toList();
  }
}
