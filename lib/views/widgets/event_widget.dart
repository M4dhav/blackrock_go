import 'dart:io';

import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/location_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventWidget extends StatelessWidget {
  final EventModel event;
  final String hostName;
  const EventWidget({super.key, required this.event, required this.hostName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 74.h,
          width: 84.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xffb4914b),
            ),
          ),
          // color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(event.imageUrl),
                    width: 80.w,
                    height: 38.h,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 1.w), // Increased horizontal padding
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      event.eventName,
                      textAlign: TextAlign.left,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22.px,
                        fontFamily: 'Cinzel',
                        color: const Color(0xffb4914b),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 10.w,
                      child: Text(
                        hostName,
                        style: TextStyle(
                          fontSize: 12.px,
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 2.w,
                    ),
                    Text(
                      "Hosted by: $hostName",
                      style: TextStyle(
                        fontSize: 10.px,
                        fontFamily: 'Cinzel',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                EventLocationTimeWidget(
                  startTime: event.startTime,
                  endTime: event.endTime,
                  locationName: event.locationName,
                  location: LatLng(event.latitude, event.longitude),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () {
                        context.push('/eventDetails', extra: [event, hostName]);
                      },
                      child: Text(
                        "Details",
                        style: TextStyle(
                          fontSize: 12.px,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () {},
                      child: Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 12.px,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
