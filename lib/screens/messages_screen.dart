import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import '../widgets/shimmer_loader.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _students = [];
  final List<Map<String, dynamic>> _teachers = List<Map<String, dynamic>>.from(MockData.teachers);
  String _sectionFilter = 'All';
  String _groupFilter = 'All';
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
          .searchStudents(query: query.trim().isEmpty ? null : query);
      if (!mounted) return;
      setState(() {
        _students = rows.isNotEmpty || query.trim().isNotEmpty
            ? rows
            : List<Map<String, dynamic>>.from(MockData.students);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _students = _filteredStudents(query));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _filteredStudents(String query) {
    final rows = List<Map<String, dynamic>>.from(MockData.students);
    if (query.trim().isEmpty) return rows;
    final q = query.toLowerCase();
    return rows.where((student) {
      return student['name'].toString().toLowerCase().contains(q) ||
          student['class_name'].toString().toLowerCase().contains(q) ||
          student['roll_no'].toString().toLowerCase().contains(q) ||
          student['section'].toString().toLowerCase().contains(q) ||
          student['department'].toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> _filteredTeachers(String query) {
    final rows = List<Map<String, dynamic>>.from(_teachers);
    if (query.trim().isEmpty) return rows;
    final q = query.toLowerCase();
    return rows.where((teacher) {
      return teacher['name'].toString().toLowerCase().contains(q) ||
          teacher['subject'].toString().toLowerCase().contains(q) ||
          teacher['role'].toString().toLowerCase().contains(q);
    }).toList();
  }

  List<Map<String, dynamic>> _visibleStudents(String query) {
    final rows = _students.where(_matchesRosterFilters).toList(growable: false);
    if (query.trim().isEmpty) return rows;
    final q = query.toLowerCase();
    return rows.where((student) {
      return student['name'].toString().toLowerCase().contains(q) ||
          student['class_name'].toString().toLowerCase().contains(q) ||
          student['roll_no'].toString().toLowerCase().contains(q) ||
          student['section'].toString().toLowerCase().contains(q) ||
          student['group'].toString().toLowerCase().contains(q) ||
          student['department'].toString().toLowerCase().contains(q);
    }).toList(growable: false);
  }

  bool _matchesRosterFilters(Map<String, dynamic> student) {
    final section = student['section'].toString();
    final group = student['group'].toString();
    final sectionOk = _sectionFilter == 'All' || section == _sectionFilter;
    final groupOk = _groupFilter == 'All' || group == _groupFilter;
    return sectionOk && groupOk;
  }

  void _openChat(BuildContext context, AppUser currentUser,
      Map<String, dynamic> contact, {required bool isTeacher}) {
    final subjectLine = isTeacher
        ? [contact['subject'], contact['role']]
            .where((value) => value != null && value.toString().isNotEmpty)
            .map((value) => value.toString())
            .join(' · ')
        : (contact['class_name'] ?? '').toString();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: ChatScreen(
            currentUserId: currentUser.id,
            currentUserName: currentUser.name,
            currentUserRole: currentUser.role,
            otherUserId: contact['id'] as String? ?? '',
            otherUserName: contact['name'] as String? ?? '',
            otherClass: isTeacher ? subjectLine : (contact['class_name'] as String? ?? ''),
            otherRollNo: isTeacher ? '' : (contact['roll_no'] as String? ?? ''),
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
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final query = _searchCtrl.text.trim();
    final visibleStudents = _visibleStudents(query);
    final visibleTeachers = _filteredTeachers(query);

    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 16 : 12, 12, isDesktop ? 16 : 12, 12),
      child: Column(
        children: [
          _SearchField(
            controller: _searchCtrl,
            onChanged: (value) {
              Future.delayed(const Duration(milliseconds: 250), () {
                if (_searchCtrl.text == value) _load(query: value);
              });
            },
          ),
          const SizedBox(height: 10),
          _RosterFilters(
            sectionFilter: _sectionFilter,
            groupFilter: _groupFilter,
            onSectionChanged: (value) => setState(() => _sectionFilter = value),
            onGroupChanged: (value) => setState(() => _groupFilter = value),
            onClear: (_sectionFilter != 'All' || _groupFilter != 'All')
                ? () => setState(() {
                      _sectionFilter = 'All';
                      _groupFilter = 'All';
                    })
                : null,
          ),
          const SizedBox(height: 12),
          if (isDesktop)
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _ContactsPane(
                      title: 'Students',
                      subtitle: 'CSE 4C roster',
                      count: _loading ? null : visibleStudents.length,
                      loading: _loading,
                      emptyText: 'No students match the search.',
                      children: _loading
                          ? const [ShimmerContactCard(), ShimmerContactCard(), ShimmerContactCard(), ShimmerContactCard()]
                          : visibleStudents.isEmpty
                              ? const []
                              : List.generate(visibleStudents.length, (index) {
                                  final student = visibleStudents[index];
                                  return _StudentTile(
                                    student: student,
                                    hasUnread: index % 3 == 0,
                                    onTap: user == null ? null : () => _openChat(context, user, student, isTeacher: false),
                                  );
                                }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ContactsPane(
                      title: 'CSE 4C Teachers',
                      subtitle: 'Faculty and mentors',
                        count: _loading ? null : visibleTeachers.length,
                      loading: _loading,
                      emptyText: 'No teachers match the search.',
                      children: _loading
                          ? const [ShimmerContactCard(), ShimmerContactCard(), ShimmerContactCard()]
                          : visibleTeachers.isEmpty
                              ? const []
                            : visibleTeachers
                                  .map((teacher) => _TeacherTile(
                                        teacher: teacher,
                                        onTap: user == null ? null : () => _openChat(context, user, teacher, isTeacher: true),
                                      ))
                                  .toList(),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TabBar(
                        tabs: const [
                          Tab(text: 'Students'),
                          Tab(text: 'Teachers'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _ContactsPane(
                            title: 'Students',
                            subtitle: 'CSE 4C roster',
                            count: _loading ? null : visibleStudents.length,
                            loading: _loading,
                            emptyText: 'No students match the search.',
                            children: _loading
                                ? const [ShimmerContactCard(), ShimmerContactCard(), ShimmerContactCard()]
                              : visibleStudents.isEmpty
                                    ? const []
                                : List.generate(visibleStudents.length, (index) {
                                  final student = visibleStudents[index];
                                        return _StudentTile(
                                          student: student,
                                          hasUnread: index % 3 == 0,
                                          onTap: user == null ? null : () => _openChat(context, user, student, isTeacher: false),
                                        );
                                      }),
                          ),
                          _ContactsPane(
                            title: 'Teachers',
                            subtitle: 'CSE 4C faculty',
                            count: _loading ? null : visibleTeachers.length,
                            loading: _loading,
                            emptyText: 'No teachers match the search.',
                            children: _loading
                                ? const [ShimmerContactCard(), ShimmerContactCard(), ShimmerContactCard()]
                              : visibleTeachers.isEmpty
                                    ? const []
                                : visibleTeachers
                                        .map((teacher) => _TeacherTile(
                                              teacher: teacher,
                                              onTap: user == null ? null : () => _openChat(context, user, teacher, isTeacher: true),
                                            ))
                                        .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RosterFilters extends StatelessWidget {
  final String sectionFilter;
  final String groupFilter;
  final ValueChanged<String> onSectionChanged;
  final ValueChanged<String> onGroupChanged;
  final VoidCallback? onClear;

  const _RosterFilters({
    required this.sectionFilter,
    required this.groupFilter,
    required this.onSectionChanged,
    required this.onGroupChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final sections = ['All', ...MockData.availableSections];
    final groups = ['All', ...MockData.availableGroups];

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _FilterGroup(
            label: 'Section',
            values: sections,
            selected: sectionFilter,
            onChanged: onSectionChanged,
          ),
          _FilterGroup(
            label: 'Group',
            values: groups,
            selected: groupFilter,
            onChanged: onGroupChanged,
          ),
          if (onClear != null)
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_all_rounded, size: 16),
              label: const Text('Clear filters'),
            ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final List<String> values;
  final String selected;
  final ValueChanged<String> onChanged;

  const _FilterGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '$label:',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.onSurfaceMuted,
          ),
        ),
        ...values.map(
          (value) => ChoiceChip(
            label: Text(value),
            selected: selected == value,
            onSelected: (_) => onChanged(value),
            labelStyle: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected == value ? Colors.white : AppTheme.onSurfaceMuted,
            ),
            selectedColor: AppTheme.primary,
            backgroundColor: AppTheme.surfaceCard,
            side: BorderSide(color: AppTheme.surfaceCardLight.withValues(alpha: 0.2)),
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Search students or teachers',
        prefixIcon: const Icon(Icons.search, color: AppTheme.onSurfaceMuted, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.onSurfaceMuted, size: 18),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
      ),
    );
  }
}

class _ContactsPane extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? count;
  final bool loading;
  final String emptyText;
  final List<Widget> children;

  const _ContactsPane({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.loading,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (count != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: children.isEmpty && !loading
                ? Center(
                    child: Text(
                      emptyText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: children.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => children[index],
                  ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final Map<String, dynamic> student;
  final bool hasUnread;
  final VoidCallback? onTap;

  const _StudentTile({required this.student, required this.hasUnread, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = student['name'].toString();
    final className = student['class_name'].toString();
    final rollNo = student['roll_no'].toString();
    final initials = name.trim().split(' ').map((part) => part.isNotEmpty ? part[0] : '').take(2).join().toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCardLight.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceCardLight.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.18),
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppTheme.unreadDot,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.surfaceCard, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$className · Roll No: $rollNo',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppTheme.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _TeacherTile extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback? onTap;

  const _TeacherTile({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = teacher['name'].toString();
    final subject = teacher['subject'].toString();
    final role = (teacher['role'] ?? '').toString();
    final initials = name.trim().split(' ').map((part) => part.isNotEmpty ? part[0] : '').take(2).join().toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCardLight.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.surfaceCardLight.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.catDept.withValues(alpha: 0.16),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.catDept,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subject,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                  if (role.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppTheme.onSurfaceMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
