import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Column(children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, 10),
        child: Align(alignment: Alignment.centerLeft, child: Text('Community Chat', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800))),
      ),
      const Expanded(child: ListView(padding: EdgeInsets.all(18), children: [
        _Bubble(name: 'Aisha • Donor', text: 'I have 12 fresh meal boxes available.', mine: false),
        _Bubble(name: 'You', text: 'I can arrange a volunteer pickup.', mine: true),
        _Bubble(name: 'Rahul • Volunteer', text: 'Pickup is scheduled for 6:30 PM.', mine: false),
      ])),
      Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          const Expanded(child: TextField(decoration: InputDecoration(hintText: 'Type a message…', filled: true))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: () {}, icon: const Icon(Icons.send)),
        ]),
      )
    ]),
  );
}

class _Bubble extends StatelessWidget {
  final String name, text; final bool mine;
  const _Bubble({required this.name, required this.text, required this.mine});
  @override
  Widget build(BuildContext c) => Align(
    alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      constraints: const BoxConstraints(maxWidth: 310),
      decoration: BoxDecoration(
        color: mine ? const Color(0xFF214D25) : const Color(0xFF132018),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(fontSize: 11, color: Colors.white54)),
        const SizedBox(height: 4),
        Text(text),
      ]),
    ),
  );
}
