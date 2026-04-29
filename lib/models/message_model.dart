class MessageModel {
  final String id;
  final String title;
  final String body;
  final String category; // class, department, event, assignment, deadline, general
  final String senderId;
  final String senderName;
  final String senderRole;
  final String targetClass;
  final String targetDepartment;
  final String priority; // Normal, Important, Urgent
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.title,
    required this.body,
    this.category = 'general',
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    this.targetClass = 'all',
    this.targetDepartment = 'all',
    this.priority = 'Normal',
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'category': category,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'target_class': targetClass,
      'target_department': targetDepartment,
        'priority': priority,
        'timestamp': timestamp.toIso8601String(),
      };

  factory MessageModel.fromMap(Map<String, dynamic> m) => MessageModel(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        category: m['category'] ?? 'general',
      senderId: m['sender_id'] ?? m['senderId'] ?? '',
      senderName: m['sender_name'] ?? m['senderName'] ?? '',
      senderRole: m['sender_role'] ?? m['senderRole'] ?? 'teacher',
      targetClass: m['target_class'] ?? m['targetClass'] ?? 'all',
      targetDepartment: m['target_department'] ?? m['targetDepartment'] ?? 'all',
        priority: m['priority'] ?? 'Normal',
        timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
      );
}
