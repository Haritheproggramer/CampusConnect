import 'dart:typed_data';
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import '../services/firebase_service.dart';
import '../models/announcement_model.dart';
import '../models/message_model.dart';
import '../utils/mock_data.dart';
import '../utils/app_theme.dart';
import '../widgets/broadcast_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import 'profile_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    // ignore: unused_local_variable
    final bool isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.school_rounded, color: AppTheme.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Campus Connect',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                Text('Teacher Dashboard',
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.onSurfaceMuted)),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.person_outline, size: 16),
              label: Text(auth.user?.name.split(' ').first ?? 'Me',
                  style: const TextStyle(fontSize: 13)),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ProfileScreen())),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Post'),
            Tab(text: 'Students'),
            Tab(text: 'Files'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _OverviewTab(),
          _PostTab(auth: auth),
          _StudentsTab(auth: auth),
          _FilesTab(auth: auth),
        ],
      ),
    );
  }
}

// ── Overview ─────────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) return const ShimmerList(count: 5, cardHeight: 100);
        if (provider.all.isEmpty) {
          return EmptyState(
            icon: Icons.campaign_outlined,
            title: 'No announcements yet',
            subtitle: 'Go to the Post tab to create one.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: provider.all.length,
          itemBuilder: (_, i) => BroadcastCard(model: provider.all[i]),
        );
      },
    );
  }
}

// ── Post ─────────────────────────────────────────────────────────────────────

class _PostTab extends StatefulWidget {
  final AuthProvider auth;
  const _PostTab({required this.auth});

  @override
  State<_PostTab> createState() => _PostTabState();
}

