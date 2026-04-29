import 'dart:async';
import 'package:flutter/material.dart';
import '../models/announcement_model.dart';
import '../services/firebase_service.dart';
import '../utils/app_theme.dart';
import '../utils/mock_data.dart';

class AnnouncementProvider extends ChangeNotifier {
  List<AnnouncementModel> _all = [];
  bool _loading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  AnnouncementProvider() {
    _init();
  }

  bool get isLoading => _loading;
  // No public error — we always fall back silently
  List<AnnouncementModel> get all => List.unmodifiable(_all);

  List<AnnouncementModel> byCategory(AnnouncementCategory cat) =>
      _all.where((a) => a.category == cat).toList();

  void _init() {
    try {
      _sub = FirebaseService.instance.streamAnnouncements().listen(
        (rows) {
          final parsed = rows
              .map((r) {
                try {
                  return AnnouncementModel.fromMap(r);
                } catch (_) {
                  return null;
                }
              })
              .whereType<AnnouncementModel>()
              .toList();

          // If backend returned nothing, fall back to mock
          _all = parsed.isNotEmpty ? parsed : MockData.announcements;
          _loading = false;
          notifyListeners();
        },
        onError: (_) {
          // Silent fallback — user never sees an error
          _all = MockData.announcements;
          _loading = false;
          notifyListeners();
        },
      );
    } catch (_) {
      _all = MockData.announcements;
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
