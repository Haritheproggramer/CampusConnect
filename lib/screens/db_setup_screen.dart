import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../services/firebase_service.dart';

/// Shown when Supabase tables don't exist.
/// Lets user copy the schema SQL and seed demo data.
class DbSetupScreen extends StatefulWidget {
  const DbSetupScreen({super.key});

  @override
  State<DbSetupScreen> createState() => _DbSetupScreenState();
}

class _DbSetupScreenState extends State<DbSetupScreen> {
  bool _seeding = false;
  bool _seeded = false;
  String? _error;

  static const _supabaseUrl = 'https://ghivhjejmloektsbddbu.supabase.co/project/default/sql/new';

  static const _schemaSql = '''-- Run this in: Supabase Dashboard > SQL Editor > New Query
create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key,
  name text not null,
  role text not null default \'student\',
  email text not null unique,
  department text default \'\',
  class_name text default \'\',
  roll_no text default \'\',
  section text default \'\',
  subject text default \'\',
  is_cr boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.students (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  class_name text default \'\',
  roll_no text default \'\',
  section text default \'\',
  department text default \'\',
  email text default \'\',
  created_at timestamptz default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  title text not null default \'\',
  body text not null,
  category text not null default \'all\',
  sender_id text not null,
  sender_name text not null,
  sender_role text not null default \'student\',
  target_class text default \'all\',
  target_department text default \'all\',
  priority text not null default \'Normal\',
  receiver_id text,
  receiver_name text,
  timestamp timestamptz default now()
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null,
  sender_id text not null,
  sender_name text not null,
  priority text not null default \'Normal\',
  date timestamptz default now(),
  category text default \'all\',
  target_class text default \'all\',
  target_department text default \'all\'
);

create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text not null default \'\',
  due_date timestamptz default (now() + interval \'7 days\'),
  assigned_by text not null default \'\',
  priority text not null default \'Normal\',
  completed boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  url text not null,
  uploaded_by text not null,
  uploaded_at timestamptz default now(),
  file_type text default \'link\'
);

alter table public.users enable row level security;
alter table public.students enable row level security;
alter table public.messages enable row level security;
alter table public.announcements enable row level security;
alter table public.tasks enable row level security;
alter table public.files enable row level security;

drop policy if exists users_rw on public.users;
drop policy if exists students_rw on public.students;
drop policy if exists messages_rw on public.messages;
drop policy if exists announcements_rw on public.announcements;
drop policy if exists tasks_rw on public.tasks;
drop policy if exists files_rw on public.files;

create policy users_rw on public.users for all to authenticated using (true) with check (true);
create policy students_rw on public.students for all to authenticated using (true) with check (true);
create policy messages_rw on public.messages for all to authenticated using (true) with check (true);
create policy announcements_rw on public.announcements for all to authenticated using (true) with check (true);
create policy tasks_rw on public.tasks for all to authenticated using (true) with check (true);
create policy files_rw on public.files for all to authenticated using (true) with check (true);
''';

  Future<void> _seedData() async {
    setState(() { _seeding = true; _error = null; });
    try {
      await FirebaseService.instance.seedDemoData();
      if (mounted) setState(() { _seeded = true; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() => _seeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storage_rounded, color: AppTheme.warning, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'Database Setup Required',
                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  'The Supabase database tables don\'t exist yet.\nFollow the 2 steps below to set up the app.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.onSurfaceMuted),
                ),
                const SizedBox(height: 32),

                // Step 1
                _StepCard(
                  step: '1',
                  title: 'Create Tables in Supabase',
                  color: AppTheme.catAll,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Open Supabase SQL Editor and run this schema:',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceMuted),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D1A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _schemaSql.substring(0, 200) + '...',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Color(0xFF7CFC00),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.copy_rounded, size: 16),
                              label: const Text('Copy SQL'),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _schemaSql));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('SQL copied! Paste it in Supabase SQL Editor.')),
                                );
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.catAll),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.open_in_new, size: 16),
                              label: const Text('Open Supabase'),
                              onPressed: () {
                                // Try to open the URL
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text('Go to: supabase.com > Your Project > SQL Editor'),
                                    action: SnackBarAction(label: 'OK', onPressed: () {}),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Step 2
                _StepCard(
                  step: '2',
                  title: 'Seed Demo Data',
                  color: AppTheme.catClass,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'After creating tables, seed 20+ students and sample announcements/tasks.',
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.onSurfaceMuted),
                      ),
                      const SizedBox(height: 12),
                      if (_error != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.error.withAlpha(80)),
                          ),
                          child: Text(
                            _error!.contains('cache') || _error!.contains('PGRST205')
                                ? '⚠ Tables not found. Complete Step 1 first, then try again.'
                                : _error!,
                            style: GoogleFonts.inter(fontSize: 11, color: AppTheme.error),
                          ),
                        ),
                      if (_seeded)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '✅ Demo data seeded! Refresh the app to see data.',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.success),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          icon: _seeding
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.bolt_rounded, size: 16),
                          label: Text(_seeding ? 'Seeding...' : 'Seed Demo Data (20+ students)'),
                          onPressed: _seeding ? null : _seedData,
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.catClass),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final Color color;
  final Widget child;

  const _StepCard({
    required this.step,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(step, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.onSurface)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
