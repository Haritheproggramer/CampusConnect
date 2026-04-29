import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firebase_service.dart';
import '../widgets/shimmer_loader.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _safeStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const ShimmerList(count: 5, cardHeight: 80);
        }

        List<TaskModel> tasks;
        if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
          tasks = MockData.tasks;
        } else {
          try {
            tasks = snap.data!.map((r) => TaskModel.fromMap(r)).toList();
            if (tasks.isEmpty) tasks = MockData.tasks;
          } catch (_) {
            tasks = MockData.tasks;
          }
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: tasks.length,
          itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
        );
      },
    );
  }

  Stream<List<Map<String, dynamic>>> _safeStream() {
    try {
      return FirebaseService.instance.streamTasks();
    } catch (_) {
      return Stream.value([]);
    }
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final dueStr = DateFormat.MMMd().add_jm().format(task.dueDate.toLocal());
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.completed;
    final prioColor = task.priority.toLowerCase() == 'urgent'
        ? AppTheme.error
        : task.priority.toLowerCase() == 'important'
            ? AppTheme.warning
            : AppTheme.catDept;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? AppTheme.error.withAlpha(60) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Priority bar
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: prioColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.description,
                      style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: isOverdue ? AppTheme.error : AppTheme.onSurfaceMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOverdue ? 'Overdue · $dueStr' : dueStr,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: isOverdue ? AppTheme.error : AppTheme.onSurfaceMuted,
                          fontWeight: isOverdue ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: prioColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: prioColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
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
