import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/auth_provider.dart';
import '../services/firebase_service.dart';
import '../models/announcement_model.dart';
import '../models/message_model.dart';
import '../models/task_model.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _annTitleCtrl = TextEditingController();
  final _annDescCtrl = TextEditingController();
  final _msgTitleCtrl = TextEditingController();
  final _msgBodyCtrl = TextEditingController();
  final _targetClassCtrl = TextEditingController(text: 'all');
  final _targetDeptCtrl = TextEditingController(text: 'all');
  final _driveNameCtrl = TextEditingController();
  final _driveLinkCtrl = TextEditingController();
  final _studentSearchCtrl = TextEditingController();

  String _priority = 'Normal';
  String _category = 'general';
  bool _busy = false;
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _searchStudents();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    final children = [
      _buildAnnouncementCard(auth),
      _buildMessageCard(auth),
      _buildFilesCard(auth),
      _buildStudentsCard(),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: _busy
            ? null
            : () async {
                setState(() => _busy = true);
                try {
                  await FirebaseService.instance.seedDemoData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded demo data')));
                  }
                } finally {
                  if (mounted) setState(() => _busy = false);
                }
              },
        child: const Text('Seed Demo Data'),
      ),
      const SizedBox(height: 40),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Teacher Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: ListView(children: [Text('Welcome, ${auth.user?.name ?? 'Teacher'}', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12), children[0], children[1], children[2]])),
                  const SizedBox(width: 16),
                  Expanded(child: ListView(children: [children[3], children[4], children[5], children[6]])),
                ],
              )
            : ListView(
                children: [
                  Text('Welcome, ${auth.user?.name ?? 'Teacher'}', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Create Announcement', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _annTitleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _annDescCtrl, decoration: const InputDecoration(labelText: 'Description')),
          TextField(controller: _targetClassCtrl, decoration: const InputDecoration(labelText: 'Target Class (or all)')),
          TextField(controller: _targetDeptCtrl, decoration: const InputDecoration(labelText: 'Target Department (or all)')),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: const [
              DropdownMenuItem(value: 'Normal', child: Text('Normal')),
              DropdownMenuItem(value: 'Important', child: Text('Important')),
              DropdownMenuItem(value: 'Urgent', child: Text('Urgent')),
            ],
            onChanged: (v) => setState(() => _priority = v ?? 'Normal'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _busy ? null : _postAnnouncement, child: const Text('Post Announcement'))
        ]),
      ),
    );
  }

  Widget _buildMessageCard(AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Send Message', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _msgTitleCtrl, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: _msgBodyCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Body')),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: const [
              DropdownMenuItem(value: 'class', child: Text('Class Notices')),
              DropdownMenuItem(value: 'department', child: Text('Department Notices')),
              DropdownMenuItem(value: 'event', child: Text('Events')),
              DropdownMenuItem(value: 'assignment', child: Text('Assignments')),
              DropdownMenuItem(value: 'deadline', child: Text('Deadlines')),
              DropdownMenuItem(value: 'general', child: Text('General Announcements')),
            ],
            onChanged: (v) => setState(() => _category = v ?? 'general'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _busy ? null : _sendMessage, child: const Text('Send Message'))
        ]),
      ),
    );
  }

  Widget _buildFilesCard(AuthProvider auth) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Notes / File Sharing', style: TextStyle(fontWeight: FontWeight.bold)),
          TextField(controller: _driveNameCtrl, decoration: const InputDecoration(labelText: 'Document name')),
          TextField(controller: _driveLinkCtrl, decoration: const InputDecoration(labelText: 'Google Drive link')),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton(onPressed: _busy ? null : _saveDriveLink, child: const Text('Save Drive Link')),
            OutlinedButton(onPressed: _busy ? null : _importClassList, child: const Text('Import Student XLSX')),
          ])
        ]),
      ),
    );
  }

  Widget _buildStudentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Students List', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _studentSearchCtrl,
                decoration: const InputDecoration(labelText: 'Search by name, class or roll no'),
                onSubmitted: (_) => _searchStudents(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _busy ? null : _searchStudents, child: const Text('Search')),
          ]),
          const SizedBox(height: 8),
          if (_students.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('No students found'),
            )
          else
            SizedBox(
              height: 260,
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, i) {
                  final s = _students[i];
                  return ListTile(
                    dense: true,
                    title: Text('${s['name'] ?? ''} (${s['roll_no'] ?? '-'})'),
                    subtitle: Text('${s['class_name'] ?? ''} • ${s['department'] ?? ''}'),
                  );
                },
              ),
            )
        ]),
      ),
    );
  }

  Future<void> _postAnnouncement() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _busy = true);
    try {
      final a = AnnouncementModel(
        id: '',
        title: _annTitleCtrl.text.trim(),
        description: _annDescCtrl.text.trim(),
        senderId: auth.user?.id ?? 'unknown',
        senderName: auth.user?.name ?? 'Teacher',
        priority: _priority,
        targetClass: _targetClassCtrl.text.trim().isEmpty ? 'all' : _targetClassCtrl.text.trim(),
        targetDepartment: _targetDeptCtrl.text.trim().isEmpty ? 'all' : _targetDeptCtrl.text.trim(),
      );
      await FirebaseService.instance.createAnnouncement(a);
      _annTitleCtrl.clear();
      _annDescCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Announcement posted')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendMessage() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _busy = true);
    try {
      final m = MessageModel(
        id: '',
        title: _msgTitleCtrl.text.trim(),
        body: _msgBodyCtrl.text.trim(),
        category: _category,
        senderId: auth.user?.id ?? 'unknown',
        senderName: auth.user?.name ?? 'Teacher',
        senderRole: auth.user?.role ?? 'teacher',
        priority: _priority,
        targetClass: _targetClassCtrl.text.trim().isEmpty ? 'all' : _targetClassCtrl.text.trim(),
        targetDepartment: _targetDeptCtrl.text.trim().isEmpty ? 'all' : _targetDeptCtrl.text.trim(),
      );
      await FirebaseService.instance.createMessage(m);

      final body = m.body.toLowerCase();
      final triggers = ['submit', 'deadline', 'assignment', 'test', 'meeting', 'tomorrow'];
      if (triggers.any((t) => body.contains(t))) {
        final task = TaskModel(
          id: '',
          title: 'Auto-task: ${m.title}',
          description: m.body,
          assignedBy: m.senderName,
          priority: m.priority,
        );
        await FirebaseService.instance.createTask(task);
      }

      _msgTitleCtrl.clear();
      _msgBodyCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveDriveLink() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (_driveLinkCtrl.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      await FirebaseService.instance.saveFileRecord(
        name: _driveNameCtrl.text.trim().isEmpty ? 'Untitled Document' : _driveNameCtrl.text.trim(),
        url: _driveLinkCtrl.text.trim(),
        uploadedBy: auth.user?.id ?? 'unknown',
        fileType: 'drive-link',
      );
      _driveNameCtrl.clear();
      _driveLinkCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Drive link saved')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _searchStudents() async {
    setState(() => _busy = true);
    try {
      final rows = await FirebaseService.instance.searchStudents(query: _studentSearchCtrl.text);
      if (mounted) setState(() => _students = rows);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importClassList() async {
    setState(() => _busy = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );
      if (result == null || result.files.isEmpty || result.files.single.bytes == null) {
        return;
      }

      final Uint8List bytes = result.files.single.bytes!;
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return;

      final rows = <Map<String, dynamic>>[];
      for (var i = 1; i < sheet.rows.length; i++) {
        final r = sheet.rows[i];
        String cell(int idx) => idx < r.length ? (r[idx]?.value?.toString() ?? '').trim() : '';

        final name = cell(0);
        if (name.isEmpty) continue;

        rows.add({
          'id': const Uuid().v4(),
          'name': name,
          'class_name': cell(1).isEmpty ? 'CSE CORE 4C' : cell(1),
          'roll_no': cell(2),
          'section': cell(3).isEmpty ? '4C' : cell(3),
          'department': cell(4).isEmpty ? 'Computer Science' : cell(4),
          'email': cell(5),
        });
      }

      await FirebaseService.instance.importStudents(rows);
      await _searchStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Imported ${rows.length} students from class list')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
