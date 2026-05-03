import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

// Public export so other screens can reference today's schedule


class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = _dayName(now.weekday);

    return DefaultTabController(
      length: 5,
      initialIndex: _dayIndex(now.weekday),
      child: Column(
        children: [
          // Tab bar - days
          Container(
            color: AppTheme.surfaceCard,
            child: TabBar(
              isScrollable: true,
              tabs: _days.map((d) => Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (d == today)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: AppTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(d),
                  ],
                ),
              )).toList(),
            ),
          ),
          // Day schedules
          Expanded(
            child: TabBarView(
              children: _days.map((day) => _DaySchedule(
                day: day,
                slots: kCseSchedule[day] ?? [],
                isToday: day == today,
                now: now,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  String _dayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      default: return 'Mon';
    }
  }

  int _dayIndex(int weekday) {
    if (weekday >= 1 && weekday <= 5) return weekday - 1;
    return 0;
  }
}

class _DaySchedule extends StatelessWidget {
  final String day;
  final List<TimetableSlot> slots;
  final bool isToday;
  final DateTime now;

  const _DaySchedule({
    required this.day,
    required this.slots,
    required this.isToday,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const Center(
        child: Text('No classes scheduled', style: TextStyle(color: AppTheme.onSurfaceMuted)),
      );
    }

    TimetableSlot? currentSlot;
    TimetableSlot? nextSlot;

    if (isToday) {
      final nowMins = now.hour * 60 + now.minute;
      for (final s in slots) {
        if (s.startMins <= nowMins && nowMins < s.endMins) {
          currentSlot = s;
        }
      }
      for (final s in slots) {
        if (s.startMins > nowMins) {
          nextSlot = s;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (isToday && currentSlot != null) _StatusBanner(
          label: '🟢 Now in Progress',
          slot: currentSlot,
          color: AppTheme.success,
        ),
        if (isToday && nextSlot != null) _StatusBanner(
          label: '⏭ Next Class',
          slot: nextSlot,
          color: AppTheme.catAll,
        ),
        if (isToday && (currentSlot != null || nextSlot != null))
          const SizedBox(height: 16),
        ...slots.map((s) => _SlotCard(
          slot: s,
          isCurrent: isToday && s == currentSlot,
          isPast: isToday && s.endMins <= (now.hour * 60 + now.minute),
        )),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String label;
  final TimetableSlot slot;
  final Color color;

  const _StatusBanner({required this.label, required this.slot, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                slot.subject,
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                slot.timeRange,
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceMuted),
              ),
              if (slot.room.isNotEmpty)
                Text(
                  slot.room,
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.onSurfaceMuted),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  final TimetableSlot slot;
  final bool isCurrent;
  final bool isPast;

  const _SlotCard({required this.slot, required this.isCurrent, required this.isPast});

  @override
  Widget build(BuildContext context) {
    final color = slot.color;
    final opacity = isPast && !isCurrent ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isCurrent ? color.withAlpha(30) : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrent ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            // Color bar
            Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Time
            SizedBox(
              width: 72,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.startTime,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  Text(
                    slot.endTime,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(width: 1, height: 40, color: AppTheme.surfaceCardLight),
            const SizedBox(width: 14),
            // Subject info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (slot.isBreak)
                    Text(
                      slot.subject,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.onSurfaceMuted,
                      ),
                    )
                  else ...[
                    Text(
                      slot.subject,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isCurrent ? Colors.white : AppTheme.onSurface,
                      ),
                    ),
                    if (slot.teacher.isNotEmpty)
                      Text(
                        slot.teacher,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                  ],
                ],
              ),
            ),
            // Room badge
            if (slot.room.isNotEmpty && !slot.isBreak)
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  slot.room,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TimetableSlot {
  final String startTime;
  final String endTime;
  final String subject;
  final String teacher;
  final String room;
  final Color color;
  final bool isBreak;

  const TimetableSlot({
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.teacher = '',
    this.room = '',
    this.color = AppTheme.catAll,
    this.isBreak = false,
  });

  String get timeRange => '$startTime – $endTime';

  int get startMins {
    final parts = startTime.split(':');
    var h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1].replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    if (startTime.contains('PM') && h != 12) h += 12;
    if (startTime.contains('AM') && h == 12) h = 0;
    return h * 60 + m;
  }

  int get endMins {
    final parts = endTime.split(':');
    var h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1].replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
    if (endTime.contains('PM') && h != 12) h += 12;
    if (endTime.contains('AM') && h == 12) h = 0;
    return h * 60 + m;
  }
}

// CSE 4C Timetable — public so other screens can reference it
const kCseSchedule = {
  'Mon': [
    TimetableSlot(startTime: '8:10 AM', endTime: '9:05 AM', subject: 'Computer Networks', teacher: 'Dr. Sharma', room: 'LT-1', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '9:05 AM', endTime: '10:00 AM', subject: 'Machine Learning', teacher: 'Dr. Priya R.', room: 'LT-1', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '10:00 AM', endTime: '10:50 AM', subject: 'Software Engineering', teacher: 'Prof. Mehta', room: 'LT-1', color: Color(0xFF66BB6A)),
    TimetableSlot(startTime: '10:50 AM', endTime: '11:10 AM', subject: 'Tea Break ☕', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '11:10 AM', endTime: '12:05 PM', subject: 'Digital Electronics', teacher: 'Prof. Singh', room: 'LT-2', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '12:05 PM', endTime: '1:00 PM', subject: 'Artificial Intelligence', teacher: 'Dr. Verma', room: 'LT-2', color: Color(0xFFFF6B6B)),
    TimetableSlot(startTime: '1:00 PM', endTime: '1:45 PM', subject: 'Lunch Break 🍱', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '1:45 PM', endTime: '3:30 PM', subject: 'Mobile App Lab', teacher: 'Prof. Kumar', room: 'Lab-3', color: Color(0xFFAB47BC)),
    TimetableSlot(startTime: '3:30 PM', endTime: '5:20 PM', subject: 'AI & ML Lab', teacher: 'Dr. Priya R.', room: 'Lab-2', color: Color(0xFF26C6DA)),
  ],
  'Tue': [
    TimetableSlot(startTime: '8:10 AM', endTime: '9:05 AM', subject: 'Machine Learning', teacher: 'Dr. Priya R.', room: 'LT-3', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '9:05 AM', endTime: '10:00 AM', subject: 'Software Engineering', teacher: 'Prof. Mehta', room: 'LT-3', color: Color(0xFF66BB6A)),
    TimetableSlot(startTime: '10:00 AM', endTime: '10:50 AM', subject: 'Digital Electronics', teacher: 'Prof. Singh', room: 'LT-3', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '10:50 AM', endTime: '11:10 AM', subject: 'Tea Break ☕', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '11:10 AM', endTime: '12:05 PM', subject: 'Computer Networks', teacher: 'Dr. Sharma', room: 'LT-2', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '12:05 PM', endTime: '1:00 PM', subject: 'Artificial Intelligence', teacher: 'Dr. Verma', room: 'LT-2', color: Color(0xFFFF6B6B)),
    TimetableSlot(startTime: '1:00 PM', endTime: '1:45 PM', subject: 'Lunch Break 🍱', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '1:45 PM', endTime: '3:30 PM', subject: 'CN Lab', teacher: 'Dr. Sharma', room: 'Lab-1', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '3:30 PM', endTime: '5:20 PM', subject: 'SE Lab', teacher: 'Prof. Mehta', room: 'Lab-4', color: Color(0xFF66BB6A)),
  ],
  'Wed': [
    TimetableSlot(startTime: '8:10 AM', endTime: '9:05 AM', subject: 'Artificial Intelligence', teacher: 'Dr. Verma', room: 'LT-1', color: Color(0xFFFF6B6B)),
    TimetableSlot(startTime: '9:05 AM', endTime: '10:00 AM', subject: 'Computer Networks', teacher: 'Dr. Sharma', room: 'LT-1', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '10:00 AM', endTime: '10:50 AM', subject: 'Machine Learning', teacher: 'Dr. Priya R.', room: 'LT-1', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '10:50 AM', endTime: '11:10 AM', subject: 'Tea Break ☕', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '11:10 AM', endTime: '12:05 PM', subject: 'Software Engineering', teacher: 'Prof. Mehta', room: 'LT-3', color: Color(0xFF66BB6A)),
    TimetableSlot(startTime: '12:05 PM', endTime: '1:00 PM', subject: 'Digital Electronics', teacher: 'Prof. Singh', room: 'LT-3', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '1:00 PM', endTime: '1:45 PM', subject: 'Lunch Break 🍱', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '1:45 PM', endTime: '3:30 PM', subject: 'Digital Electronics Lab', teacher: 'Prof. Singh', room: 'Lab-5', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '3:30 PM', endTime: '5:20 PM', subject: 'Library / Self Study', isBreak: true, color: Color(0xFF9090A8)),
  ],
  'Thu': [
    TimetableSlot(startTime: '8:10 AM', endTime: '9:05 AM', subject: 'Digital Electronics', teacher: 'Prof. Singh', room: 'LT-2', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '9:05 AM', endTime: '10:00 AM', subject: 'Artificial Intelligence', teacher: 'Dr. Verma', room: 'LT-2', color: Color(0xFFFF6B6B)),
    TimetableSlot(startTime: '10:00 AM', endTime: '10:50 AM', subject: 'Computer Networks', teacher: 'Dr. Sharma', room: 'LT-2', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '10:50 AM', endTime: '11:10 AM', subject: 'Tea Break ☕', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '11:10 AM', endTime: '12:05 PM', subject: 'Machine Learning', teacher: 'Dr. Priya R.', room: 'LT-4', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '12:05 PM', endTime: '1:00 PM', subject: 'Software Engineering', teacher: 'Prof. Mehta', room: 'LT-4', color: Color(0xFF66BB6A)),
    TimetableSlot(startTime: '1:00 PM', endTime: '1:45 PM', subject: 'Lunch Break 🍱', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '1:45 PM', endTime: '3:30 PM', subject: 'ML Lab', teacher: 'Dr. Priya R.', room: 'Lab-2', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '3:30 PM', endTime: '5:20 PM', subject: 'Mobile App Lab', teacher: 'Prof. Kumar', room: 'Lab-3', color: Color(0xFFAB47BC)),
  ],
  'Fri': [
    TimetableSlot(startTime: '8:10 AM', endTime: '9:05 AM', subject: 'Software Engineering', teacher: 'Prof. Mehta', room: 'LT-1', color: Color(0xFF66BB6A)),
    TimetableSlot(startTime: '9:05 AM', endTime: '10:00 AM', subject: 'Digital Electronics', teacher: 'Prof. Singh', room: 'LT-1', color: Color(0xFFFFA726)),
    TimetableSlot(startTime: '10:00 AM', endTime: '10:50 AM', subject: 'Artificial Intelligence', teacher: 'Dr. Verma', room: 'LT-1', color: Color(0xFFFF6B6B)),
    TimetableSlot(startTime: '10:50 AM', endTime: '11:10 AM', subject: 'Tea Break ☕', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '11:10 AM', endTime: '12:05 PM', subject: 'Computer Networks', teacher: 'Dr. Sharma', room: 'LT-3', color: Color(0xFF6C63FF)),
    TimetableSlot(startTime: '12:05 PM', endTime: '1:00 PM', subject: 'Machine Learning', teacher: 'Dr. Priya R.', room: 'LT-3', color: Color(0xFF42A5F5)),
    TimetableSlot(startTime: '1:00 PM', endTime: '1:45 PM', subject: 'Lunch Break 🍱', isBreak: true, color: Color(0xFF9090A8)),
    TimetableSlot(startTime: '1:45 PM', endTime: '3:30 PM', subject: 'Seminar / Guest Lecture', teacher: 'TBA', room: 'Seminar Hall', color: Color(0xFF26C6DA)),
    TimetableSlot(startTime: '3:30 PM', endTime: '5:20 PM', subject: 'AI & ML Lab', teacher: 'Dr. Priya R.', room: 'Lab-2', color: Color(0xFF26C6DA)),
  ],
};

/// Multi-class timetable registry.
///
/// Structure: classLabel → day → List<TimetableSlot>
/// Add future class timetables here. null = "Timetable not added yet".
/// Do NOT add fake data for classes without real timetables.
/// Class labels must match SectionRosterData.allClassLabels.
const Map<String, Map<String, List<TimetableSlot>>?> kAllTimetables = {
  'CSE Core C': kCseSchedule, // ← active real data
  'CSE Core A': null,         // coming soon
  'CSE Core B': null,         // coming soon
  'CSE Core D': null,         // coming soon
  'AIML A':    null,          // coming soon
  'AIML B':    null,          // coming soon
};
