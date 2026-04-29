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
    final students = [
      {
        'id': const Uuid().v4(),
        'name': 'Alice Johnson',
        'class_name': 'CSE 2nd Year',
        'roll_no': 'CS101',
        'section': 'A',
        'department': 'Computer Science',
        'email': 'alice@example.com',
      },
      {
        'id': const Uuid().v4(),
        'name': 'Bob Kumar',
        'class_name': 'CSE 2nd Year',
        'roll_no': 'CS102',
        'section': 'A',
        'department': 'Computer Science',
        'email': 'bob@example.com',
      },
      {
        'id': const Uuid().v4(),
        'name': 'Harayam Jha',
        'class_name': 'CSE 2nd Year',
        'roll_no': '45',
        'section': 'A',
        'department': 'Computer Science',
        'email': 'harayam@example.com',
      },
    ];
    await db.from('students').upsert(students);

    await db.from('announcements').insert({
      'id': const Uuid().v4(),
      'title': 'Welcome to Campus Connect',
      'description': 'Your smart college communication platform is ready.',
      'sender_id': 'system',
      'sender_name': 'Admin',
      'priority': 'Normal',
      'category': 'all',
      'date': DateTime.now().toIso8601String(),
      'target_class': 'all',
      'target_department': 'all',
    });

    await db.from('announcements').insert({
      'id': const Uuid().v4(),
      'title': 'Data Science Seminar — Register Now',
      'description': 'Open to all CSE students. Venue: LT-3, Friday 3PM.',
      'sender_id': 'system',
      'sender_name': 'HOD CSE',
      'priority': 'Important',
      'category': 'department',
      'date': DateTime.now().toIso8601String(),
      'target_class': 'all',
      'target_department': 'Computer Science',
    });

    await db.from('announcements').insert({
      'id': const Uuid().v4(),
      'title': 'Class Schedule Change — Tomorrow',
      'description': 'Period 3 (OS Lab) moved to Period 5. Check timetable.',
      'sender_id': 'system',
      'sender_name': 'CR Alice Johnson',
      'priority': 'Urgent',
      'category': 'class',
      'date': DateTime.now().toIso8601String(),
      'target_class': 'CSE 2nd Year',
      'target_department': 'all',
    });
  }
}
