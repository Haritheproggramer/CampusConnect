import '../utils/app_theme.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String senderId;
  final String senderName;
  final String priority;
  final DateTime date;
  // Strict single category: 'all' | 'department' | 'class'
  final AnnouncementCategory category;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.senderId,
    required this.senderName,
    this.priority = 'Normal',
    DateTime? date,
    this.category = AnnouncementCategory.all,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'sender_id': senderId,
        'sender_name': senderName,
        'priority': priority,
        'date': date.toIso8601String(),
        'category': category.code.toLowerCase(),
        // Keep legacy fields for backward compat
        'target_class': category == AnnouncementCategory.class_ ? 'all' : 'all',
        'target_department':
            category == AnnouncementCategory.department ? 'all' : 'all',
      };

  factory AnnouncementModel.fromMap(Map<String, dynamic> m) {
    // Derive category from legacy fields or new category field
    AnnouncementCategory cat;
    final rawCat = m['category'] as String?;
    if (rawCat != null && rawCat.isNotEmpty) {
      cat = AnnouncementCategory.fromString(rawCat);
    } else {
      // Legacy: if target_class is not 'all', it's CLASS
      final tc = (m['target_class'] ?? 'all').toString();
      final td = (m['target_department'] ?? 'all').toString();
      if (tc != 'all') {
        cat = AnnouncementCategory.class_;
      } else if (td != 'all') {
        cat = AnnouncementCategory.department;
      } else {
        cat = AnnouncementCategory.all;
      }
    }

    return AnnouncementModel(
      id: m['id'] ?? '',
      title: m['title'] ?? '',
      description: m['description'] ?? '',
      senderId: m['sender_id'] ?? m['senderId'] ?? '',
      senderName: m['sender_name'] ?? m['senderName'] ?? '',
      priority: m['priority'] ?? 'Normal',
      date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      category: cat,
    );
  }
}
