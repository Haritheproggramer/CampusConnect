import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/firebase_service.dart';
import '../models/task_model.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';
import '../utils/app_theme.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.streamTasks(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
          return const ShimmerList(count: 5, cardHeight: 80);
        }
        if (snap.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Could not load tasks',
            subtitle: snap.error.toString(),
          );
        }
        final rows = snap.data ?? [];
        if (rows.isEmpty) {
          return const EmptyState(
            icon: Icons.task_alt_rounded,
            title: 'No tasks yet',
            subtitle: 'Your upcoming tasks will appear here.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final t = TaskModel.fromMap(rows[i]);
            return _TaskCard(task: t);
          },
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final dueStr = DateFormat.MMMd().add_jm().format(task.dueDate.toLocal());
    final isOverdue = task.dueDate.isBefore(DateTime.now());
    final prioColor = task.priority.toLowerCase() == 'urgent'
        ? AppTheme.error
        : task.priority.toLowerCase() == 'important'
            ? AppTheme.warning
            : AppTheme.onSurfaceMuted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue
              ? AppTheme.error.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: prioColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
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
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.onSurfaceMuted,
                    ),
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