class _PostTabState extends State<_PostTab> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _msgTitleCtrl = TextEditingController();
  final _msgBodyCtrl = TextEditingController();
  AnnouncementCategory _annCat = AnnouncementCategory.all;
  String _msgCat = 'all';
  String _priority = 'Normal';
  bool _busy = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _msgTitleCtrl.dispose();
    _msgBodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionLabel('Post Announcement'),
        const SizedBox(height: 12),
        _card([
          _label('Category (ONE only)'),
          const SizedBox(height: 8),
          _categoryPicker(
            selected: _annCat,
            onChanged: (c) => setState(() => _annCat = c),
          ),
          const SizedBox(height: 12),
          _tf(_titleCtrl, 'Title', Icons.title),
          const SizedBox(height: 10),
          _tf(_descCtrl, 'Description', Icons.notes_rounded, maxLines: 3),
          const SizedBox(height: 10),
          _priorityPicker(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Post Announcement'),
              onPressed: _busy ? null : _postAnn,
            ),
          ),
        ]),
        const SizedBox(height: 24),
        _sectionLabel('Send Message'),
        const SizedBox(height: 12),
        _card([
          _label('Message Category (ONE only)'),
          const SizedBox(height: 8),
          _msgCategoryPicker(),
          const SizedBox(height: 12),
          _tf(_msgTitleCtrl, 'Title', Icons.title),
          const SizedBox(height: 10),
          _tf(_msgBodyCtrl, 'Message body', Icons.message_outlined, maxLines: 4),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send Message'),
              onPressed: _busy ? null : _sendMsg,
            ),
          ),
        ]),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.science_outlined, size: 16),
            label: const Text('Seed Demo Data'),
            onPressed: _busy ? null : _seed,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String t) => Text(t,
      style: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.onSurface));

  Widget _label(String t) => Text(t,
      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceMuted));

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _tf(TextEditingController ctrl, String hint, IconData icon,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppTheme.onSurfaceMuted),
      ),
    );
  }

  Widget _categoryPicker({
    required AnnouncementCategory selected,
    required ValueChanged<AnnouncementCategory> onChanged,
  }) {
    return Row(
      children: AnnouncementCategory.values.map((cat) {
        final sel = selected == cat;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? cat.color.withValues(alpha: 0.2) : AppTheme.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? cat.color : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: cat.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? cat.color : AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _msgCategoryPicker() {
    const cats = [
      {'val': 'all', 'label': 'All', 'color': AppTheme.catAll},
      {'val': 'department', 'label': 'Dept', 'color': AppTheme.catDept},
      {'val': 'class', 'label': 'Class', 'color': AppTheme.catClass},
    ];
    return Row(
      children: cats.map((c) {
        final val = c['val'] as String;
        final label = c['label'] as String;
        final color = c['color'] as Color;
        final sel = _msgCat == val;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _msgCat = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: sel ? color.withAlpha(51) : AppTheme.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? color : Colors.transparent),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? color : AppTheme.onSurfaceMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _priorityPicker() {
    const opts = [
      {'val': 'Normal', 'color': AppTheme.onSurfaceMuted},
      {'val': 'Important', 'color': AppTheme.warning},
      {'val': 'Urgent', 'color': AppTheme.error},
    ];
    return Row(
      children: opts.map((o) {
        final val = o['val'] as String;
        final color = o['color'] as Color;
        final sel = _priority == val;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = val),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: sel ? color.withAlpha(38) : AppTheme.surfaceCardLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: sel ? color : Colors.transparent),
              ),
              child: Text(
                val,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? color : AppTheme.onSurfaceMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _postAnn() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _busy = true);
    try {
      final a = AnnouncementModel(
        id: '',
        title: title,
        description: _descCtrl.text.trim(),
        senderId: widget.auth.user?.id ?? '',
        senderName: widget.auth.user?.name ?? 'Teacher',
        priority: _priority,
        category: _annCat,
      );
      await FirebaseService.instance.createAnnouncement(a);
      _titleCtrl.clear();
      _descCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted ✓')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendMsg() async {
    final title = _msgTitleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _busy = true);
    try {
      final m = MessageModel(
        id: '',
        title: title,
        body: _msgBodyCtrl.text.trim(),
        category: _msgCat,
        senderId: widget.auth.user?.id ?? '',
        senderName: widget.auth.user?.name ?? 'Teacher',
        senderRole: widget.auth.user?.role ?? 'teacher',
        priority: _priority,
      );
      await FirebaseService.instance.createMessage(m);
      _msgTitleCtrl.clear();
      _msgBodyCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Message sent ✓')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _seed() async {
    setState(() => _busy = true);
    try {
      await FirebaseService.instance.seedDemoData();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Demo data seeded ✓')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

// ── Students ─────────────────────────────────────────────────────────────────

class _StudentsTab extends StatefulWidget {
  final AuthProvider auth;
  const _StudentsTab({required this.auth});

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _students = [];
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
          .searchStudents(query: query.isEmpty ? null : query);
      if (mounted) setState(() => _students = rows);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> _visibleStudents(String query) {
    final rows = _students.where(_matchesFilters).toList(growable: false);
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

  bool _matchesFilters(Map<String, dynamic> student) {
    final section = student['section'].toString();
    final group = student['group'].toString();
    final sectionOk = _sectionFilter == 'All' || section == _sectionFilter;
    final groupOk = _groupFilter == 'All' || group == _groupFilter;
    return sectionOk && groupOk;
  }

  Future<void> _importXlsx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || result.files.single.bytes == null) return;

    final Uint8List bytes = result.files.single.bytes!;
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.tables[excel.tables.keys.first];
    if (sheet == null) return;

    final rows = <Map<String, dynamic>>[];
    for (var i = 1; i < sheet.rows.length; i++) {
      final r = sheet.rows[i];
      String cell(int idx) =>
          idx < r.length ? (r[idx]?.value?.toString() ?? '').trim() : '';
      final name = cell(0);
      if (name.isEmpty) continue;
      rows.add({
        'id': const Uuid().v4(),
        'name': name,
        'class_name': cell(1).isEmpty ? 'CSE 4C' : cell(1),
        'roll_no': cell(2),
        'section': cell(3).isEmpty ? 'C' : cell(3),
        'group': cell(4).isEmpty ? 'G1' : cell(4),
        'department': cell(5).isEmpty ? 'CSE' : cell(5),
        'email': cell(6),
      });
    }

    await FirebaseService.instance.importStudents(rows);
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imported ${rows.length} students ✓')));
    }
  }

  Future<void> _toggleCR(String studentId, bool currentCR) async {
    await FirebaseService.instance
        .toggleCR(studentId: studentId, isCR: !currentCR);
    await _load(query: _searchCtrl.text);
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchCtrl.text.trim();
    final visibleStudents = _visibleStudents(query);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => Future.delayed(
                          const Duration(milliseconds: 350),
                          () => _load(query: v)),
                      style: const TextStyle(color: AppTheme.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon:
                            Icon(Icons.search, color: AppTheme.onSurfaceMuted, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file, size: 16),
                    label: const Text('Import XLSX'),
                    onPressed: _importXlsx,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.catDept,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _FilterGroup(
                      label: 'Section',
                      values: ['All', ...MockData.availableSections],
                      selected: _sectionFilter,
                      onChanged: (value) => setState(() => _sectionFilter = value),
                    ),
                    _FilterGroup(
                      label: 'Group',
                      values: ['All', ...MockData.availableGroups],
                      selected: _groupFilter,
                      onChanged: (value) => setState(() => _groupFilter = value),
                    ),
                    if (_sectionFilter != 'All' || _groupFilter != 'All')
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _sectionFilter = 'All';
                          _groupFilter = 'All';
                        }),
                        icon: const Icon(Icons.clear_all_rounded, size: 16),
                        label: const Text('Clear filters'),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? ListView.builder(
                  itemCount: 8, itemBuilder: (_, __) => const ShimmerContactCard())
              : visibleStudents.isEmpty
                  ? const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No students found',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: visibleStudents.length,
                      itemBuilder: (context, i) {
                        final s = visibleStudents[i];
                        final isCR = s['is_cr'] == true;
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor:
                                    AppTheme.primary.withValues(alpha: 0.15),
                                child: Text(
                                  (s['name'] as String? ?? '?')
                                      .trim()
                                      .split(' ')
                                      .map((e) => e[0])
                                      .take(2)
                                      .join()
                                      .toUpperCase(),
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primary),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          s['name'] ?? '—',
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.onSurface),
                                        ),
                                        if (isCR) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppTheme.catClass
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text('CR',
                                                style: GoogleFonts.inter(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppTheme.catClass)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Text(
                                      '${s['class_name'] ?? ''}  ·  Roll: ${s['roll_no'] ?? '—'}',
                                      style: GoogleFonts.inter(
                                          fontSize: 11,
                                          color: AppTheme.onSurfaceMuted),
                                    ),
                                    if ((s['group'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.surfaceCardLight.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          'Group ${(s['group'] ?? '').toString()}',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.onSurfaceMuted,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // CR Toggle
                              Tooltip(
                                message: isCR ? 'Remove CR' : 'Make CR',
                                child: IconButton(
                                  onPressed: () =>
                                      _toggleCR(s['id'] as String, isCR),
                                  icon: Icon(
                                    isCR
                                        ? Icons.star_rounded
                                        : Icons.star_outline_rounded,
                                    color:
                                        isCR ? AppTheme.catClass : AppTheme.onSurfaceMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
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

// ── Files ─────────────────────────────────────────────────────────────────────

class _FilesTab extends StatefulWidget {
  final AuthProvider auth;
  const _FilesTab({required this.auth});

  @override
  State<_FilesTab> createState() => _FilesTabState();
}

class _FilesTabState extends State<_FilesTab> {
  final _nameCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  bool _busy = false;
  List<Map<String, dynamic>>? _files;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFiles() async {
    final rows = await FirebaseService.instance.fetchFiles();
    if (mounted) setState(() => _files = rows);
  }

  Future<void> _saveLink() async {
    if (_linkCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await FirebaseService.instance.saveFileRecord(
        name: _nameCtrl.text.trim().isEmpty
            ? 'Untitled Document'
            : _nameCtrl.text.trim(),
        url: _linkCtrl.text.trim(),
        uploadedBy: widget.auth.user?.id ?? '',
        fileType: 'drive-link',
      );
      _nameCtrl.clear();
      _linkCtrl.clear();
      await _loadFiles();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Drive link saved ✓')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share a Document',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface)),
              const SizedBox(height: 12),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration: const InputDecoration(hintText: 'Document name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _linkCtrl,
                style: const TextStyle(color: AppTheme.onSurface),
                decoration:
                    const InputDecoration(hintText: 'Google Drive / URL link'),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.link_rounded, size: 18),
                  label: const Text('Save Link'),
                  onPressed: _busy ? null : _saveLink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Shared Files',
            style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface)),
        const SizedBox(height: 10),
        if (_files == null)
          const ShimmerList(count: 4, cardHeight: 60)
        else if (_files!.isEmpty)
          const EmptyState(
            icon: Icons.folder_open_rounded,
            title: 'No files shared yet',
          )
        else
          ..._files!.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        color: AppTheme.catAll, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        f['name'] ?? 'File',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppTheme.onSurface),
                      ),
                    ),
                    const Icon(Icons.open_in_new,
                        color: AppTheme.onSurfaceMuted, size: 16),
                  ],
                ),
              )),
      ],
    );
  }
}
