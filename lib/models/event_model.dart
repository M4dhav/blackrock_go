import 'package:intl/intl.dart';

final List<String> campBlocks = [
  "esplanade",
  "a",
  "b",
  "c",
  "d",
  "e",
  "f",
  "g",
  "h",
  "i",
  "j",
  "k"
];

class EventModel {
  final String id;
  final EventType eventType;
  final String eventName;
  final String description;
  final String campId;
  final String campName;
  final String campBlock;
  final String campTime;
  final DateTime startTime;
  final DateTime endTime;
  final String locationName;
  late final double latitude;
  late final double longitude;

  EventModel({
    required this.eventName,
    required this.description,
    required this.campId,
    required this.campName,
    required this.campBlock,
    required this.campTime,
    required this.startTime,
    required this.endTime,
    required this.eventType,
    required this.id,
    required this.locationName,
  });

  EventModel.fromMap(Map<String, dynamic> map)
      : id = map['event_uid'],
        eventType = EventType.fromMap(map['event_type']),
        campId = map['camp_uid'],
        campName = map['camp_name'],
        locationName = map['camp_location'],
        campBlock = map['camp_location']
            .split("&")
            .map((s) => s.trim())
            .where((s) => campBlocks.contains(s.toLowerCase()))
            .toList()
            .first,
        campTime = map['camp_location']
            .split("&")
            .map((s) => s.trim())
            .where((s) => !campBlocks.contains(s.toLowerCase()))
            .toList()
            .first,
        eventName = map['event_title'],
        description = map['description'],
        startTime = DateFormat('yyyy-MM-dd hh:mm a').parse(map['start_time']),
        endTime = DateFormat('yyyy-MM-dd hh:mm a').parse(map['end_time']);
}

class EventType {
  final String label;
  final String abbreviation;

  EventType({required this.label, required this.abbreviation});
  EventType.fromMap(Map<String, dynamic> map)
      : label = map['label'],
        abbreviation = map['abbr'];
}
