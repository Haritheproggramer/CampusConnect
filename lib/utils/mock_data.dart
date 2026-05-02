import '../models/announcement_model.dart';
import '../models/message_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import 'section_rosters.dart';

/// Local fallback data shown whenever Supabase is unavailable.
/// Keeps the demo usable without surfacing technical setup issues.
class MockData {
  static const String demoStudentId = '2K24CSUN01152';

  static AppUser get demoUser => AppUser(
        id: demoStudentId,
        name: 'Avishi Gupta',
        role: 'student',
        email: 'avishi.gupta@campusconnect.demo',
        department: 'CSE',
        className: 'CSE 4C',
        rollNo: '2K24CSUN01152',
        section: 'C',
        group: 'G1',
        isCR: true,
      );

  static List<Map<String, dynamic>> get students => SectionRosterData.allStudents
      .map((student) => {
            ...student,
            'id': student['roll_no'],
          })
      .toList(growable: false);

  static List<Map<String, dynamic>> studentsForSection(String className) =>
      SectionRosterData.studentsForSection(className);

  static List<String> get availableSections => SectionRosterData.availableSections;

  static List<String> get availableGroups => SectionRosterData.availableGroups;

  static List<Map<String, dynamic>> get teachers => [
        {'id': 'teacher-monika', 'name': 'Dr. Monika Lamba', 'subject': 'Machine Learning', 'role': 'Mentor'},
        {'id': 'teacher-meenakshi', 'name': 'Dr. Meenakshi', 'subject': 'Digital Electronics'},
        {'id': 'teacher-bhawna', 'name': 'Bhawna Ma\'am', 'subject': 'Computer Networks'},
        {'id': 'teacher-ram', 'name': 'Ram Chatterjee', 'subject': 'Software Engineering'},
        {'id': 'teacher-pushpa', 'name': 'Pushpa Ma\'am', 'subject': 'Mobile App Development'},
        {'id': 'teacher-aniket', 'name': 'Aniket Sir', 'subject': 'AI & ML'},
        {'id': 'teacher-shelly', 'name': 'Dr. Shelly Agarwal', 'subject': 'Entrepreneurship'},
        {'id': 'teacher-geetika', 'name': 'Geetika Ma\'am', 'subject': 'PCE-II'},
        {'id': 'teacher-shushanta', 'name': 'Shushanta Bose', 'subject': 'PCE-II'},
        {'id': 'teacher-ganga', 'name': 'Ganga Sharma', 'subject': 'Design Thinking'},
        {'id': 'teacher-akanshi', 'name': 'Akanshi Ma\'am', 'subject': 'Indian Constitution'},
      ];

