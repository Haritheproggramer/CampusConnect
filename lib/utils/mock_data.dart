import '../models/announcement_model.dart';
import '../models/task_model.dart';
import '../utils/app_theme.dart';


/// Local fallback data — shown when Supabase is unavailable.
/// App always looks fully functional.
class MockData {
  // ── Real Student Roster ───────────────────────────────────────────────────
  static List<Map<String, dynamic>> get students => [
        // G1
        {'id': 'm-s01', 'name': 'Aakash Kothari',             'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01143', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s02', 'name': 'Abhishek Bora',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01144', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s03', 'name': 'Abhishek Sharma',            'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01145', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s04', 'name': 'Aditya Choudhary',           'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01146', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s05', 'name': 'Akash Yadav',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01148', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s06', 'name': 'Avishi Gupta',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01152', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s07', 'name': 'Ayaan Anwar',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01153', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s08', 'name': 'Bhoomi Sharma',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01154', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s09', 'name': 'Gaderu Krishna Nanda',       'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01156', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s10', 'name': 'Hariom Jha',                 'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01157', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s11', 'name': 'Harshit Raj',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01160', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s12', 'name': 'Harshit Singhal',            'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01161', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s13', 'name': 'Hunny Kaushik',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01163', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s14', 'name': 'Ishita Babbar',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01165', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s15', 'name': 'Japleen Kaur',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01167', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s16', 'name': 'Jasmine Kaur',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01168', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s17', 'name': 'Jatin Chhabra',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01169', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s18', 'name': 'Jatin Singhal',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01170', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s19', 'name': 'Kavy Khanna',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01172', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s20', 'name': 'Khushi Vats',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01174', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s21', 'name': 'Kirti Singhal',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01175', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s22', 'name': 'Krishna Khanna',             'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01177', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s23', 'name': 'Kunal Sharma',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01178', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s24', 'name': 'Naman Tyagi',                'class_name': 'CSE 1st Year', 'roll_no': '2K25CSUL01008', 'section': 'G1', 'department': 'Computer Science'},
        {'id': 'm-s25', 'name': 'Aakash',                     'class_name': 'CSE 1st Year', 'roll_no': '2K25CSUL01010', 'section': 'G1', 'department': 'Computer Science'},
        // G2
        {'id': 'm-s26', 'name': 'Nampelly Akshay',            'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01180', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s27', 'name': 'Narla Vamshi',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01181', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s28', 'name': 'Naveen Jindal',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01182', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s29', 'name': 'Nirbhay',                    'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01183', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s30', 'name': 'Pendli Jashvanth Manikanta', 'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01185', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s31', 'name': 'Piyush Juneja',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01186', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s32', 'name': 'Piyush Kumar Sharma',        'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01187', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s33', 'name': 'Prabhleen Kaur',             'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01188', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s34', 'name': 'Prince Sharma',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01191', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s35', 'name': 'Pujari Shiva Kumar',         'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01192', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s36', 'name': 'Raja Babu Rai',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01194', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s37', 'name': 'Rohan',                      'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01195', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s38', 'name': 'Rohan Sharma',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01196', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s39', 'name': 'Sagar Kumar',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01198', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s40', 'name': 'Sarthak Mittal',             'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01199', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s41', 'name': 'Shambhavi',                  'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01200', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s42', 'name': 'Shenigaram Manish',          'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01201', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s43', 'name': 'Shinu Sura',                 'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01202', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s44', 'name': 'Sonakshi Chand',             'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01203', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s45', 'name': 'Tanisha',                    'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01204', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s46', 'name': 'Tanya Rathore',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01205', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s47', 'name': 'Vansh Pratap',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01206', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s48', 'name': 'Vatsal Goel',                'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01207', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s49', 'name': 'Venkata Ramana Reddy',       'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01208', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s50', 'name': 'Vidit Chauhan',              'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01209', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s51', 'name': 'Yanis Hasan Khan',           'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01211', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s52', 'name': 'Yashveer Tanwar',            'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01212', 'section': 'G2', 'department': 'Computer Science'},
        {'id': 'm-s53', 'name': 'Yuvraj Nagar',               'class_name': 'CSE 1st Year', 'roll_no': '2K24CSUN01213', 'section': 'G2', 'department': 'Computer Science'},
      ];

  // ── Announcements ─────────────────────────────────────────────────────────
  static List<AnnouncementModel> get announcements => [
        AnnouncementModel(
          id: 'm-a1',
          title: '🏆 Hackathon Registration Open — Smart India Hackathon 2024',
          description: 'SIH registrations are now open! Form teams of 6 and register before the deadline. Problem statements will be released on the portal. Great opportunity for all CSE students.',
          senderId: 'system',
          senderName: 'Prof. Kumar (Faculty Coordinator)',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          category: AnnouncementCategory.all,
        ),
        AnnouncementModel(
          id: 'm-a2',
          title: '📅 Mentor Meeting — Industry Interaction Session',
          description: 'Industry mentors from TCS, Infosys, and Wipro will visit campus on Friday. All students MUST attend. Venue: Seminar Hall, 2 PM sharp.',
          senderId: 'system',
          senderName: 'Placement Cell',
          priority: 'Urgent',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          category: AnnouncementCategory.all,
        ),
        AnnouncementModel(
          id: 'm-a3',
          title: '📝 Mid-Semester Examination Schedule Released',
          description: 'Mid-semester exam timetable has been published on the academic portal. Exams start from next week. Check your individual schedule and download admit card.',
          senderId: 'system',
          senderName: 'Exam Controller',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: AnnouncementCategory.all,
        ),
        AnnouncementModel(
          id: 'm-a4',
          title: '🤖 Workshop: Advanced ML with PyTorch — CSE Dept',
          description: 'Two-day hands-on workshop on deep learning with PyTorch. Open to all CSE students. Register by tomorrow 5 PM. Limited seats — 30 only.',
          senderId: 'system',
          senderName: 'Dr. Priya R. (ML Faculty)',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(hours: 8)),
          category: AnnouncementCategory.department,
        ),
        AnnouncementModel(
          id: 'm-a5',
          title: '💼 Campus Recruitment: Google Pre-Placement Talk',
          description: 'Google India team will conduct a pre-placement talk for CSE students. Attendance is compulsory for eligible students (CGPA ≥ 7.5). Venue: LT-1, 11 AM Thursday.',
          senderId: 'system',
          senderName: 'CSE Department (HOD)',
          priority: 'Urgent',
          date: DateTime.now().subtract(const Duration(days: 2)),
          category: AnnouncementCategory.department,
        ),
        AnnouncementModel(
          id: 'm-a6',
          title: '⏰ Class Test POSTPONED — Software Engineering (Unit 3)',
          description: 'The SE class test scheduled for tomorrow has been postponed to next Monday. Use this time to revise SDLC models and Agile methodology.',
          senderId: 'system',
          senderName: 'Hariom Jha (CR — CSE 1st Year)',
          priority: 'Urgent',
          date: DateTime.now().subtract(const Duration(hours: 1)),
          category: AnnouncementCategory.class_,
        ),
        AnnouncementModel(
          id: 'm-a7',
          title: '📋 Assignment 3 Submission — Computer Networks',
          description: 'CN Assignment 3 (TCP/IP Protocols, Routing Algorithms) must be submitted by Friday 5 PM. Submit via ERP portal AND bring a printout. No late submissions.',
          senderId: 'system',
          senderName: 'Hariom Jha (CR — CSE 1st Year)',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(hours: 3)),
          category: AnnouncementCategory.class_,
        ),
        AnnouncementModel(
          id: 'm-a8',
          title: '🔬 Lab Session — Bring Laptops Tomorrow',
          description: 'Tomorrow\'s lab session requires everyone to bring their own laptop with required software installed. Lab systems are under maintenance.',
          senderId: 'system',
          senderName: 'Hariom Jha (CR — CSE 1st Year)',
          priority: 'Normal',
          date: DateTime.now().subtract(const Duration(hours: 6)),
          category: AnnouncementCategory.class_,
        ),
      ];

