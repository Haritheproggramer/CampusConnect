import '../models/announcement_model.dart';
import '../models/message_model.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';

/// Local fallback data shown whenever Supabase is unavailable.
/// Keeps the demo usable without surfacing technical setup issues.
class MockData {
  static const String demoStudentId = 'cse4c-01';

  static AppUser get demoUser => AppUser(
        id: demoStudentId,
        name: 'Aarav Sharma',
        role: 'student',
        email: 'aarav.sharma@campusconnect.demo',
        department: 'Computer Science',
        className: 'CSE 4C',
        rollNo: 'CS4C01',
        section: 'C',
        isCR: true,
      );

  static List<Map<String, dynamic>> get students => [
        {'id': 'cse4c-01', 'name': 'Aarav Sharma', 'class_name': 'CSE 4C', 'roll_no': 'CS4C01', 'section': 'C', 'department': 'Computer Science', 'email': 'aarav.sharma@college.edu'},
        {'id': 'cse4c-02', 'name': 'Aanya Singh', 'class_name': 'CSE 4C', 'roll_no': 'CS4C02', 'section': 'C', 'department': 'Computer Science', 'email': 'aanya.singh@college.edu'},
        {'id': 'cse4c-03', 'name': 'Arjun Mehta', 'class_name': 'CSE 4C', 'roll_no': 'CS4C03', 'section': 'C', 'department': 'Computer Science', 'email': 'arjun.mehta@college.edu'},
        {'id': 'cse4c-04', 'name': 'Priya Verma', 'class_name': 'CSE 4C', 'roll_no': 'CS4C04', 'section': 'C', 'department': 'Computer Science', 'email': 'priya.verma@college.edu'},
        {'id': 'cse4c-05', 'name': 'Rohit Gupta', 'class_name': 'CSE 4C', 'roll_no': 'CS4C05', 'section': 'C', 'department': 'Computer Science', 'email': 'rohit.gupta@college.edu'},
        {'id': 'cse4c-06', 'name': 'Sneha Patel', 'class_name': 'CSE 4C', 'roll_no': 'CS4C06', 'section': 'C', 'department': 'Computer Science', 'email': 'sneha.patel@college.edu'},
        {'id': 'cse4c-07', 'name': 'Vikram Joshi', 'class_name': 'CSE 4C', 'roll_no': 'CS4C07', 'section': 'C', 'department': 'Computer Science', 'email': 'vikram.joshi@college.edu'},
        {'id': 'cse4c-08', 'name': 'Divya Nair', 'class_name': 'CSE 4C', 'roll_no': 'CS4C08', 'section': 'C', 'department': 'Computer Science', 'email': 'divya.nair@college.edu'},
        {'id': 'cse4c-09', 'name': 'Karan Malhotra', 'class_name': 'CSE 4C', 'roll_no': 'CS4C09', 'section': 'C', 'department': 'Computer Science', 'email': 'karan.malhotra@college.edu'},
        {'id': 'cse4c-10', 'name': 'Meera Iyer', 'class_name': 'CSE 4C', 'roll_no': 'CS4C10', 'section': 'C', 'department': 'Computer Science', 'email': 'meera.iyer@college.edu'},
        {'id': 'cse4c-11', 'name': 'Nikhil Reddy', 'class_name': 'CSE 4C', 'roll_no': 'CS4C11', 'section': 'C', 'department': 'Computer Science', 'email': 'nikhil.reddy@college.edu'},
        {'id': 'cse4c-12', 'name': 'Pooja Mishra', 'class_name': 'CSE 4C', 'roll_no': 'CS4C12', 'section': 'C', 'department': 'Computer Science', 'email': 'pooja.mishra@college.edu'},
        {'id': 'cse4c-13', 'name': 'Rahul Pandey', 'class_name': 'CSE 4C', 'roll_no': 'CS4C13', 'section': 'C', 'department': 'Computer Science', 'email': 'rahul.pandey@college.edu'},
        {'id': 'cse4c-14', 'name': 'Sanya Kapoor', 'class_name': 'CSE 4C', 'roll_no': 'CS4C14', 'section': 'C', 'department': 'Computer Science', 'email': 'sanya.kapoor@college.edu'},
        {'id': 'cse4c-15', 'name': 'Tanmay Bhatt', 'class_name': 'CSE 4C', 'roll_no': 'CS4C15', 'section': 'C', 'department': 'Computer Science', 'email': 'tanmay.bhatt@college.edu'},
        {'id': 'cse4c-16', 'name': 'Urvashi Chandra', 'class_name': 'CSE 4C', 'roll_no': 'CS4C16', 'section': 'C', 'department': 'Computer Science', 'email': 'urvashi.chandra@college.edu'},
        {'id': 'cse4c-17', 'name': 'Varun Saxena', 'class_name': 'CSE 4C', 'roll_no': 'CS4C17', 'section': 'C', 'department': 'Computer Science', 'email': 'varun.saxena@college.edu'},
        {'id': 'cse4c-18', 'name': 'Deepika Rao', 'class_name': 'CSE 4C', 'roll_no': 'CS4C18', 'section': 'C', 'department': 'Computer Science', 'email': 'deepika.rao@college.edu'},
        {'id': 'cse4c-19', 'name': 'Harsh Jha', 'class_name': 'CSE 4C', 'roll_no': 'CS4C19', 'section': 'C', 'department': 'Computer Science', 'email': 'harsh.jha@college.edu'},
        {'id': 'cse4c-20', 'name': 'Ishaan Trivedi', 'class_name': 'CSE 4C', 'roll_no': 'CS4C20', 'section': 'C', 'department': 'Computer Science', 'email': 'ishaan.trivedi@college.edu'},
        {'id': 'cse4c-21', 'name': 'Jyoti Bansal', 'class_name': 'CSE 4C', 'roll_no': 'CS4C21', 'section': 'C', 'department': 'Computer Science', 'email': 'jyoti.bansal@college.edu'},
        {'id': 'cse4c-22', 'name': 'Kartik Choudhary', 'class_name': 'CSE 4C', 'roll_no': 'CS4C22', 'section': 'C', 'department': 'Computer Science', 'email': 'kartik.choudhary@college.edu'},
      ];

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
          senderId: 'cse4c-02',
          senderName: 'Aanya Singh',
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
          receiverName: 'Aarav Sharma',
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
          receiverName: 'Aarav Sharma',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        MessageModel(
          id: 'dm-3',
          title: '',
          body: 'Class schedule change noted. I have updated the shared group sheet.',
          senderId: demoStudentId,
          senderName: 'Aarav Sharma',
          senderRole: 'student',
          receiverId: 'cse4c-02',
          receiverName: 'Aanya Singh',
          timestamp: DateTime.now().subtract(const Duration(hours: 9)),
        ),
        MessageModel(
          id: 'dm-4',
          title: '',
          body: 'Let us coordinate the group discussion after lunch and finalize the slide order.',
          senderId: demoStudentId,
          senderName: 'Aarav Sharma',
          senderRole: 'student',
          receiverId: 'cse4c-05',
          receiverName: 'Rohit Gupta',
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
