import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import '../utils/section_rosters.dart';
import 'chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();

  // Class selector — default to the only class with real data
  String _selectedClass = 'CSE Core C';

  // Group filter
  String _groupFilter = 'All';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Data ──────────────────────────────────────────────────────────────────

  /// Always read from the local roster — never from Supabase stale data.
  List<Map<String, dynamic>> get _rosterStudents {
    final raw = SectionRosterData.studentsForClass(_selectedClass);
    // Ensure 'id' key exists for chat navigation
    return raw.map((s) => {...s, 'id': s['roll_no']}).toList(growable: false);
  }

  List<Map<String, dynamic>> get _teachers =>
      List<Map<String, dynamic>>.from(MockData.teachers);

  List<String> get _groupOptions {
    final groups = _rosterStudents
        .map((s) => s['group']?.toString() ?? '')
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...groups];
  }

  List<Map<String, dynamic>> _visibleStudents(String query) {
    var rows = _rosterStudents;
    // Group filter
    if (_groupFilter != 'All') {
      rows = rows.where((s) => s['group']?.toString() == _groupFilter).toList();
    }
    // Search filter
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      rows = rows.where((s) {
        return s['name'].toString().toLowerCase().contains(q) ||
            s['roll_no'].toString().toLowerCase().contains(q) ||
            (s['group']?.toString().toLowerCase().contains(q) ?? false);
      }).toList();
    }
    return rows;
  }

  List<Map<String, dynamic>> _visibleTeachers(String query) {
    if (query.trim().isEmpty) return _teachers;
    final q = query.trim().toLowerCase();
    return _teachers.where((t) {
      return t['name'].toString().toLowerCase().contains(q) ||
          t['subject'].toString().toLowerCase().contains(q) ||
          (t['role']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _openChat(BuildContext context, AppUser currentUser,
      Map<String, dynamic> contact,
      {required bool isTeacher}) {
    final subjectLine = isTeacher
        ? [contact['subject'], contact['role']]
            .where((v) => v != null && v.toString().isNotEmpty)
            .map((v) => v.toString())
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
            otherClass: isTeacher
                ? subjectLine
                : (contact['class_name'] as String? ?? ''),
            otherRollNo:
                isTeacher ? '' : (contact['roll_no'] as String? ?? ''),
          ),
        ),
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    final query = _searchCtrl.text.trim();
    final onStudentTab = _tabCtrl.index == 0;

    final visibleStudents = _visibleStudents(query);
    final visibleTeachers = _visibleTeachers(query);

    final hasRoster = SectionRosterData.hasRoster(_selectedClass);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Class / Section selector ───────────────────────────────────────
          _ClassSelector(
            selected: _selectedClass,
            onChanged: (v) => setState(() {
              _selectedClass = v;
              _groupFilter = 'All';
            }),
          ),
          const SizedBox(height: 10),

          // ── Search bar ────────────────────────────────────────────────────
          _SearchField(
            controller: _searchCtrl,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 10),

          // ── Tab bar: Students | Teachers ───────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 16),
                      const SizedBox(width: 6),
                      const Text('Students'),
                      if (hasRoster) ...[
                        const SizedBox(width: 6),
                        _CountBadge(count: visibleStudents.length),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined, size: 16),
                      const SizedBox(width: 6),
                      const Text('Teachers'),
                      const SizedBox(width: 6),
                      _CountBadge(count: visibleTeachers.length),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Group filter — only on student tab and when roster exists ─────
          if (onStudentTab && hasRoster)
            _GroupFilter(
              options: _groupOptions,
              selected: _groupFilter,
              onChanged: (v) => setState(() => _groupFilter = v),
            ),
          if (onStudentTab && hasRoster) const SizedBox(height: 10),

          // ── Content ───────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                // ── Students tab ─────────────────────────────────────────────
                !hasRoster
                    ? _RosterNotAdded(
                        className: SectionRosterData
                                .classDisplayNames[_selectedClass] ??
                            _selectedClass,
                      )
                    : visibleStudents.isEmpty
                        ? _EmptySearch(
                            message: query.isEmpty
                                ? 'No students match the filters.'
                                : 'No students match "$query".',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: visibleStudents.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 6),
                            itemBuilder: (ctx, i) {
                              final s = visibleStudents[i];
                              return _StudentTile(
                                student: s,
                                onTap: user == null
                                    ? null
                                    : () => _openChat(ctx, user, s,
                                        isTeacher: false),
                              );
                            },
                          ),

                // ── Teachers tab ─────────────────────────────────────────────
                visibleTeachers.isEmpty
                    ? _EmptySearch(
                        message: 'No teachers match "$query".',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: visibleTeachers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (ctx, i) {
                          final t = visibleTeachers[i];
                          return _TeacherTile(
                            teacher: t,
                            onTap: user == null
                                ? null
                                : () => _openChat(ctx, user, t,
                                    isTeacher: true),
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Class selector ──────────────────────────────────────────────────────────

class _ClassSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _ClassSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: SectionRosterData.allClassLabels.map((label) {
          final isSelected = selected == label;
          final hasData = SectionRosterData.hasRoster(label);
          final displayName =
              SectionRosterData.classDisplayNames[label] ?? label;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.18)
                      : AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : AppTheme.surfaceCardLight.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.onSurfaceMuted,
                      ),
                    ),
                    if (!hasData) ...[
                      const SizedBox(width: 5),
                      Icon(
                        Icons.lock_outline,
                        size: 11,
                        color: isSelected
                            ? AppTheme.primary.withValues(alpha: 0.6)
                            : AppTheme.onSurfaceMuted.withValues(alpha: 0.5),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Group filter chips ───────────────────────────────────────────────────────

class _GroupFilter extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _GroupFilter({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Group:',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          ...options.map(
            (g) => ChoiceChip(
              label: Text(g),
              selected: selected == g,
              onSelected: (_) => onChanged(g),
              labelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected == g ? Colors.white : AppTheme.onSurfaceMuted,
              ),
              selectedColor: AppTheme.primary,
              backgroundColor: AppTheme.surfaceCard,
              side: BorderSide(
                  color: AppTheme.surfaceCardLight.withValues(alpha: 0.25)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────

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
        hintText: 'Search name, roll no, group…',
        prefixIcon:
            const Icon(Icons.search, color: AppTheme.onSurfaceMuted, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear,
                    color: AppTheme.onSurfaceMuted, size: 18),
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

// ── Empty / placeholder states ───────────────────────────────────────────────

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _RosterNotAdded extends StatelessWidget {
  final String className;
  const _RosterNotAdded({required this.className});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_add_outlined,
                size: 48, color: AppTheme.onSurfaceMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'Roster not added yet',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Student data for $className has not been added.\nContact your CR or admin to upload the roster.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String message;
  const _EmptySearch({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceMuted),
      ),
    );
  }
}

// ── Student tile ─────────────────────────────────────────────────────────────

class _StudentTile extends StatelessWidget {
  final Map<String, dynamic> student;
  final VoidCallback? onTap;

  const _StudentTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = student['name'].toString();
    final rollNo = student['roll_no'].toString();
    final group = student['group']?.toString() ?? '';
    final isCR = student['is_cr'] == true;
    final initials = name
        .trim()
        .split(' ')
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: isCR
                  ? AppTheme.catClass.withValues(alpha: 0.18)
                  : AppTheme.primary.withValues(alpha: 0.15),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCR ? AppTheme.catClass : AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + roll
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCR) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.catClass.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'CR',
                            style: GoogleFonts.inter(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.catClass,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    rollNo,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Group badge
            if (group.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: group == 'G1'
                      ? AppTheme.catAll.withValues(alpha: 0.14)
                      : AppTheme.catDept.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  group,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: group == 'G1' ? AppTheme.catAll : AppTheme.catDept,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: AppTheme.onSurfaceMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

// ── Teacher tile ─────────────────────────────────────────────────────────────

class _TeacherTile extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final VoidCallback? onTap;

  const _TeacherTile({required this.teacher, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = teacher['name'].toString();
    final subject = teacher['subject'].toString();
    final role = (teacher['role'] ?? '').toString();
    final initials = name
        .trim()
        .split(' ')
        .map((p) => p.isNotEmpty ? p[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.catDept.withValues(alpha: 0.16),
              child: Text(
                initials.isEmpty ? '?' : initials,
                style: GoogleFonts.inter(
                  fontSize: 13,
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
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            if (role.isNotEmpty)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role,
                  style: GoogleFonts.inter(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right,
                color: AppTheme.onSurfaceMuted, size: 16),
          ],
        ),
      ),
    );
  }
}
