import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'package:intl/intl.dart';

class MessageCard extends StatelessWidget {
  final MessageModel model;
  const MessageCard({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.yMMMd().add_jm().format(model.timestamp);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: ListTile(
        title: Text(model.title),
        subtitle: Text('${model.body}\n${model.senderName} • ${model.senderRole} • $time'),
        isThreeLine: true,
        trailing: _priorityBadge(model.priority),
      ),
    );
  }

  Widget _priorityBadge(String p) {
    Color c = Colors.grey;
    if (p.toLowerCase() == 'important') c = Colors.orange;
    if (p.toLowerCase() == 'urgent') c = Colors.red;
    return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)), child: Text(p, style: const TextStyle(color: Colors.white)));
  }
}