  // ── Tasks ─────────────────────────────────────────────────────────────────
  static List<TaskModel> get tasks {
    final now = DateTime.now();
    return [
      TaskModel(id: 'm-t1', title: 'CN Assignment 3 — Submit via ERP Portal',    description: 'TCP/IP Protocols, Routing Algorithms, Subnetting. Soft copy on portal + hardcopy.', dueDate: now.add(const Duration(days: 3)), assignedBy: 'Dr. Sharma',     priority: 'Urgent'),
      TaskModel(id: 'm-t2', title: 'SE Unit 3 — Agile & SDLC Revision',          description: 'Test rescheduled to Monday. Topics: Agile, Scrum, Waterfall, Spiral models.',          dueDate: now.add(const Duration(days: 5)), assignedBy: 'Prof. Mehta',     priority: 'Important'),
      TaskModel(id: 'm-t3', title: 'ML Lab Report — K-Means Clustering',          description: 'Write lab report for Experiment 6 (K-Means on Iris dataset). Include screenshots.',   dueDate: now.add(const Duration(days: 7)), assignedBy: 'Dr. Priya R.',    priority: 'Normal'),
      TaskModel(id: 'm-t4', title: 'Register for SIH 2024 Hackathon',             description: 'Form team of 6, pick problem statement, register on sih.gov.in before deadline.',      dueDate: now.add(const Duration(days: 2)), assignedBy: 'Prof. Kumar',     priority: 'Urgent'),
      TaskModel(id: 'm-t5', title: 'Digital Electronics — Chapter 5 Problems',    description: 'Solve exercise problems from Chapter 5 (Sequential Circuits, Flip-Flops).',            dueDate: now.add(const Duration(days: 6)), assignedBy: 'Prof. Singh',     priority: 'Normal'),
      TaskModel(id: 'm-t6', title: 'Mid-Semester Exam Preparation',               description: 'All subjects. Download admit card from ERP portal. Exams start next Monday.',           dueDate: now.add(const Duration(days: 8)), assignedBy: 'Exam Controller', priority: 'Urgent'),
    ];
  }
}
