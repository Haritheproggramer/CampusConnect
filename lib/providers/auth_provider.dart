import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = true;

  AuthProvider() {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> _init() async {
    _loading = true;
    notifyListeners();
    _user = await FirebaseService.instance.getCurrentUserProfile();
    _loading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    notifyListeners();
    _user = await FirebaseService.instance.signInWithEmail(email: email, password: password);
    _loading = false;
    notifyListeners();
  }

  Future<void> signUp(String email, String password, String name, String role, {Map<String, dynamic>? extra}) async {
    _loading = true;
    notifyListeners();
    _user = await FirebaseService.instance.signUpWithEmail(email: email, password: password, name: name, role: role, extra: extra);
    _loading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseService.instance.signOut();
    _user = null;
    notifyListeners();
  }
}
