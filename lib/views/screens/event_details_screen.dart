
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/location_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/const_model.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.event});
  final EventModel event;

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
        appBar: CustomAppBar(
          titleWidget: Text(
            'Event Details',
            style: TextStyle(color: Constants.primaryGold, fontSize: 22.px),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 5.h),
            child: Center(
              child: Column(
                children: [
                  Text(
                    event.eventName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.px,
                      fontFamily: 'Cinzel',
                      color: Constants.primaryGold,
                    ),
                  ),
                  Text(
                    event.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17.px,
                      fontFamily: 'Cinzel',
                      color: Colors.white,
                    ),
                  ),
                  EventLocationTimeWidget(
                    startTime: event.startTime,
                    endTime: event.endTime,
                    location: LatLng(event.latitude, event.longitude),
                    locationName: event.locationName,
                    campName: event.campName,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
