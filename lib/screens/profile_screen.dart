import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final u = auth.user;
    if (u == null) return const Center(child: Text('Not logged in'));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(u.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text('Role: ${u.role}'),
        Text('Email: ${u.email}'),
        Text('Department: ${u.department}'),
        if (u.role == 'student') ...[
          Text('Class: ${u.className}'),
          Text('Roll No: ${u.rollNo}'),
          Text('Section: ${u.section}'),
        ] else ...[
          Text('Subject: ${u.subject}'),
        ],
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () async { await auth.signOut(); }, child: const Text('Logout'))
      ]),
    );
  }
}
