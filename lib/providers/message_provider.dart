import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firebase_service.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageModel> _broadcasts = [];
  final Set<String> _readIds = {};
  bool _loading = true;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  MessageProvider() {
    _init();
  }

  bool get isLoading => _loading;
  List<MessageModel> get broadcasts => List.unmodifiable(_broadcasts);
  int get unreadCount => _broadcasts.where((m) => !_readIds.contains(m.id)).length;
  bool isRead(String id) => _readIds.contains(id);

  void markRead(String id) {
    if (_readIds.add(id)) notifyListeners();
  }

  void _init() {
    try {
      _sub = FirebaseService.instance.streamBroadcasts().listen(
        (rows) {
          _broadcasts = rows
              .where((r) {
                final rid = r['receiver_id'];
                return rid == null || (rid as String).isEmpty;
              })
              .map((r) {
                try {
                  return MessageModel.fromMap(r);
                } catch (_) {
                  return null;
                }
              })
              .whereType<MessageModel>()
              .toList();
          _loading = false;
          notifyListeners();
        },
        onError: (_) {
          // Silent — app continues normally
          _loading = false;
          notifyListeners();
        },
      );
    } catch (_) {
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
