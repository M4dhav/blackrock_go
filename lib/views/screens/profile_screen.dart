import 'package:blackrock_go/controllers/timeline_post_controller.dart';
import 'package:blackrock_go/controllers/user_controller.dart';
import 'package:blackrock_go/views/widgets/drawer_widget.dart';
import 'package:blackrock_go/views/widgets/navbar_widget.dart';
import 'package:blackrock_go/views/widgets/timeline_post_widget.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserController userController = Get.find();
  final TimelinePostController postController = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Colors.transparent,
      appBar: CustomNavBar(
        leadingWidget: SizedBox(
          width: 50.w,
          child: Text(
            userController.user.accountName,
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
      body: RefreshIndicator(
        notificationPredicate: (notification) {
          return notification.depth == 2;
        },
        onRefresh: () async {},
        child: NestedScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: SizedBox(
                  // height: 50.1.h,
                  width: 80.w,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 6.w, right: 6.w, top: 2.h, bottom: 1.h),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xffb4914b)),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: CircleAvatar(
                                        radius: 12.w,
                                        backgroundImage: FileImage(
                                            userController.user.pfpUrl),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      userController.user.accountName,
                                      style: TextStyle(
                                        color: const Color(0xffb4914b),
                                        fontSize: 19.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 3.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.all(2.h),
            child: Container(
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
              child: DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    ButtonsTabBar(
                      backgroundColor: Colors.transparent,
                      unselectedBackgroundColor: Colors.transparent,
                      contentPadding:
                          EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                      labelStyle: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontWeight: FontWeight.bold,
                        color: Color(0xffb4914b),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xffb4914b),
                        decorationThickness: 4,
                        fontSize: 16,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w100,
                        color: const Color(0xffb4914b),
                      ),
                      tabs: const [
                        Tab(text: "TIMELINE"),
                        Tab(text: "TOKENS"),
                        Tab(text: "NFTS"),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: <Widget>[
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: postController.posts.length,
                            itemBuilder: (context, index) {
                              final post = postController.posts[index];
                              final date = DateTime.fromMillisecondsSinceEpoch(
                                  post.timestamp);
                              final formattedDate =
                                  "${date.day}/${date.month}/${date.year}";
                              return TimelineItem(
                                index: index,
                                imageUrl: post.imageUrl,
                                timestamp: formattedDate,
                              );
                            },
                          ),
                          Container(),
                          Container()
                          // ListView.builder(
                          //   itemCount: 0,
                          //   itemBuilder: (context, index) {
                          //     final token =
                          //         controller.runes.values.elementAt(index);
                          //     return InkWell(
                          //       onTap: () {
                          //         context.push('token', extra: token);
                          //       },
                          //       child: ListTile(
                          //         titleTextStyle:
                          //             const TextStyle(color: Colors.white),
                          //         title: Text(token['name']),
                          //         subtitle: Text(
                          //             "Balance: ${token['balance'] ?? 0} ${token['symbol'] ?? ""}"),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // ListView.builder(
                          //   itemCount: controller.ordinals.length,
                          //   itemBuilder: (context, index) {
                          //     final token =
                          //         controller.ordinals.values.elementAt(index);
                          //     String type = token['info']['content_type'];
                          //     if (type.contains('image')) {
                          //       return Image.network(
                          //           token['info']['content_url']);
                          //     } else if (type.contains("text")) {
                          //       return GestureDetector(
                          //         onTap: () async {
                          //           log("tranc a tsrating                         ");
                          //           await controller
                          //               .sellerCreateAndStoreTransactionWithBip49(
                          //             listingId: "jbhkdjcbc",
                          //             ordinalUtxo: token['utxos'][0],
                          //             sellerReceiveAddress:
                          //                 userController.user.walletAddress,
                          //           );
                          //         },
                          //         child: Text(
                          //           token['info']['contents'],
                          //           textAlign: TextAlign.center,
                          //         ),
                          //       );
                          //     } else {
                          //       return Container();
                          //     }
                          //   },
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
