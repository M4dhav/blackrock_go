import 'package:blackrock_go/models/user_model.dart';
import 'package:latlong2/latlong.dart';

class EventModel {
  final String imageUrl;
  final String eventName;
  final String description;
  final LatLng location;
  final DateTime startTime;
  final DateTime endTime;
  late final List<User> hosts;
  final String locationName;
  final int cost;

  EventModel({
    required this.imageUrl,
    required this.eventName,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.hosts,
    required this.cost,
    required this.locationName,
  });

  EventModel.fromMap(Map<String, dynamic> map)
      : imageUrl = map['imageUrl'],
        eventName = map['eventName'],
        description = map['description'],
        location = map['location'],
        startTime = DateTime.parse(map['startTime']),
        endTime = DateTime.parse(map['endTime']),
        cost = map['cost'] ?? 0,
        locationName = map['locationName'];
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'eventName': eventName,
      'description': description,
      'location': LatLng(location.latitude, location.longitude),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'cost': cost,
      'locationName': locationName,
    };
  }
}
