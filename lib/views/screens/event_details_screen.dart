import 'dart:io';

import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/location_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/const_model.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key, required this.event});
  final EventModel event;

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
            child: Center(
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(widget.event.imageUrl),
                      width: 90.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Text(
                      widget.event.eventName,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 25.px,
                        fontFamily: 'Cinzel',
                        color: Constants.primaryGold,
                      ),
                    ),
                  ),
                  EventLocationTimeWidget(
                      startTime: widget.event.startTime,
                      endTime: widget.event.endTime,
                      location:
                          LatLng(widget.event.latitude, widget.event.longitude),
                      locationName: widget.event.locationName)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
