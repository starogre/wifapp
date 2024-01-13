import 'package:flutter/material.dart';
import 'event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(event.name),
      subtitle: Text(
          '${event.startTime} - ${event.endTime}\n${event.organizer}\n${event.location}'),
      onTap: onTap, // pass ontap callback to listtile
    ));
  }
}
