import 'dart:async';
import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../services/firebase_service.dart';

class MessageProvider extends ChangeNotifier {
  List<MessageModel> _broadcasts = [];
  final Set<String> _readIds = {};
  bool _loading = true;
  String? _error;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  MessageProvider() {
    _init();
  }

  bool get isLoading => _loading;
  String? get error => _error;
  List<MessageModel> get broadcasts => List.unmodifiable(_broadcasts);

  int get unreadCount =>
      _broadcasts.where((m) => !_readIds.contains(m.id)).length;

  bool isRead(String id) => _readIds.contains(id);

  void markRead(String id) {
    if (_readIds.add(id)) notifyListeners();
  }

  void _init() {
    _sub = FirebaseService.instance.streamBroadcasts().listen(
      (rows) {
        _broadcasts = rows
            .where((r) =>
                r['receiver_id'] == null ||
                (r['receiver_id'] as String?)!.isEmpty)
            .map((r) => MessageModel.fromMap(r))
            .toList();
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
