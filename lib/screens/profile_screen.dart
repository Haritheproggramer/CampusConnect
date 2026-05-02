import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';
import 'timetable_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Consumer2<MessageProvider, AnnouncementProvider>(
      builder: (context, messages, announcements, _) {
        final stats = [
          _ProfileStat(
            label: 'Unread Messages',
            value: messages.unreadCount.toString(),
            icon: Icons.mark_chat_unread_outlined,
          ),
          _ProfileStat(
            label: 'Pending Tasks',
            value: MockData.tasks.where((task) => !task.completed).length.toString(),
            icon: Icons.task_alt_outlined,
          ),
          _ProfileStat(
            label: 'Today\'s Classes',
            value: _todayClassCount().toString(),
            icon: Icons.calendar_today_outlined,
          ),
          _ProfileStat(
            label: 'Announcements',
            value: announcements.all.length.toString(),
            icon: Icons.campaign_outlined,
          ),
        ];

        final details = [
          _InfoItem(label: 'Name', value: user?.name ?? '—', icon: Icons.badge_outlined),
          _InfoItem(label: 'Class', value: user?.className.isNotEmpty == true ? user!.className : '—', icon: Icons.class_outlined),
          _InfoItem(label: 'Roll No', value: user?.rollNo.isNotEmpty == true ? user!.rollNo : '—', icon: Icons.numbers_outlined),
          _InfoItem(label: 'Department', value: user?.department.isNotEmpty == true ? user!.department : '—', icon: Icons.apartment_outlined),
          _InfoItem(label: 'Section', value: user?.section.isNotEmpty == true ? user!.section : '—', icon: Icons.grid_view_rounded),
          _InfoItem(label: 'Email', value: user?.email.isNotEmpty == true ? user!.email : '—', icon: Icons.email_outlined),
          _InfoItem(label: 'CR status', value: user?.isCR == true ? 'Class Representative' : 'Not CR', icon: Icons.verified_outlined),
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _HeaderCard(user: user),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 4 : constraints.maxWidth >= 650 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 3.8 : 2.5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats
                      .map((stat) => _StatCard(stat: stat))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              'Profile Details',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 900 ? 2 : 1;
                return GridView.count(
                  crossAxisCount: columns,
                  childAspectRatio: columns == 1 ? 4.4 : 3.1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: details
                      .map((item) => _InfoCard(item: item))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => auth.signOut(),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.error,
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        );
      },
    );
  }

  int _todayClassCount() {
    final now = DateTime.now();
    final day = _dayKey(now.weekday);
    if (day == null) return 0;
    return (kCseSchedule[day] ?? []).where((slot) => !slot.isBreak).length;
  }

  String? _dayKey(int weekday) {
    const days = {1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri'};
    return days[weekday];
  }
}

class _HeaderCard extends StatelessWidget {
  final dynamic user;

  const _HeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final initials = user?.name?.toString().isNotEmpty == true
        ? user!.name
            .trim()
            .split(' ')
            .map((part) => part.isNotEmpty ? part[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primary.withValues(alpha: 0.16),
            child: Text(
              initials,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Student',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  [user?.className, user?.rollNo].where((value) => value != null && value.toString().isNotEmpty).map((value) => value.toString()).join(' · '),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _Badge(label: (user?.role ?? 'student').toUpperCase()),
                    if (user?.department?.toString().isNotEmpty == true)
                      _Badge(label: user!.department),
                    if (user?.isCR == true) _Badge(label: 'CR'),
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

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _ProfileStat {
  final String label;
  final String value;
  final IconData icon;

  _ProfileStat({required this.label, required this.value, required this.icon});
}

class _StatCard extends StatelessWidget {
  final _ProfileStat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(stat.icon, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stat.value,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  stat.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  final IconData icon;

  _InfoItem({required this.label, required this.value, required this.icon});
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;

  const _InfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.surfaceCardLight.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18, color: AppTheme.onSurfaceMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
