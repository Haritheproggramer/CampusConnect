class AnnouncementModel {
  final String id;
  final String title;
  final String description;
  final String senderId;
  final String senderName;
  final String priority;
  final DateTime date;
  final String targetClass;
  final String targetDepartment;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.senderId,
    required this.senderName,
    this.priority = 'Normal',
    DateTime? date,
    this.targetClass = 'all',
    this.targetDepartment = 'all',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
      'sender_id': senderId,
      'sender_name': senderName,
        'priority': priority,
        'date': date.toIso8601String(),
      'target_class': targetClass,
      'target_department': targetDepartment,
      };

  factory AnnouncementModel.fromMap(Map<String, dynamic> m) => AnnouncementModel(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        description: m['description'] ?? '',
      senderId: m['sender_id'] ?? m['senderId'] ?? '',
      senderName: m['sender_name'] ?? m['senderName'] ?? '',
        priority: m['priority'] ?? 'Normal',
        date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
      targetClass: m['target_class'] ?? m['targetClass'] ?? 'all',
      targetDepartment: m['target_department'] ?? m['targetDepartment'] ?? 'all',
      );
}
