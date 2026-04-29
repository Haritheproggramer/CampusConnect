import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firebase_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/teacher_dashboard.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.init();
  runApp(const CampusConnectApp());
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        return MaterialApp(
          title: 'Campus Connect',
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          home: _homeFor(auth),
        );
      }),
    );
  }

  Widget _homeFor(AuthProvider auth) {
    if (auth.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (!auth.isLoggedIn) return const LoginScreen();
    if (auth.user?.role == 'teacher' || auth.user?.role == 'admin') {
      return TeacherDashboard();
    }
    return StudentDashboard();
  }
}
