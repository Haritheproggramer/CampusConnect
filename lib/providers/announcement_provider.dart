import 'dart:async';
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementModel> _all = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  AnnouncementProvider() {
    _init();
  }

  bool get isLoading => _loading;
  String? get error => _error;

  List<AnnouncementModel> byCategory(AnnouncementCategory cat) {
    return _all
        .where((a) => a.category == cat)
        .toList();
  }

  List<AnnouncementModel> get all => List.unmodifiable(_all);

  void _init() {
    _sub = FirebaseService.instance.streamAnnouncements().listen(
      (rows) {
        _all = rows.map((r) => AnnouncementModel.fromMap(r)).toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
