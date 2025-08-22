import 'package:blackrock_go/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/const_model.dart';

class EventListTile extends StatelessWidget {
  final EventModel event;
  const EventListTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/eventDetails', extra: [event]);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 2.w),
        padding: EdgeInsets.symmetric(vertical: 1.8.h, horizontal: 1.5.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Constants.primaryGold,
            width: 0.3,
          ),
        ),
        child: ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                event.eventName,
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
              Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                event.description,
                style: TextStyle(color: Colors.grey, fontSize: 14.sp),
              ),
              Text(
                '${DateFormat('EEE').format(event.startTime)} ${DateFormat('h:mm a').format(event.startTime)} : ${DateFormat('h:mm a').format(event.endTime)}', // Day (e.g., "Mon")
                style: TextStyle(
                  color: Constants.primaryGold,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
