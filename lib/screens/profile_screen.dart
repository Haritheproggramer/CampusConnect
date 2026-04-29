import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Avatar card
        Center(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name
                            .trim()
                            .split(' ')
                            .map((e) => e[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                        : '?',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user?.name ?? '—',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _roleBadge(user?.role ?? 'student'),
                  if (user?.isCR == true) ...[
                    const SizedBox(width: 8),
                    _crBadge(),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Info card
        _InfoCard(user: user),
        const SizedBox(height: 20),
        // Sign out
        OutlinedButton.icon(
          onPressed: () => auth.signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.error,
            side: const BorderSide(color: AppTheme.error),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _roleBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        role.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _crBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.catClass.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'CR',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.catClass,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final dynamic user;
  const _InfoCard({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if ((user?.email ?? '').isNotEmpty)
            _Row(Icons.email_outlined, 'Email', user!.email),
          if ((user?.department ?? '').isNotEmpty) ...[
            _Divider(),
            _Row(Icons.business_outlined, 'Department', user!.department),
          ],
          if ((user?.className ?? '').isNotEmpty) ...[
            _Divider(),
            _Row(Icons.class_outlined, 'Class', user!.className),
          ],
          if ((user?.rollNo ?? '').isNotEmpty) ...[
            _Divider(),
            _Row(Icons.format_list_numbered, 'Roll No', user!.rollNo),
          ],
          if ((user?.section ?? '').isNotEmpty) ...[
            _Divider(),
            _Row(Icons.grid_view_rounded, 'Section', user!.section),
          ],
          if ((user?.subject ?? '').isNotEmpty) ...[
            _Divider(),
            _Row(Icons.menu_book_rounded, 'Subject', user!.subject),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.onSurfaceMuted, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: Color(0xFF3A3A52));
}
