import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/announcement_model.dart';
import '../models/message_model.dart';
import '../utils/app_theme.dart';

/// Clean announcement broadcast card:
/// Title + Category chip + Sender + Timestamp. NO body preview.
class BroadcastCard extends StatelessWidget {
  final AnnouncementModel model;
  final VoidCallback? onTap;

  const BroadcastCard({super.key, required this.model, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cat = model.category;
    final timeStr = _formatTime(model.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: cat.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _CategoryChip(category: cat),
                const Spacer(),
                Text(
                  timeStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              model.title,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 13, color: AppTheme.onSurfaceMuted),
                const SizedBox(width: 4),
                Text(
                  model.senderName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                if (model.priority != 'Normal') ...[
                  const SizedBox(width: 10),
                  _PriorityDot(priority: model.priority),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.MMMd().format(dt);
  }
}

class _CategoryChip extends StatelessWidget {
  final AnnouncementCategory category;
  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            category.label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: category.color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final String priority;
  const _PriorityDot({required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = priority.toLowerCase() == 'urgent'
        ? AppTheme.error
        : AppTheme.warning;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          priority,
          style: GoogleFonts.inter(fontSize: 11, color: color),
        ),
      ],
    );
  }
}

// ── Legacy MessageCard (kept for any existing usages) ─────────────────────────

class MessageCard extends StatelessWidget {
  final MessageModel model;
  const MessageCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat.jm().format(model.timestamp);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${model.senderName} · $timeStr',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          if (model.priority != 'Normal')
            _badge(model.priority),
        ],
      ),
    );
  }

  Widget _badge(String p) {
    final color =
        p.toLowerCase() == 'urgent' ? AppTheme.error : AppTheme.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        p,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
