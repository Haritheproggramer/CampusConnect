import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/announcement_model.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _classFilter = 'all';
  String _deptFilter = 'all';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _classFilter,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Classes')),
                    DropdownMenuItem(value: 'CSE CORE 4C', child: Text('CSE CORE 4C')),
                  ],
                  onChanged: (v) => setState(() => _classFilter = v ?? 'all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _deptFilter,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Departments')),
                    DropdownMenuItem(value: 'Computer Science', child: Text('Computer Science')),
                  ],
                  onChanged: (v) => setState(() => _deptFilter = v ?? 'all'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: FirebaseService.instance.streamAnnouncements(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final rows = snap.data!;
              final filtered = rows.where((r) {
                final tc = r['target_class'] ?? 'all';
                final td = r['target_department'] ?? 'all';
                final classOk = _classFilter == 'all' || tc == 'all' || tc == _classFilter;
                final deptOk = _deptFilter == 'all' || td == 'all' || td == _deptFilter;
                return classOk && deptOk;
              }).toList();

              if (filtered.isEmpty) return const Center(child: Text('No announcements'));
        return ListView.builder(
                itemCount: filtered.length,
          itemBuilder: (context, i) {
                  final a = AnnouncementModel.fromMap(filtered[i]);
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(a.title),
                subtitle: Text('${a.description}\nBy ${a.senderName} • ${a.priority}'),
                isThreeLine: true,
              ),
            );
          },
        );
      },
          ),
        )
      ],
    );
  }
}
