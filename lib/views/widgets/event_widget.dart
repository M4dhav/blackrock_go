
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/location_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventWidget extends StatelessWidget {
  final EventModel event;

  const EventWidget({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          height: 50.h,
          width: 84.w,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Constants.primaryGold,
            ),
          ),
          // color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  event.eventName,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 22.px,
                    fontFamily: 'Cinzel',
                    color: Constants.primaryGold,
                  ),
                ),
                Text(
                  event.description,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.px,
                    fontFamily: 'Cinzel',
                    color: Colors.white,
                  ),
                ),
                EventLocationTimeWidget(
                  startTime: event.startTime,
                  endTime: event.endTime,
                  locationName: event.locationName,
                  location: LatLng(event.latitude, event.longitude),
                  campName: event.campName,
                ),
                ElevatedButton(
                  style: Constants.buttonStyle,
                  onPressed: () {
                    context.push('/eventDetails', extra: [
                      event,
                    ]);
                  },
                  child: Text(
                    "Details",
                    style: TextStyle(
                      fontSize: 12.px,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
