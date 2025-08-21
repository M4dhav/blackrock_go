import 'package:blackrock_go/controllers/meshtastic_node_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:meshtastic_flutter/meshtastic_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blackrock_go/models/const_model.dart' as constants;

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final MeshtasticNodeController meshtasticNodeController = Get.find();

    return Drawer(
      shadowColor: constants.Constants.primaryGold,
      surfaceTintColor: const Color.fromARGB(255, 52, 52, 52),
      elevation: 10.w,
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 3.w, top: 10.h, bottom: 8.h),
            child: Obx(
              () => meshtasticNodeController.connectionStatus.value.state ==
                      MeshtasticConnectionState.connected
                  ? Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: constants.Constants.primaryGold,
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
                        SizedBox(width: 4.w),
                        Text(
                          meshtasticNodeController.client.localUser?.longName ??
                              'Jim Halpert',
                          style: TextStyle(
                            color: constants.Constants.primaryGold,
                            fontSize: 21.px,
                          ),
                        ),
                      ],
                    )
                  : Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: constants.Constants.primaryGold,
                              width: 1.px,
                            ),
                            borderRadius: BorderRadius.circular(8)),
                        padding: EdgeInsets.all(9),
                        child: Text(
                          'No Node Connected',
                          style: TextStyle(
                            color: constants.Constants.primaryGold,
                            fontSize: 20.px,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () {
              context.push('/connectNode');
            },
            child: ListTile(
              leading: Icon(Icons.bluetooth,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Connect to Node',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 20.px,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.event,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Events',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
          SizedBox(height: 1.h),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.settings,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 24.px,
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: ListTile(
              leading: Icon(Icons.contacts,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Contact Us',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 20.px,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await launchUrl(Uri.parse('https://blackrockgo.org/privacy'));
            },
            child: ListTile(
              leading: Icon(Icons.privacy_tip,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Privacy Policy',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 20.px,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              await launchUrl(Uri.parse('https://blackrockgo.org/terms'));
            },
            child: ListTile(
              leading: Icon(Icons.edit_document,
                  color: constants.Constants.primaryGold, size: 24.px),
              title: Text(
                'Terms of Service',
                style: TextStyle(
                  color: constants.Constants.primaryGold,
                  fontSize: 20.px,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
