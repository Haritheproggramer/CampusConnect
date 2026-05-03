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

  // Class selector — default to the only class with real data
  String _selectedClass = 'CSE Core C';
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
    super.dispose();
  }

  List<Map<String, dynamic>> get _rosterStudents {
    final raw = SectionRosterData.studentsForClass(_selectedClass);
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

  List<Map<String, dynamic>> filteredStudents(String query) {
    var rows = _rosterStudents;
    if (_groupFilter != 'All') {
      rows = rows.where((s) => s['group']?.toString() == _groupFilter).toList();
    }
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

  List<Map<String, dynamic>> filteredTeachers(String query) {
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
                ? [contact['subject'], contact['role']]
                    .where((v) => v != null && v.toString().isNotEmpty)
                    .map((v) => v.toString())
                    .join(' · ')
                : (contact['class_name'] as String? ?? ''),
            otherRollNo:
                isTeacher ? '' : (contact['roll_no'] as String? ?? ''),
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
    final hasRoster = SectionRosterData.hasRoster(_selectedClass);
    final onStudentTab = _tabCtrl.index == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Class / Section selector ─────────────────────────────────────
          _ClassSelector(
            selected: _selectedClass,
            onChanged: (v) => setState(() {
              _selectedClass = v;
              _groupFilter = 'All';
            }),
          ),
          const SizedBox(height: 10),

          // ── Tab bar: Students | Teachers ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 16),
                      SizedBox(width: 6),
                      Text('Students'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Teachers'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // ── Group filter — only on student tab and when roster exists ────
          if (onStudentTab && hasRoster)
            _GroupFilter(
              options: _groupOptions,
              selected: _groupFilter,
              onChanged: (v) => setState(() => _groupFilter = v),
            ),
          if (onStudentTab && hasRoster) const SizedBox(height: 10),

          // ── Tab content — each tab manages its own search ────────────────
          Expanded(
            child: IndexedStack(
              index: _tabCtrl.index,
              children: [
                // Students tab — isolated search
                _StudentsTab(
                  hasRoster: hasRoster,
                  selectedClass: _selectedClass,
                  groupFilter: _groupFilter,
                  rosterStudents: _rosterStudents,
                  user: user,
                  onOpen: (ctx, contact) =>
                      _openChat(ctx, user!, contact, isTeacher: false),
                ),
                // Teachers tab — isolated search
                _TeachersTab(
                  teachers: _teachers,
                  user: user,
                  onOpen: (ctx, contact) =>
                      _openChat(ctx, user!, contact, isTeacher: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Students tab — own search bar, own state
// ══════════════════════════════════════════════════════════════════════════════

class _StudentsTab extends StatefulWidget {
  final bool hasRoster;
  final String selectedClass;
  final String groupFilter;
  final List<Map<String, dynamic>> rosterStudents;
  final AppUser? user;
  final void Function(BuildContext, Map<String, dynamic>) onOpen;

  const _StudentsTab({
    required this.hasRoster,
    required this.selectedClass,
    required this.groupFilter,
    required this.rosterStudents,
    required this.user,
    required this.onOpen,
  });

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab>
    with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    var rows = widget.rosterStudents;
    if (widget.groupFilter != 'All') {
      rows = rows
          .where((s) => s['group']?.toString() == widget.groupFilter)
          .toList();
    }
    final q = _search.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      rows = rows.where((s) {
        return s['name'].toString().toLowerCase().contains(q) ||
            s['roll_no'].toString().toLowerCase().contains(q) ||
            (s['group']?.toString().toLowerCase().contains(q) ?? false);
      }).toList();
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!widget.hasRoster) {
      return _RosterNotAdded(
        className:
            SectionRosterData.classDisplayNames[widget.selectedClass] ??
                widget.selectedClass,
      );
    }

    final rows = _filtered;
    return Column(
      children: [
        _SearchField(
          controller: _search,
          hint: 'Search student name, roll no, group…',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        // Count
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${rows.length} student${rows.length == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    _search.text.isEmpty
                        ? 'No students match filters.'
                        : 'No match for "${_search.text}".',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.onSurfaceMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _StudentTile(
                    student: rows[i],
                    onTap: widget.user == null
                        ? null
                        : () => widget.onOpen(ctx, rows[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Teachers tab — own search bar, own state
// ══════════════════════════════════════════════════════════════════════════════

class _TeachersTab extends StatefulWidget {
  final List<Map<String, dynamic>> teachers;
  final AppUser? user;
  final void Function(BuildContext, Map<String, dynamic>) onOpen;

  const _TeachersTab({
    required this.teachers,
    required this.user,
    required this.onOpen,
  });

  @override
  State<_TeachersTab> createState() => _TeachersTabState();
}

class _TeachersTabState extends State<_TeachersTab>
    with AutomaticKeepAliveClientMixin {
  final _search = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_search.text.trim().isEmpty) return widget.teachers;
    final q = _search.text.trim().toLowerCase();
    return widget.teachers.where((t) {
      return t['name'].toString().toLowerCase().contains(q) ||
          t['subject'].toString().toLowerCase().contains(q) ||
          (t['role']?.toString().toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final rows = _filtered;
    return Column(
      children: [
        _SearchField(
          controller: _search,
          hint: 'Search teacher name or subject…',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${rows.length} teacher${rows.length == 1 ? '' : 's'}',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: rows.isEmpty
              ? Center(
                  child: Text(
                    'No match for "${_search.text}".',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppTheme.onSurfaceMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 24),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (ctx, i) => _TeacherTile(
                    teacher: rows[i],
                    onTap: widget.user == null
                        ? null
                        : () => widget.onOpen(ctx, rows[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Class selector ────────────────────────────────────────────────────────────

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

// ── Group filter chips ────────────────────────────────────────────────────────

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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField(
      {required this.controller,
      required this.hint,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
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

// ── Placeholder states ────────────────────────────────────────────────────────

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
                size: 48,
                color: AppTheme.onSurfaceMuted.withValues(alpha: 0.5)),
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
              'Student data for $className has not been added.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Student tile ──────────────────────────────────────────────────────────────

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
                        fontSize: 11, color: AppTheme.onSurfaceMuted),
                  ),
                ],
              ),
            ),
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

// ── Teacher tile ──────────────────────────────────────────────────────────────

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
