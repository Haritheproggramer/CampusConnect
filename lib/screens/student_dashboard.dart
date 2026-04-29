import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/broadcast_card.dart';
import '../widgets/empty_state.dart';
import '../utils/app_theme.dart';
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

  static const _navItems = [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: 'Messages'),
    NavigationDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign_rounded), label: 'Board'),
    NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt_rounded), label: 'Tasks'),
    NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final pages = [
      _HomeTab(auth: auth),
      const MessagesScreen(),
      const AnnouncementsScreen(),
      const TasksScreen(),
      const ProfileScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              minWidth: 80,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: Text('Home')),
                NavigationRailDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people_rounded), label: Text('Messages')),
                NavigationRailDestination(icon: Icon(Icons.campaign_outlined), selectedIcon: Icon(Icons.campaign_rounded), label: Text('Board')),
                NavigationRailDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt_rounded), label: Text('Tasks')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person_rounded), label: Text('Profile')),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(
              child: Column(
                children: [
                  _AppHeader(name: auth.user?.name ?? 'Student'),
                  Expanded(child: pages[_index]),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: _AppHeader(name: auth.user?.name ?? 'Student'),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _navItems,
        height: 64,
        elevation: 0,
        backgroundColor: AppTheme.surfaceCard,
        animationDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  const _AppHeader({required this.name});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.school_rounded,
                color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            'Campus Connect',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<AnnouncementProvider>(
          builder: (_, p, __) {
            if (p.isLoading) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Hi, ${name.split(' ').first} 👋',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.onSurfaceMuted,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  final AuthProvider auth;
  const _HomeTab({required this.auth});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 32),
      children: [
        // Greeting card
        _GreetingCard(user: auth.user),
        const SizedBox(height: 8),
        // Stats row
        _StatsRow(),
        const SizedBox(height: 20),
        _SectionHeader('Recent Announcements'),
        const SizedBox(height: 4),
        Consumer<AnnouncementProvider>(
          builder: (_, provider, __) {
            if (provider.isLoading) {
              return const ShimmerList(count: 3, cardHeight: 100);
            }
            final items = provider.all.take(3).toList();
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.campaign_outlined,
                title: 'No announcements yet',
              );
            }
            return Column(
              children: items.map((a) => BroadcastCard(model: a)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final dynamic user;
  const _GreetingCard({this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF9C8DFF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  user?.name ?? 'Student',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if ((user?.className ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${user!.className}  ·  Roll No: ${user!.rollNo}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (_, provider, __) {
        final total = provider.all.length;
        final dept = provider.byCategory(AnnouncementCategory.department).length;
        final cls = provider.byCategory(AnnouncementCategory.class_).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _StatChip(label: 'All', value: total, color: AppTheme.catAll),
              const SizedBox(width: 10),
              _StatChip(label: 'Dept', value: dept, color: AppTheme.catDept),
              const SizedBox(width: 10),
              _StatChip(label: 'Class', value: cls, color: AppTheme.catClass),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.onSurfaceMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
    );
  }
}
