import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';
import '../widgets/student_contact_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import '../utils/app_theme.dart';
import 'chat_screen.dart';

/// Student contact list — identity first, no message preview
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  String? _error;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final rows = await FirebaseService.instance
          .searchStudents(query: query.isEmpty ? null : query);
      if (mounted) setState(() => _students = rows);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openChat(
    BuildContext context,
    AppUser currentUser,
    Map<String, dynamic> student,
  ) {
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
                Future.delayed(const Duration(milliseconds: 350), () {
              if (_searchCtrl.text == v) _load(query: v);
            }),
            style: const TextStyle(color: AppTheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search by name, class or roll no...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceMuted, size: 20),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppTheme.onSurfaceMuted, size: 18),
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
          child: _error != null
              ? EmptyState(
                  icon: Icons.wifi_off_rounded,
                  title: 'Could not load students',
                  subtitle: _error,
                  action: ElevatedButton(
                    onPressed: _load,
                    child: const Text('Retry'),
                  ),
                )
              : _loading
                  ? ListView.builder(
                      itemCount: 8,
                      itemBuilder: (_, __) => const ShimmerContactCard(),
                    )
                  : _students.isEmpty
                      ? const EmptyState(
                          icon: Icons.people_outline,
                          title: 'No students found',
                          subtitle:
                              'Try a different name, class or roll number.',
                        )
                      : ListView.builder(
                          itemCount: _students.length,
                          itemBuilder: (context, i) {
                            final s = _students[i];
                            return StudentContactCard(
                              student: s,
                              hasUnread: false, // TODO: integrate with real DM unread tracking
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
