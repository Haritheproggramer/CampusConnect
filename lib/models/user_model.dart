class AppUser {
  final String id;
  final String name;
  final String role; // student | teacher | admin
  final String email;
  final String department;
  final String className;
  final String rollNo;
  final String section;
  final String subject;

  AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.department = '',
    this.className = '',
    this.rollNo = '',
    this.section = '',
    this.subject = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'role': role,
        'email': email,
        'department': department,
      'class_name': className,
      'roll_no': rollNo,
      'section': section,
      'subject': subject,
      };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        role: m['role'] ?? 'student',
        email: m['email'] ?? '',
        department: m['department'] ?? '',
      className: m['class_name'] ?? m['className'] ?? '',
      rollNo: m['roll_no'] ?? m['rollNo'] ?? '',
      section: m['section'] ?? '',
      subject: m['subject'] ?? '',
      );
}
