import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../widgets/student_contact_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String query = ''}) async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final rows = await FirebaseService.instance
          .searchStudents(query: query.isEmpty ? null : query);
      if (mounted) {
        setState(() {
          // If backend returned nothing or errored, use mock data filtered by query
          _students = rows.isNotEmpty ? rows : _filteredMock(query);
        });
      }
    } catch (_) {
      // Silent fallback — show mock students
      if (mounted) setState(() => _students = _filteredMock(query));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _filteredMock(String query) {
    if (query.isEmpty) return MockData.students;
    final q = query.toLowerCase();
    return MockData.students.where((s) {
      return (s['name'] as String).toLowerCase().contains(q) ||
          (s['class_name'] as String).toLowerCase().contains(q) ||
          (s['roll_no'] as String).toLowerCase().contains(q) ||
          (s['section'] as String).toLowerCase().contains(q);
    }).toList();
  }

  void _openChat(BuildContext context, AppUser currentUser, Map<String, dynamic> student) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: ChatScreen(
            currentUserId: currentUser.id,
            currentUserName: currentUser.name,
            currentUserRole: currentUser.role,
            otherUserId: student['id'] as String? ?? '',
            otherUserName: student['name'] as String? ?? '',
            otherClass: student['class_name'] as String? ?? '',
            otherRollNo: student['roll_no'] as String? ?? '',
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) =>
                Future.delayed(const Duration(milliseconds: 300), () {
              if (_searchCtrl.text == v) _load(query: v);
            }),
            style: const TextStyle(color: AppTheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search by name, roll no, or group...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceMuted, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.onSurfaceMuted, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        _load();
                      },
                    )
                  : null,
            ),
          ),
        ),
        // List
        Expanded(
          child: _loading
              ? ListView.builder(
                  itemCount: 8,
                  itemBuilder: (_, __) => const ShimmerContactCard(),
                )
              : _students.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No students found',
                      subtitle: 'Try a different name or roll number.',
                    )
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, i) {
                        final s = _students[i];
                        return StudentContactCard(
                          student: s,
                          hasUnread: false,
                          onTap: user == null
                              ? () {}
                              : () => _openChat(context, user, s),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
