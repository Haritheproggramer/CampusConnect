import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = true;
  String? _error;

  AuthProvider() {
    _init();
  }

  AppUser? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _init() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await FirebaseService.instance.getCurrentUserProfile();
    } catch (e) {
      _user = null;
      _error = 'Backend not ready. Please run Supabase schema.sql and retry.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await FirebaseService.instance.signInWithEmail(email: email, password: password);
    } catch (e) {
      _user = null;
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String name, String role, {Map<String, dynamic>? extra}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _user = await FirebaseService.instance.signUpWithEmail(email: email, password: password, name: name, role: role, extra: extra);
    } catch (e) {
      _user = null;
      _error = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await FirebaseService.instance.signOut();
    _user = null;
    notifyListeners();
  }
}