  static List<AnnouncementModel> get announcements => [
        AnnouncementModel(
          id: 'a-hackathon',
          title: 'Hackathon registration open',
          description: 'CSE 4C students can register for the hackathon team shortlist this week. Submit your idea by Friday.',
          senderId: 'system',
          senderName: 'Placement Cell',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(hours: 2)),
          category: AnnouncementCategory.all,
        ),
        AnnouncementModel(
          id: 'a-assignment',
          title: 'Assignment deadline reminder',
          description: 'Computer Networks assignment is due on Friday 5 PM. Bring the hard copy to class.',
          senderId: 'system',
          senderName: 'CSE Faculty',
          priority: 'Urgent',
          date: DateTime.now().subtract(const Duration(hours: 5)),
          category: AnnouncementCategory.class_,
        ),
        AnnouncementModel(
          id: 'a-postponed',
          title: 'Class test postponed',
          description: 'The Software Engineering unit test has been moved to next Monday. Use the extra time to revise.',
          senderId: 'system',
          senderName: 'CSE Faculty',
          priority: 'Urgent',
          date: DateTime.now().subtract(const Duration(hours: 10)),
          category: AnnouncementCategory.class_,
        ),
        AnnouncementModel(
          id: 'a-workshop',
          title: 'Workshop on AI tools',
          description: 'A hands-on workshop on AI tools and prompt design is scheduled for the CSE department on Wednesday.',
          senderId: 'system',
          senderName: 'Department Office',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(days: 1)),
          category: AnnouncementCategory.department,
        ),
        AnnouncementModel(
          id: 'a-mentor',
          title: 'Mentor meeting this week',
          description: 'All CSE 4C students should meet their mentor for progress review and project guidance on Thursday.',
          senderId: 'system',
          senderName: 'Dr. Monika Lamba',
          priority: 'Important',
          date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
          category: AnnouncementCategory.all,
        ),
      ];

  static List<MessageModel> get broadcasts => [
        MessageModel(
          id: 'm-b1',
          title: 'Assignment update',
          body: 'CN Assignment 3 should be submitted in class before 5 PM on Friday. Late submissions will not be accepted.',
          category: 'class',
          senderId: 'teacher-meenakshi',
          senderName: 'Dr. Meenakshi',
          senderRole: 'teacher',
          priority: 'Important',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        MessageModel(
          id: 'm-b2',
          title: 'Lab update',
          body: 'Digital Electronics lab will run in Lab-2 tomorrow. Bring your lab record and system notes.',
          category: 'all',
          senderId: 'teacher-meenakshi',
          senderName: 'Dr. Meenakshi',
          senderRole: 'teacher',
          priority: 'Normal',
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        MessageModel(
          id: 'm-b3',
          title: 'Class schedule change',
          body: 'SE lecture on Wednesday is shifted to 11:10 AM. The first hour will be a self-study block.',
          category: 'class',
          senderId: 'teacher-ram',
          senderName: 'Ram Chatterjee',
          senderRole: 'teacher',
          priority: 'Important',
          timestamp: DateTime.now().subtract(const Duration(hours: 10)),
        ),
        MessageModel(
          id: 'm-b4',
          title: 'Group discussion',
          body: 'Please post your final project topic in the CSE 4C group before the mentor meeting tomorrow.',
          category: 'class',
          senderId: demoStudentId,
          senderName: 'Avishi Gupta',
          senderRole: 'student',
          priority: 'Normal',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

  static List<MessageModel> get directMessages => [
        MessageModel(
          id: 'dm-1',
          title: '',
          body: 'Assignment 3 outline is ready. Review the TCP/IP sections before tomorrow.',
          senderId: 'teacher-monika',
          senderName: 'Dr. Monika Lamba',
          senderRole: 'teacher',
          receiverId: demoStudentId,
          receiverName: 'Avishi Gupta',
          timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        MessageModel(
          id: 'dm-2',
          title: '',
          body: 'The lab update is final. Bring your laptop and keep the toolchain installed.',
          senderId: 'teacher-pushpa',
          senderName: 'Pushpa Ma\'am',
          senderRole: 'teacher',
          receiverId: demoStudentId,
          receiverName: 'Avishi Gupta',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        MessageModel(
          id: 'dm-3',
          title: '',
          body: 'Class schedule change noted. I have updated the shared group sheet.',
          senderId: demoStudentId,
          senderName: 'Avishi Gupta',
          senderRole: 'student',
          receiverId: '2K24CSUN01157',
          receiverName: 'Hariom Jha',
          timestamp: DateTime.now().subtract(const Duration(hours: 9)),
        ),
        MessageModel(
          id: 'dm-4',
          title: '',
          body: 'Let us coordinate the group discussion after lunch and finalize the slide order.',
          senderId: demoStudentId,
          senderName: 'Avishi Gupta',
          senderRole: 'student',
          receiverId: '2K24CSUN01157',
          receiverName: 'Hariom Jha',
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        ),
      ];

  static List<TaskModel> get tasks {
    final now = DateTime.now();
    return [
      TaskModel(id: 't-1', title: 'CN Assignment 3', description: 'Submit the TCP/IP assignment with hard copy and portal upload.', dueDate: now.add(const Duration(days: 3)), assignedBy: 'Dr. Monika Lamba', priority: 'Urgent'),
      TaskModel(id: 't-2', title: 'Digital Electronics Lab Submission', description: 'Complete the lab sheet and upload the PDF with screenshots.', dueDate: now.add(const Duration(days: 4)), assignedBy: 'Dr. Meenakshi', priority: 'Important'),
      TaskModel(id: 't-3', title: 'Software Engineering test prep', description: 'Revise Agile, SDLC, and requirement analysis for the postponed class test.', dueDate: now.add(const Duration(days: 5)), assignedBy: 'Ram Chatterjee', priority: 'Important'),
      TaskModel(id: 't-4', title: 'Hackathon problem statement', description: 'Shortlist one idea and prepare the one-page proposal with your team.', dueDate: now.add(const Duration(days: 2)), assignedBy: 'Dr. Shelly Agarwal', priority: 'Urgent'),
      TaskModel(id: 't-5', title: 'AI & ML workshop notes', description: 'Capture takeaways from the workshop and add them to your project log.', dueDate: now.add(const Duration(days: 6)), assignedBy: 'Aniket Sir', priority: 'Normal'),
      TaskModel(id: 't-6', title: 'Mentor meeting checklist', description: 'Bring attendance, project progress, and blockers to the mentor meeting.', dueDate: now.add(const Duration(days: 1)), assignedBy: 'Dr. Monika Lamba', priority: 'Important'),
    ];
  }
}
