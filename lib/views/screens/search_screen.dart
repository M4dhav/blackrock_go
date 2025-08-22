import 'package:blackrock_go/controllers/event_controller.dart';
import 'package:blackrock_go/models/event_model.dart';
import 'package:blackrock_go/views/widgets/search_tile_widget.dart';
import 'package:blackrock_go/views/widgets/search_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/const_model.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final EventController controller = Get.find();
  List<EventModel> filteredSuggestions = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(left: 3.2.w, right: 3.2.w, top: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Search for?',
                  style:
                      TextStyle(color: Constants.primaryGold, fontSize: 16.sp)),
              SearchBarWidget(
                onSearch: (query) {
                  setState(() {
                    if (query.isEmpty) {
                      filteredSuggestions = List.from(controller.allEvents);
                    } else {
                      filteredSuggestions = controller.allEvents
                          .where((item) => item.eventName
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                          .toList();
                    }
                  });
                },
              ),
              SizedBox(height: 4.h),
              Expanded(
                child: ListView(
                  children: filteredSuggestions.map((suggestion) {
                    return EventListTile(
                      event: suggestion,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
