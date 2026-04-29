class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String assignedBy;
  final String priority;
  final bool completed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    DateTime? dueDate,
    required this.assignedBy,
    this.priority = 'Normal',
    this.completed = false,
  }) : dueDate = dueDate ?? DateTime.now().add(Duration(days: 7));

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
      'due_date': dueDate.toIso8601String(),
      'assigned_by': assignedBy,
        'priority': priority,
        'completed': completed,
      };

  factory TaskModel.fromMap(Map<String, dynamic> m) => TaskModel(
        id: m['id'] ?? '',
        title: m['title'] ?? '',
        description: m['description'] ?? '',
      dueDate: DateTime.tryParse(m['due_date'] ?? m['dueDate'] ?? '') ?? DateTime.now().add(Duration(days: 7)),
      assignedBy: m['assigned_by'] ?? m['assignedBy'] ?? '',
        priority: m['priority'] ?? 'Normal',
        completed: m['completed'] ?? false,
      );
}
