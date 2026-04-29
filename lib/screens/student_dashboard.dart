import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_card.dart';
import '../services/firebase_service.dart';
import '../models/message_model.dart';
import '../models/task_model.dart';
import '../models/announcement_model.dart';
import 'messages_screen.dart';
import 'tasks_screen.dart';
import 'announcements_screen.dart';
import 'profile_screen.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final pages = [
      _home(auth),
      MessagesScreen(),
      TasksScreen(),
      AnnouncementsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Connect')),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.message), label: Text('Messages')),
                    NavigationRailDestination(icon: Icon(Icons.task), label: Text('Tasks')),
                    NavigationRailDestination(icon: Icon(Icons.announcement), label: Text('Announcements')),
                    NavigationRailDestination(icon: Icon(Icons.person), label: Text('Profile')),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: pages[_index]),
              ],
            )
          : pages[_index],
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
                BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
                BottomNavigationBarItem(icon: Icon(Icons.announcement), label: 'Announcements'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            ),
    );
  }

  Widget _home(AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Hello, ${auth.user?.name ?? 'Student'}', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Important messages', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService.instance.streamMessages(),
          builder: (context, snap) {
            if (!snap.hasData) return const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            final rows = snap.data!
                .where((r) => (r['priority'] == 'Important' || r['priority'] == 'Urgent'))
                .take(3)
                .toList();
            if (rows.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No important messages')));
            return Column(children: rows.map((r) => MessageCard(model: MessageModel.fromMap(r))).toList());
          },
        ),
        const SizedBox(height: 12),
        const Text('Upcoming tasks/deadlines', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService.instance.streamTasks(),
          builder: (context, snap) {
            if (!snap.hasData) return const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            final rows = snap.data!.take(3).toList();
            if (rows.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No upcoming tasks')));
            return Card(
              child: Column(
                children: rows.map((r) {
                  final t = TaskModel.fromMap(r);
                  return ListTile(
                    title: Text(t.title),
                    subtitle: Text('Due: ${t.dueDate.toLocal()} • ${t.priority}'),
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text('Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService.instance.streamAnnouncements(),
          builder: (context, snap) {
            if (!snap.hasData) return const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            final rows = snap.data!.take(3).toList();
            if (rows.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No announcements')));
            return Card(
              child: Column(
                children: rows.map((r) {
                  final a = AnnouncementModel.fromMap(r);
                  return ListTile(
                    title: Text(a.title),
                    subtitle: Text('${a.description}\n${a.priority} • ${a.senderName}'),
                    isThreeLine: true,
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text('Notes and files', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: FirebaseService.instance.db
              .from('files')
              .select()
              .limit(10)
              .then((value) => List<Map<String, dynamic>>.from(value)),
          builder: (context, snap) {
            if (!snap.hasData) return const Card(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
            final rows = snap.data!;
            if (rows.isEmpty) return const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('No shared files yet')));
            return Card(
              child: Column(
                children: rows.map((r) {
                  final url = (r['url'] ?? '').toString();
                  return ListTile(
                    title: Text((r['name'] ?? 'File').toString()),
                    subtitle: Text(url),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      final uri = Uri.tryParse(url);
                      if (uri != null) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}
