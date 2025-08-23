import 'dart:convert';
import 'dart:developer';

import 'package:blackrock_go/models/event_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class EventController extends GetxController {
  final List<EventModel> events = [];
  final List<EventModel> allEvents = [];

  Future<void> getEvents() async {
    final eventsJsonString =
        await rootBundle.loadString('assets/camp_events.json');
    final campCoordsJsonString =
        await rootBundle.loadString('assets/camp_coords.json');

    final List<dynamic> eventsJson = jsonDecode(eventsJsonString);
    final List<dynamic> campCoordsJson = jsonDecode(campCoordsJsonString);
    log("the length of campCoordsJson is ${campCoordsJson.length}");
    for (var eventJson in eventsJson) {
      try {
        eventJson['camp_location']
            .split("&")
            .map((s) => s.trim())
            .where((s) => campBlocks.contains(s.toLowerCase()))
            .toList()
            .first;
      } catch (e) {
        continue;
      }
      EventModel event = EventModel.fromMap(eventJson as Map<String, dynamic>);
      try {
        event.latitude = campCoordsJson.firstWhere((c) =>
            c['ring'] == event.campBlock &&
            c['time'] == event.campTime)['latitude'];
        event.longitude = campCoordsJson.firstWhere((c) =>
            c['ring'] == event.campBlock &&
            c['time'] == event.campTime)['longitude'];
      } catch (e) {
        continue;
      }

      allEvents.add(event);
    }
    log("allEvents.length: ${allEvents.length}");
    log("allEvents[0].latitude: ${allEvents[0].latitude}");
    // final timeNow = DateTime.now();
    final timeNow = DateTime(2025, 8, 27, 12, 0, 0);
    events.addAll(allEvents.where((event) =>
        event.endTime.isAfter(timeNow) && event.startTime.isBefore(timeNow)));
    log("events.length: ${events.length}");
  }
}
