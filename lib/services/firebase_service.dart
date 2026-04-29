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

  SupabaseClient get db => Supabase.instance.client;
  User? get currentAuthUser => db.auth.currentUser;

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
    _initialized = true;
  }

  Future<AppUser?> getCurrentUserProfile() async {
    final u = currentAuthUser;
    if (u == null) return null;

    try {
      final row = await db.from('users').select().eq('id', u.id).maybeSingle();
      if (row == null) {
        return AppUser(
          id: u.id,
          name: (u.userMetadata?['name'] ?? '') as String,
          role: (u.userMetadata?['role'] ?? 'student') as String,
          email: u.email ?? '',
        );
      }
      return AppUser.fromMap(Map<String, dynamic>.from(row));
    } catch (_) {
      // Fallback avoids app-lock if schema/policies are not yet applied.
      return AppUser(
        id: u.id,
        name: (u.userMetadata?['name'] ?? '') as String,
        role: (u.userMetadata?['role'] ?? 'student') as String,
        email: u.email ?? '',
      );
    }
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
      if (uid == null) {
        throw Exception('Signup completed but user id is missing.');
      }

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
      return user;
    } on AuthApiException catch (e) {
      final code = e.code ?? '';
      final isRateLimit = code == 'over_email_send_rate_limit' || e.statusCode == '429';
      final isAlreadyExists = code == 'user_already_exists' || code == 'email_exists';

      if (isRateLimit || isAlreadyExists) {
        try {
          await db.auth.signInWithPassword(email: email, password: password);
          final existingUser = await getCurrentUserProfile();
          if (existingUser != null) return existingUser;
        } catch (_) {
          // If fallback sign-in fails, show actionable guidance below.
        }
      }

      if (isRateLimit) {
        throw Exception(
          'Signup blocked by Supabase email rate limit. Try Sign in with an existing account, or disable Email confirmation in Supabase Auth (for dev) and retry after a few minutes.',
        );
      }
      rethrow;
    }
  }

  Future<AppUser?> signInWithEmail({required String email, required String password}) async {
    await db.auth.signInWithPassword(email: email, password: password);
    return getCurrentUserProfile();
  }

  Future<void> signOut() async {
    await db.auth.signOut();
  }

  Stream<List<Map<String, dynamic>>> streamMessages() {
    return db.from('messages').stream(primaryKey: ['id']).order('timestamp', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamAnnouncements() {
    return db.from('announcements').stream(primaryKey: ['id']).order('date', ascending: false);
  }

  Stream<List<Map<String, dynamic>>> streamTasks() {
    return db.from('tasks').stream(primaryKey: ['id']).order('due_date', ascending: true);
  }

  Future<void> createMessage(MessageModel m) async {
    final id = const Uuid().v4();
    await db.from('messages').insert(m.toMap()..['id'] = id);
  }

  Future<void> createAnnouncement(AnnouncementModel a) async {
    final id = const Uuid().v4();
    await db.from('announcements').insert(a.toMap()..['id'] = id);
  }

  Future<void> createTask(TaskModel t) async {
    final id = const Uuid().v4();
    await db.from('tasks').insert(t.toMap()..['id'] = id);
  }

  Future<String> uploadFile(String filePath, Uint8List bytes) async {
    final id = const Uuid().v4();
    final storagePath = 'notes/$id';
    await db.storage.from('campus-files').uploadBinary(storagePath, bytes, fileOptions: const FileOptions(upsert: true));
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

  Future<void> seedDemoData() async {
    final students = [
      {
        'id': const Uuid().v4(),
        'name': 'Alice Johnson',
        'class_name': 'CSE CORE 4C',
        'roll_no': 'CS101',
        'section': '4C',
        'department': 'Computer Science',
        'email': 'alice@example.com',
      },
      {
        'id': const Uuid().v4(),
        'name': 'Bob Kumar',
        'class_name': 'CSE CORE 4C',
        'roll_no': 'CS102',
        'section': '4C',
        'department': 'Computer Science',
        'email': 'bob@example.com',
      }
    ];
    await db.from('students').upsert(students);

    await db.from('announcements').insert({
      'id': const Uuid().v4(),
      'title': 'Welcome to Campus Connect',
      'description': 'This is a demo announcement. Stay tuned for assignments and deadlines.',
      'sender_id': 'system',
      'sender_name': 'Admin',
      'priority': 'Normal',
      'date': DateTime.now().toIso8601String(),
      'target_class': 'all',
      'target_department': 'all',
    });
  }

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

  Future<void> importStudents(List<Map<String, dynamic>> students) async {
    if (students.isEmpty) return;
    await db.from('students').upsert(students);
  }

  Future<void> markAnnouncementRead({required String announcementId, required String studentId}) async {
    await db.from('announcement_reads').upsert({
      'announcement_id': announcementId,
      'student_id': studentId,
      'read_at': DateTime.now().toIso8601String(),
    });
  }
}
