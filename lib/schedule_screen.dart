import 'package:flutter/material.dart';
import 'event_card.dart';
import 'event.dart';
import 'event_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleScreen extends StatelessWidget {
  final List<Event> events = [
    Event(
      startTime: '9:00 AM',
      endTime: '10:00 AM',
      name: 'Keynote',
      organizer: 'John Doe',
      location: 'Main Hall',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor.',
    ),
    Event(
      startTime: '10:00 AM',
      endTime: '11:00 AM',
      name: 'Workshop',
      organizer: 'Jane Doe',
      location: 'Room 1',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor.',
    ),
    Event(
      startTime: '11:00 AM',
      endTime: '12:00 PM',
      name: 'Lunch',
      organizer: 'John Doe',
      location: 'Cafeteria',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor.',
    ),
    Event(
      startTime: '12:00 PM',
      endTime: '1:00 PM',
      name: 'Workshop',
      organizer: 'Jane Doe',
      location: 'Room 1',
      description:
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor. Donec euismod, nisl eget tempor dignissim, nunc nulla aliquam eros, vitae ultricies nisl nisl eget dolor.',
    ),
  ];

  ScheduleScreen({super.key});

  Future<List<Event>> fetchEvents() async {
    List<Event> events = [];
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('events').get();
      for (var doc in querySnapshot.docs) {
        events.add(Event.fromFirestore(doc));
      }
    } catch (e) {
      print("Error fetching events: $e");
    }
    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Schedule"),
      ),
      body: FutureBuilder<List<Event>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final events = snapshot.data ?? [];
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventCard(
                  event: events[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EventDetailScreen(event: events[index]),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
