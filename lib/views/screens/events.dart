import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/search_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EventController controller = Get.find();
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomAppBar(
          titleWidget: Text('Events',
              style: TextStyle(color: Constants.primaryGold, fontSize: 22.px)),
        ),
        body: ListView.builder(
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            return EventListTile(event: event);
          },
          shrinkWrap: true,
        ),
      ),
    );
  }
}
