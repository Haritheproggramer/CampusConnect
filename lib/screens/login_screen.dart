import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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
  bool _obscure = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 800;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),
          // Decorative blobs
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(color: const Color(0xFF6C63FF), size: 300),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _Blob(color: const Color(0xFF42A5F5), size: 250),
          ),
          // Content
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: isWide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildBranding(),
                            const SizedBox(width: 60),
                            _buildCard(auth),
                          ],
                        )
                      : Column(
                          children: [
                            _buildBranding(),
                            const SizedBox(height: 32),
                            _buildCard(auth),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.school_rounded,
              color: Color(0xFF6C63FF), size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Campus\nConnect',
          style: GoogleFonts.inter(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your college. Smarter.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white60,
          ),
        ),
        const SizedBox(height: 24),
        _featureRow(Icons.campaign_rounded, 'Instant announcements'),
        const SizedBox(height: 8),
        _featureRow(Icons.message_rounded, 'Direct messaging'),
        const SizedBox(height: 8),
        _featureRow(Icons.shield_rounded, 'Role-based access'),
      ],
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildCard(AuthProvider auth) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isSignUp ? 'Create Account' : 'Welcome back',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isSignUp
                    ? 'Join your campus community'
                    : 'Sign in to continue',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 24),

              if (auth.error != null)
                _errorBanner(auth.error!),

              if (_isSignUp) ...[
                _field(_name, 'Full Name', Icons.person_outline),
                const SizedBox(height: 12),
                _field(_department, 'Department', Icons.business_outlined),
                const SizedBox(height: 12),
                if (_role == 'student') ...[
                  _field(_className, 'Class (e.g. CSE 2nd Year)',
                      Icons.class_outlined),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _field(_rollNo, 'Roll No',
                              Icons.format_list_numbered)),
                      const SizedBox(width: 12),
                      Expanded(
                          child:
                              _field(_section, 'Section', Icons.grid_view_rounded)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  _field(_subject, 'Subject', Icons.menu_book_rounded),
                  const SizedBox(height: 12),
                ],
              ],

              _field(_email, 'Email', Icons.email_outlined,
                  type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _passwordField(),
              const SizedBox(height: 16),

              if (_isSignUp) _roleSelector(),
              const SizedBox(height: 20),

              auth.isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF6C63FF)),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _submit,
                      child: Text(
                        _isSignUp ? 'Create Account' : 'Sign In',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  auth.clearError();
                  setState(() => _isSignUp = !_isSignUp);
                  _animCtrl
                    ..reset()
                    ..forward();
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign in'
                      : 'No account? Sign up',
                  style: GoogleFonts.inter(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: GoogleFonts.inter(color: Colors.red.shade300, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _password,
      obscureText: _obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
        suffixIcon: IconButton(
          icon: Icon(
            _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.white38,
            size: 18,
          ),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _roleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I am a...',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white54),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final r in ['student', 'teacher', 'admin'])
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _role = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _role == r
                          ? const Color(0xFF6C63FF)
                          : Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _role == r
                            ? const Color(0xFF6C63FF)
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Text(
                      r[0].toUpperCase() + r.substring(1),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _role == r ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.08),
      ),
    );
  }
}
