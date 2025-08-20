import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/controllers/timeline_post_controller.dart';
import 'package:blackrock_go/views/widgets/drawer_widget.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:blackrock_go/views/widgets/timeline_post_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TimelinePostController postController = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MeshtasticNodeController meshtasticNodeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
        leadingWidget: SizedBox(
          width: 50.w,
          child: Text(
            "Profile Page",
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xffb4914b),
            ),
          ),
        ),
        actionWidgets: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_box,
                  size: 26.px, color: const Color(0xffb4914b)),
              onPressed: () {},
            ),
            IconButton(
              icon:
                  Icon(Icons.menu, size: 29.px, color: const Color(0xffb4914b)),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ],
        ),
      ),
      body: NestedScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                width: 80.w,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: 6.w, right: 6.w, top: 2.h, bottom: 1.h),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xffb4914b)),
                    ),
                    padding: EdgeInsets.all(3.h),
                    child: Obx(
                      () => meshtasticNodeController
                                  .connectionStatus.value.state ==
                              MeshtasticConnectionState.connected
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(0xffb4914b),
                                      radius: 9.w,
                                      child: Text(
                                        meshtasticNodeController
                                                .client.localUser?.shortName ??
                                            'JH',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 21.px,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${meshtasticNodeController.client.connectedNodeBatteryLevel}%',
                                      style: TextStyle(
                                        color: const Color(0xffb4914b),
                                        // fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meshtasticNodeController
                                              .client.localUser?.longName ??
                                          'Jim Halpert',
                                      style: TextStyle(
                                        color: const Color(0xffb4914b),
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      // meshtasticNodeController.client.myNodeInfo.??
                                      'BLE Name: ${meshtasticNodeController.client.connectedDeviceName}',
                                      style: TextStyle(
                                        color: const Color(0xffb4914b),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      // meshtasticNodeController.client.myNodeInfo.??
                                      'Firmware Version: ${meshtasticNodeController.client.firmwareVersion}',
                                      style: TextStyle(
                                        color: const Color(0xffb4914b),
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Obx(
                                      () => Text(
                                        // meshtasticNodeController.client.myNodeInfo.??
                                        meshtasticNodeController
                                            .connectionStatus.value.state.name,
                                        style: TextStyle(
                                          color: meshtasticNodeController
                                                      .connectionStatus
                                                      .value
                                                      .state ==
                                                  MeshtasticConnectionState
                                                      .connected
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Icon(Icons.bluetooth_disabled,
                                    color: Colors.redAccent, size: 22.px),
                                Text(
                                  'No Node Connected',
                                  style: TextStyle(
                                    color: const Color(0xffb4914b),
                                    fontSize: 20.px,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(2.h),
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Color(0xffb4914b)),
                left: BorderSide(color: Color(0xffb4914b)),
                right: BorderSide(color: Color(0xffb4914b)),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Timeline',
                  style: TextStyle(
                    fontFamily: 'Cinzel',
                    fontWeight: FontWeight.bold,
                    color: Color(0xffb4914b),
                    fontSize: 22,
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      shrinkWrap: true,
                      // reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: postController.posts.length,
                      itemBuilder: (context, index) {
                        final post = postController.posts[index];
                        final date =
                            DateTime.fromMillisecondsSinceEpoch(post.timestamp);
                        final formattedDate =
                            "${date.day}/${date.month}/${date.year}";
                        return TimelineItem(
                          index: index,
                          imageUrl: post.imageUrl,
                          timestamp: formattedDate,
                        );
                      },
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
