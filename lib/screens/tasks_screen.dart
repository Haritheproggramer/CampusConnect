import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/task_model.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.streamTasks(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snap.data!;
        if (rows.isEmpty) return const Center(child: Text('No tasks'));
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final t = TaskModel.fromMap(rows[i]);
            return ListTile(
              title: Text(t.title),
              subtitle: Text('${t.description}\nDue: ${t.dueDate.toLocal()}'),
            );
          },
        );
      },
    );
  }
}
