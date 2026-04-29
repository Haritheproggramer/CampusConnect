import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/message_model.dart';
import '../widgets/message_card.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseService.instance.streamMessages(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final rows = snap.data!;
        if (rows.isEmpty) return const Center(child: Text('No messages'));
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, i) {
            final m = MessageModel.fromMap(rows[i]);
            return MessageCard(model: m);
          },
        );
      },
    );
  }
}
