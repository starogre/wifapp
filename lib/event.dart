import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String startTime;
  final String endTime;
  final String name;
  final String organizer;
  final String location;
  final String description;

  Event({
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.organizer,
    required this.location,
    required this.description,
  });

  factory Event.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Event(
      startTime: data['startTime'] as String? ?? '',
      endTime: data['endTime'] as String? ?? '',
      name: data['name'] as String? ?? 'Unnamed Event',
      organizer: data['organizer'] as String? ?? 'Unknown Organizer',
      location: data['location'] as String? ?? 'Unknown Location',
      description: data['description'] as String? ?? 'No description available',
    );
  }
}
