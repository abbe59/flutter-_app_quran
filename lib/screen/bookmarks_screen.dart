import 'package:flutter/material.dart';
import 'package:quren_app_first/services/bookmark_manager.dart';
import 'package:quren_app_first/widget/gradient_scaffold.dart';
import 'package:quren_app_first/screen/surah_ayat_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Bookmark> bookmarks = [];
  List<Bookmark> filteredBookmarks = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    setState(() => isLoading = true);
    final loadedBookmarks = await BookmarkManager.getBookmarksSortedByDate();
    setState(() {
      bookmarks = loadedBookmarks;
      filteredBookmarks = loadedBookmarks;
      isLoading = false;
    });
  }

  void filterBookmarks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBookmarks = bookmarks;
      } else {
        filteredBookmarks = bookmarks.where((bookmark) =>
          bookmark.surahName.contains(query) ||
          bookmark.ayahText.contains(query) ||
          (bookmark.note?.contains(query) ?? false)
        ).toList();
      }
    });
  }

  Future<void> deleteBookmark(Bookmark bookmark) async {
    final success = await BookmarkManager.deleteBookmark(bookmark.uniqueKey);
    if (success) {
      setState(() {
        bookmarks.removeWhere((b) => b.uniqueKey == bookmark.uniqueKey);
        filteredBookmarks.removeWhere((b) => b.uniqueKey == bookmark.uniqueKey);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف العلامة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void navigateToAyah(Bookmark bookmark) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahAyatScreen(
          surahNumber: bookmark.surahNumber,
          surahName: bookmark.surahName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientScaffold(
      title: 'العلامات المرجعية',
      child: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: filterBookmarks,
              decoration: InputDecoration(
                hintText: 'البحث في العلامات...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
            ),
          ),

          // آخر موضع قراءة
          FutureBuilder<Map<String, dynamic>?>(
            future: BookmarkManager.getLastReadPosition(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final lastRead = snapshot.data!;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'آخر موضع قراءة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'السورة ${lastRead['surahNumber']} - الآية ${lastRead['ayahNumber']}',
                              style: TextStyle(color: Colors.blue.shade600),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // الانتقال لآخر موضع قراءة
                          // يمكن تنفيذ هذا لاحقاً
                        },
                        icon: Icon(Icons.arrow_forward, color: Colors.blue.shade700),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // قائمة العلامات
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredBookmarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_border,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'لا توجد علامات مرجعية'
                                  : 'لا توجد نتائج للبحث',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            if (searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'اضغط على أيقونة العلامة في أي آية لحفظها',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredBookmarks.length,
                        itemBuilder: (context, index) {
                          final bookmark = filteredBookmarks[index];
                          return BookmarkCard(
                            bookmark: bookmark,
                            onTap: () => navigateToAyah(bookmark),
                            onDelete: () => deleteBookmark(bookmark),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس البطاقة
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bookmark.surahName} - آية ${bookmark.ayahNumber}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    iconSize: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // نص الآية
              Text(
                bookmark.ayahText,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Amiri',
                  height: 1.6,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (bookmark.note != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bookmark.note!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // تاريخ الإنشاء
              Text(
                'تم الحفظ: ${_formatDate(bookmark.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
