import 'package:blackrock_go/models/user_model.dart';
import 'package:latlong2/latlong.dart';

class EventModel {
  final String imageUrl;
  final String eventName;
  final String description;
  final double latitude;
  final double longitude;
  final DateTime startTime;
  final DateTime endTime;
  late final String hostName;
  final String locationName;

  EventModel({
    required this.imageUrl,
    required this.eventName,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.startTime,
    required this.endTime,
    required this.hostName,
    required this.locationName,
  });

  EventModel.fromMap(Map<String, dynamic> map)
      : imageUrl = map['imageUrl'],
        eventName = map['eventName'],
        description = map['description'],
        latitude = map['latitude'],
        longitude = map['longitude'],
        startTime = DateTime.parse(map['startTime']),
        endTime = DateTime.parse(map['endTime']),
        locationName = map['locationName'];
  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'eventName': eventName,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'locationName': locationName,
    };
  }
}
