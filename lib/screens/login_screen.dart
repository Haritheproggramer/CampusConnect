import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final _className = TextEditingController();
  final _rollNo = TextEditingController();
  final _section = TextEditingController();
  final _department = TextEditingController();
  final _subject = TextEditingController();
  String _role = 'student';
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Connect')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSignUp)
                    TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full Name')),
                  if (_isSignUp)
                    TextField(controller: _department, decoration: const InputDecoration(labelText: 'Department')),
                  if (_isSignUp && _role == 'student') ...[
                    TextField(controller: _className, decoration: const InputDecoration(labelText: 'Class')),
                    TextField(controller: _rollNo, decoration: const InputDecoration(labelText: 'Roll No')),
                    TextField(controller: _section, decoration: const InputDecoration(labelText: 'Section')),
                  ],
                  if (_isSignUp && _role != 'student')
                    TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Subject')),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Text('Role:'),
                    const SizedBox(width: 8),
                    DropdownButton<String>(value: _role, items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student')),
                      DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ], onChanged: (v) => setState(() => _role = v ?? 'student'))
                  ]),
                  const SizedBox(height: 12),
                  auth.isLoading ? const CircularProgressIndicator() : ElevatedButton(
                    onPressed: () async {
                      try {
                        if (_isSignUp) {
                          await auth.signUp(
                            _email.text.trim(),
                            _password.text.trim(),
                            _name.text.trim(),
                            _role,
                            extra: {
                              'department': _department.text.trim(),
                              'className': _className.text.trim(),
                              'rollNo': _rollNo.text.trim(),
                              'section': _section.text.trim(),
                              'subject': _subject.text.trim(),
                            },
                          );
                        } else {
                          await auth.signIn(_email.text.trim(), _password.text.trim());
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    child: Text(_isSignUp ? 'Sign up' : 'Sign in'),
                  ),
                  TextButton(onPressed: () => setState(() => _isSignUp = !_isSignUp), child: Text(_isSignUp ? 'Have an account? Sign in' : 'No account? Sign up'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
