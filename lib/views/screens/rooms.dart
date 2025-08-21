// import 'package:blackrock_go/views/screens/chat.dart';
import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../models/const_model.dart';

class RoomsPage extends StatefulWidget {
  const RoomsPage({super.key});

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final MeshtasticNodeController meshtasticNodeController = Get.find();

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
        appBar: CustomAppBar(
          leadingWidget: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Your Chats',
              style: TextStyle(color: Constants.primaryGold),
            ),
          ),
          actionWidgets: IconButton(
            icon: Icon(
              Icons.add,
              size: 35.px,
              color: Constants.primaryGold,
            ),
            onPressed: () {
              context.push('/users');
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(
            top: 2.h,
            left: 2.w,
            right: 2.w,
            bottom: 1.h,
          ),
          child: Builder(
            builder: (context) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.push('/allChat');
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 0.5.h),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20.sp),
                          border: Border.all(
                            width: 0.7,
                            color: Constants.primaryGold,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.h,
                          vertical: 2.h,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'All Chat',
                              style: TextStyle(fontSize: 17.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      return meshtasticNodeController.activeRooms.isNotEmpty
                          ? ListView.builder(
                              itemCount:
                                  meshtasticNodeController.activeRooms.length,
                              itemBuilder: (context, index) {
                                final room =
                                    meshtasticNodeController.activeRooms[index];

                                return GestureDetector(
                                  onTap: () {
                                    context.pushReplacement('/userChat',
                                        extra: {
                                          'title': room.longName,
                                          'user': room
                                        });
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 0.5.h),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius:
                                            BorderRadius.circular(20.sp),
                                        border: Border.all(
                                          width: 0.7,
                                          color: Constants.primaryGold,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 2.h,
                                        vertical: 2.h,
                                      ),
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                room.displayName,
                                                style:
                                                    TextStyle(fontSize: 17.sp),
                                              ),
                                              Text(
                                                room.lastHeard.toString(),
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    color: const Color.fromARGB(
                                                        255, 78, 78, 78)),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : SizedBox.shrink();
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
