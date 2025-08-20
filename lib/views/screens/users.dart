import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:blackrock_go/views/widgets/appbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final MeshtasticNodeController meshtasticNodeController = Get.find();

  Widget _buildAvatar(NodeInfoWrapper user) {
    return CircleAvatar(
      backgroundColor: const Color(0xffb4914b),
      radius: 9.w,
      child: Text(
        user.shortName ?? 'JH',
        style: TextStyle(
          color: Colors.black,
          fontSize: 21.px,
        ),
      ),
    );
  }

  void _handlePressed(NodeInfoWrapper user, BuildContext context) async {
    final goRouter = GoRouter.of(context);

    goRouter.pop();
    // await navigator.push(
    //   MaterialPageRoute(
    //     builder: (context) => ChatPage(
    //       room: room,
    //     ),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/bg.jpg',
                ),
                fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: CustomAppBar(
            titleWidget: const Text(
              'Users',
              style: TextStyle(color: Color(0xffb4914b)),
            ),
          ),
          body: ListView.builder(
            itemBuilder: (context, index) {
              final user = meshtasticNodeController
                  .nodes[meshtasticNodeController.nodes.keys.elementAt(index)];

              if (user?.num ==
                  meshtasticNodeController.client.myNodeInfo?.myNodeNum) {
                return SizedBox.shrink();
              }

              return InkWell(
                onTap: () {
                  _handlePressed(user, context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(user!),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.longName ?? 'Jim Halpert',
                            style: TextStyle(fontSize: 18.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
}
