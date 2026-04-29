import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/broadcast_card.dart';
import '../widgets/shimmer_loader.dart';
import '../widgets/empty_state.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  static const _tabs = [
    AnnouncementCategory.all,
    AnnouncementCategory.department,
    AnnouncementCategory.class_,
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          color: AppTheme.surfaceCard,
          child: TabBar(
            controller: _tabCtrl,
            tabs: _tabs.map((cat) {
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cat.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(cat.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        // Tab views
        Expanded(
          child: Consumer<AnnouncementProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const ShimmerList(count: 6, cardHeight: 100);
              }
              return TabBarView(
                controller: _tabCtrl,
                children: _tabs.map((cat) {
                  final items = provider.byCategory(cat);
                  if (items.isEmpty) {
                    return EmptyState(
                      icon: Icons.campaign_outlined,
                      title: 'No messages yet',
                      subtitle:
                          'No ${cat.label.toLowerCase()} announcements posted.',
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: items.length,
                    itemBuilder: (context, i) =>
                        BroadcastCard(model: items[i]),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
