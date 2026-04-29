import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/announcement_model.dart';
import '../models/task_model.dart';

class FirebaseService {
  FirebaseService._private();
  static final FirebaseService instance = FirebaseService._private();

  static const String _supabaseUrl = 'https://ghivhjejmloektsbddbu.supabase.co';
  static const String _supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoaXZoamVqbWxvZWt0c2JkZGJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc0NzQ0OTcsImV4cCI6MjA5MzA1MDQ5N30.oSCbEkP8MF3Bmn5CcrpIRpuFoLMJv8uG_7jUFETgVvo';

  bool _initialized = false;

  // ── In-memory cache ──────────────────────────────────────────────────────
  AppUser? _cachedUser;

  SupabaseClient get db => Supabase.instance.client;
  User? get currentAuthUser => db.auth.currentUser;

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _initialized = true;
  }

  // ── Auth ─────────────────────────────────────────────────────────────────

  Future<AppUser?> getCurrentUserProfile({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedUser != null) return _cachedUser;
    final u = currentAuthUser;
    if (u == null) {
      _cachedUser = null;
      return null;
    }

    try {
      final row = await db.from('users').select().eq('id', u.id).maybeSingle();
      if (row == null) {
        _cachedUser = AppUser(
          id: u.id,
          name: (u.userMetadata?['name'] ?? '') as String,
          role: (u.userMetadata?['role'] ?? 'student') as String,
          email: u.email ?? '',
        );
      } else {
        _cachedUser = AppUser.fromMap(Map<String, dynamic>.from(row));
      }
    } catch (_) {
      _cachedUser = AppUser(
        id: u.id,
        name: (u.userMetadata?['name'] ?? '') as String,
        role: (u.userMetadata?['role'] ?? 'student') as String,
        email: u.email ?? '',
      );
    }
    return _cachedUser;
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final resp = await db.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );
      final uid = resp.user?.id;
      if (uid == null) throw Exception('Signup completed but user id is missing.');

      final user = AppUser(
        id: uid,
        name: name,
        role: role,
        email: email,
        department: extra?['department'] ?? '',
        className: extra?['className'] ?? '',
        rollNo: extra?['rollNo'] ?? '',
        section: extra?['section'] ?? '',
        subject: extra?['subject'] ?? '',
      );

      await db.from('users').upsert(user.toMap());
      if (role == 'student') {
        await db.from('students').upsert({
          'id': uid,
          'name': name,
          'class_name': user.className,
          'roll_no': user.rollNo,
          'section': user.section,
          'department': user.department,
          'email': email,
        });
      }
      _cachedUser = user;
      return user;
    } on AuthApiException catch (e) {
      final code = e.code ?? '';
      final isRateLimit =
          code == 'over_email_send_rate_limit' || e.statusCode == '429';
      final isAlreadyExists =
          code == 'user_already_exists' || code == 'email_exists';

      if (isRateLimit || isAlreadyExists) {
        try {
          await db.auth.signInWithPassword(email: email, password: password);
          final existingUser = await getCurrentUserProfile(forceRefresh: true);
          if (existingUser != null) return existingUser;
        } catch (_) {}
      }
      if (isRateLimit) {
        throw Exception(
          'Signup blocked by Supabase email rate limit. Try signing in or disable Email confirmation in Supabase Auth (dev mode).',
        );
      }
      rethrow;
    }
  }

  Future<AppUser?> signInWithEmail(
      {required String email, required String password}) async {
    await db.auth.signInWithPassword(email: email, password: password);
    return getCurrentUserProfile(forceRefresh: true);
  }

  Future<void> signOut() async {
    await db.auth.signOut();
    _cachedUser = null;
  }

  // ── Announcements ─────────────────────────────────────────────────────────

  /// Single stream — all announcements ordered by date desc
  Stream<List<Map<String, dynamic>>> streamAnnouncements() {
    return db
        .from('announcements')
        .stream(primaryKey: ['id'])
        .order('date', ascending: false);
  }

  Future<void> createAnnouncement(AnnouncementModel a) async {
    final id = const Uuid().v4();
    await db.from('announcements').insert(a.toMap()..['id'] = id);
  }

  // ── Broadcasts (class/dept/all messages) ──────────────────────────────────

  /// Broadcasts are messages without a receiver_id
  Stream<List<Map<String, dynamic>>> streamBroadcasts() {
    return db
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: false);
  }

  // ── Direct Messages ───────────────────────────────────────────────────────

  /// Stream of DMs between two users (either direction)
  Stream<List<Map<String, dynamic>>> streamDirectMessages(
      String userId, String otherId) {
    // We filter client-side since Supabase stream doesn't support OR filters
    return db
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('timestamp', ascending: true)
        .map((rows) => rows
            .where((r) {
              final sid = r['sender_id'] as String? ?? '';
              final rid = r['receiver_id'] as String? ?? '';
              return (sid == userId && rid == otherId) ||
                  (sid == otherId && rid == userId);
            })
            .toList());
  }

  Future<void> sendDirectMessage({
    required String senderId,
    required String senderName,
    required String senderRole,
    required String receiverId,
    required String receiverName,
    required String body,
  }) async {
    final id = const Uuid().v4();
    final m = MessageModel(
      id: id,
      title: '',
      body: body,
      category: 'direct',
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      receiverId: receiverId,
      receiverName: receiverName,
    );
    await db.from('messages').insert(m.toMap());
  }

  Future<void> createMessage(MessageModel m) async {
    final id = const Uuid().v4();
    await db.from('messages').insert(m.toMap()..['id'] = id);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> streamTasks() {
    return db
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('due_date', ascending: true);
  }

  Future<void> createTask(TaskModel t) async {
    final id = const Uuid().v4();
    await db.from('tasks').insert(t.toMap()..['id'] = id);
  }

  // ── Students ──────────────────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> searchStudents({String? query}) async {
    if (query == null || query.trim().isEmpty) {
      final rows = await db.from('students').select().limit(100);
      return List<Map<String, dynamic>>.from(rows);
    }
    final q = query.trim();
    final rows = await db
        .from('students')
        .select()
        .or('name.ilike.%$q%,class_name.ilike.%$q%,roll_no.ilike.%$q%')
        .limit(100);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<List<Map<String, dynamic>>> fetchStudentsForClass(
      String className) async {
    if (className.isEmpty) return searchStudents();
    final rows = await db
        .from('students')
        .select()
        .ilike('class_name', '%$className%')
        .limit(200);
    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> importStudents(List<Map<String, dynamic>> students) async {
    if (students.isEmpty) return;
    await db.from('students').upsert(students);
  }

  Future<void> toggleCR(
      {required String studentId, required bool isCR}) async {
    await db.from('users').update({'is_cr': isCR}).eq('id', studentId);
  }

  // ── Files ─────────────────────────────────────────────────────────────────

  Future<String> uploadFile(String filePath, Uint8List bytes) async {
    final id = const Uuid().v4();
    final storagePath = 'notes/$id';
    await db.storage.from('campus-files').uploadBinary(storagePath, bytes,
        fileOptions: const FileOptions(upsert: true));
    return db.storage.from('campus-files').getPublicUrl(storagePath);
  }

  Future<void> saveFileRecord({
    required String name,
    required String url,
    required String uploadedBy,
    String fileType = 'link',
  }) async {
    final id = const Uuid().v4();
    await db.from('files').insert({
      'id': id,
      'name': name,
      'url': url,
      'uploaded_by': uploadedBy,
      'uploaded_at': DateTime.now().toIso8601String(),
      'file_type': fileType,
    });
  }

  Future<List<Map<String, dynamic>>> fetchFiles({int limit = 20}) async {
    final rows =
        await db.from('files').select().limit(limit).order('uploaded_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  // ── Read tracking ─────────────────────────────────────────────────────────

  Future<void> markAnnouncementRead(
      {required String announcementId, required String studentId}) async {
    await db.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'student_id': studentId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Seed ──────────────────────────────────────────────────────────────────

  Future<void> seedDemoData() async {
    // ── 20+ Realistic CSE 4C Students ────────────────────────────────────────
    final students = [
      {'id': const Uuid().v4(), 'name': 'Aarav Sharma',      'class_name': 'CSE 4C', 'roll_no': 'CS4C01', 'section': 'C', 'department': 'Computer Science', 'email': 'aarav.sharma@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Aanya Singh',       'class_name': 'CSE 4C', 'roll_no': 'CS4C02', 'section': 'C', 'department': 'Computer Science', 'email': 'aanya.singh@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Arjun Mehta',       'class_name': 'CSE 4C', 'roll_no': 'CS4C03', 'section': 'C', 'department': 'Computer Science', 'email': 'arjun.mehta@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Priya Verma',       'class_name': 'CSE 4C', 'roll_no': 'CS4C04', 'section': 'C', 'department': 'Computer Science', 'email': 'priya.verma@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Rohit Gupta',       'class_name': 'CSE 4C', 'roll_no': 'CS4C05', 'section': 'C', 'department': 'Computer Science', 'email': 'rohit.gupta@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Sneha Patel',       'class_name': 'CSE 4C', 'roll_no': 'CS4C06', 'section': 'C', 'department': 'Computer Science', 'email': 'sneha.patel@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Vikram Joshi',      'class_name': 'CSE 4C', 'roll_no': 'CS4C07', 'section': 'C', 'department': 'Computer Science', 'email': 'vikram.joshi@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Divya Nair',        'class_name': 'CSE 4C', 'roll_no': 'CS4C08', 'section': 'C', 'department': 'Computer Science', 'email': 'divya.nair@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Karan Malhotra',    'class_name': 'CSE 4C', 'roll_no': 'CS4C09', 'section': 'C', 'department': 'Computer Science', 'email': 'karan.malhotra@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Meera Iyer',        'class_name': 'CSE 4C', 'roll_no': 'CS4C10', 'section': 'C', 'department': 'Computer Science', 'email': 'meera.iyer@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Nikhil Reddy',      'class_name': 'CSE 4C', 'roll_no': 'CS4C11', 'section': 'C', 'department': 'Computer Science', 'email': 'nikhil.reddy@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Pooja Mishra',      'class_name': 'CSE 4C', 'roll_no': 'CS4C12', 'section': 'C', 'department': 'Computer Science', 'email': 'pooja.mishra@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Rahul Pandey',      'class_name': 'CSE 4C', 'roll_no': 'CS4C13', 'section': 'C', 'department': 'Computer Science', 'email': 'rahul.pandey@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Sanya Kapoor',      'class_name': 'CSE 4C', 'roll_no': 'CS4C14', 'section': 'C', 'department': 'Computer Science', 'email': 'sanya.kapoor@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Tanmay Bhatt',      'class_name': 'CSE 4C', 'roll_no': 'CS4C15', 'section': 'C', 'department': 'Computer Science', 'email': 'tanmay.bhatt@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Urvashi Chandra',   'class_name': 'CSE 4C', 'roll_no': 'CS4C16', 'section': 'C', 'department': 'Computer Science', 'email': 'urvashi.c@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Varun Saxena',      'class_name': 'CSE 4C', 'roll_no': 'CS4C17', 'section': 'C', 'department': 'Computer Science', 'email': 'varun.saxena@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Deepika Rao',       'class_name': 'CSE 4C', 'roll_no': 'CS4C18', 'section': 'C', 'department': 'Computer Science', 'email': 'deepika.rao@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Harayam Jha',       'class_name': 'CSE 4C', 'roll_no': 'CS4C19', 'section': 'C', 'department': 'Computer Science', 'email': 'harayam@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Ishaan Trivedi',    'class_name': 'CSE 4C', 'roll_no': 'CS4C20', 'section': 'C', 'department': 'Computer Science', 'email': 'ishaan.t@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Jyoti Bansal',      'class_name': 'CSE 4C', 'roll_no': 'CS4C21', 'section': 'C', 'department': 'Computer Science', 'email': 'jyoti.b@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Kartik Choudhary',  'class_name': 'CSE 4C', 'roll_no': 'CS4C22', 'section': 'C', 'department': 'Computer Science', 'email': 'kartik.c@college.edu'},
      // ECE students for variety
      {'id': const Uuid().v4(), 'name': 'Lavanya Menon',     'class_name': 'ECE 4A', 'roll_no': 'EC4A01', 'section': 'A', 'department': 'Electronics', 'email': 'lavanya.m@college.edu'},
      {'id': const Uuid().v4(), 'name': 'Manish Tripathi',   'class_name': 'ECE 4A', 'roll_no': 'EC4A02', 'section': 'A', 'department': 'Electronics', 'email': 'manish.t@college.edu'},
    ];
    await db.from('students').upsert(students);

    // ── Announcements: ALL category ───────────────────────────────────────────
    await db.from('announcements').upsert([
      {
        'id': const Uuid().v4(),
        'title': '🏆 Hackathon Registration Open — Smart India Hackathon 2024',
        'description': 'SIH registrations are now open! Form teams of 6 and register before the deadline. Problem statements will be released on the portal. This is a great opportunity for all CSE students.',
        'sender_id': 'system', 'sender_name': 'Prof. Kumar (Faculty Coordinator)',
        'priority': 'Important', 'category': 'all',
        'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'target_class': 'all', 'target_department': 'all',
      },
      {
        'id': const Uuid().v4(),
        'title': '📅 Mentor Meeting — Industry Interaction Session',
        'description': 'Industry mentors from TCS, Infosys, and Wipro will visit campus on Friday. All 4th year students MUST attend. Venue: Seminar Hall, 2 PM sharp.',
        'sender_id': 'system', 'sender_name': 'Placement Cell',
        'priority': 'Urgent', 'category': 'all',
        'date': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'target_class': 'all', 'target_department': 'all',
      },
      {
        'id': const Uuid().v4(),
        'title': '📝 Mid-Semester Examination Schedule Released',
        'description': 'Mid-semester exam timetable has been published on the academic portal. Exams start from next week. Check your individual schedule and download admit card.',
        'sender_id': 'system', 'sender_name': 'Exam Controller',
        'priority': 'Important', 'category': 'all',
        'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        'target_class': 'all', 'target_department': 'all',
      },
    ]);

    // ── Announcements: DEPARTMENT category ────────────────────────────────────
    await db.from('announcements').upsert([
      {
        'id': const Uuid().v4(),
        'title': '🤖 Workshop: Advanced ML with PyTorch — CSE Dept',
        'description': 'Two-day hands-on workshop on deep learning with PyTorch. Open to all CSE students. Register by tomorrow 5 PM. Limited seats — 30 only. Lab-2 will be used.',
        'sender_id': 'system', 'sender_name': 'Dr. Priya R. (ML Faculty)',
        'priority': 'Important', 'category': 'department',
        'date': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'target_class': 'all', 'target_department': 'Computer Science',
      },
      {
        'id': const Uuid().v4(),
        'title': '💼 Campus Recruitment: Google Pre-Placement Talk',
        'description': 'Google India team will conduct a pre-placement talk exclusively for CSE students. Attendance is compulsory for all eligible students (CGPA ≥ 7.5). Venue: LT-1, 11 AM Thursday.',
        'sender_id': 'system', 'sender_name': 'CSE Department (HOD)',
        'priority': 'Urgent', 'category': 'department',
        'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'target_class': 'all', 'target_department': 'Computer Science',
      },
    ]);

    // ── Announcements: CLASS category ─────────────────────────────────────────
    await db.from('announcements').upsert([
      {
        'id': const Uuid().v4(),
        'title': '⏰ Class Test POSTPONED — Software Engineering (Unit 3)',
        'description': 'The SE class test scheduled for tomorrow has been postponed to next Monday. Prof. Mehta has confirmed the change. Use this time to revise SDLC models and Agile methodology.',
        'sender_id': 'system', 'sender_name': 'Aanya Singh (CR — CSE 4C)',
        'priority': 'Urgent', 'category': 'class',
        'date': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
        'target_class': 'CSE 4C', 'target_department': 'Computer Science',
      },
      {
        'id': const Uuid().v4(),
        'title': '📋 Assignment 3 Submission — CN (Computer Networks)',
        'description': 'CN Assignment 3 (TCP/IP Protocols, Routing Algorithms) must be submitted by Friday 5 PM to Dr. Sharma. Submit via ERP portal AND bring a printout. No late submissions accepted.',
        'sender_id': 'system', 'sender_name': 'Aanya Singh (CR — CSE 4C)',
        'priority': 'Important', 'category': 'class',
        'date': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
        'target_class': 'CSE 4C', 'target_department': 'Computer Science',
      },
      {
        'id': const Uuid().v4(),
        'title': '🔬 Mobile App Lab — Bring Laptops Tomorrow',
        'description': 'Prof. Kumar has confirmed that tomorrow\'s Mobile App Lab (1:45 PM) will require everyone to bring their own laptop with Android Studio installed. Lab systems are under maintenance.',
        'sender_id': 'system', 'sender_name': 'Aanya Singh (CR — CSE 4C)',
        'priority': 'Normal', 'category': 'class',
        'date': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        'target_class': 'CSE 4C', 'target_department': 'Computer Science',
      },
    ]);

    // ── Messages / Broadcasts ─────────────────────────────────────────────────
    await db.from('messages').upsert([
      {
        'id': const Uuid().v4(),
        'title': 'Assignment Submission Reminder',
        'body': 'Reminder: CN Assignment 3 deadline is this Friday at 5 PM. Submit via portal AND bring hardcopy.',
        'category': 'class', 'sender_id': 'system',
        'sender_name': 'CR Aanya Singh', 'sender_role': 'student',
        'priority': 'Important',
        'timestamp': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      },
      {
        'id': const Uuid().v4(),
        'title': 'Lab Maintenance Update',
        'body': 'Lab-1 will be under maintenance tomorrow (Wednesday). CN Lab is shifted to Lab-4. Please note the change.',
        'category': 'all', 'sender_id': 'system',
        'sender_name': 'Dr. Sharma', 'sender_role': 'teacher',
        'priority': 'Normal',
        'timestamp': DateTime.now().subtract(const Duration(hours: 10)).toIso8601String(),
      },
      {
        'id': const Uuid().v4(),
        'title': 'Group Discussion: Final Year Project Topics',
        'body': 'All CSE 4C students: please fill the Google Form shared in WhatsApp group with your preferred FYP topic by end of day.',
        'category': 'class', 'sender_id': 'system',
        'sender_name': 'CR Aanya Singh', 'sender_role': 'student',
        'priority': 'Normal',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ]);

    // ── Tasks ─────────────────────────────────────────────────────────────────
    final now = DateTime.now();
    await db.from('tasks').upsert([
      {
        'id': const Uuid().v4(),
        'title': 'CN Assignment 3 — Submit via Portal',
        'description': 'TCP/IP Protocols, Routing Algorithms, Subnetting. Soft copy on portal + hardcopy to Dr. Sharma.',
        'due_date': DateTime(now.year, now.month, now.day + 3, 17, 0).toIso8601String(),
        'assigned_by': 'Dr. Sharma', 'priority': 'Urgent',
      },
      {
        'id': const Uuid().v4(),
        'title': 'SE Unit 3 — Study Agile & SDLC for Postponed Test',
        'description': 'Test rescheduled to Monday. Topics: Agile, Scrum, Waterfall, Spiral models. Review last year question papers.',
        'due_date': DateTime(now.year, now.month, now.day + 5, 9, 0).toIso8601String(),
        'assigned_by': 'Prof. Mehta', 'priority': 'Important',
      },
      {
        'id': const Uuid().v4(),
        'title': 'ML Lab Report — K-Means Clustering',
        'description': 'Write lab report for Experiment 6 (K-Means Clustering on Iris dataset). Include output screenshots and analysis.',
        'due_date': DateTime(now.year, now.month, now.day + 7, 17, 0).toIso8601String(),
        'assigned_by': 'Dr. Priya R.', 'priority': 'Normal',
      },
      {
        'id': const Uuid().v4(),
        'title': 'Register for SIH 2024 Hackathon',
        'description': 'Form team of 6, pick problem statement, register on sih.gov.in before the deadline. Share team details with faculty coordinator.',
        'due_date': DateTime(now.year, now.month, now.day + 2, 23, 59).toIso8601String(),
        'assigned_by': 'Prof. Kumar', 'priority': 'Urgent',
      },
      {
        'id': const Uuid().v4(),
        'title': 'Digital Electronics — Chapter 5 Problems',
        'description': 'Solve exercise problems from Chapter 5 (Sequential Circuits, Flip-Flops). Required for next lab session.',
        'due_date': DateTime(now.year, now.month, now.day + 6, 9, 0).toIso8601String(),
        'assigned_by': 'Prof. Singh', 'priority': 'Normal',
      },
      {
        'id': const Uuid().v4(),
        'title': 'Mid-Semester Exam Preparation',
        'description': 'All 5 subjects: CN, ML, SE, DE, AI. Download admit card from ERP portal. Exams start next Monday.',
        'due_date': DateTime(now.year, now.month, now.day + 8, 8, 0).toIso8601String(),
        'assigned_by': 'Exam Controller', 'priority': 'Urgent',
      },
    ]);
  }
}

