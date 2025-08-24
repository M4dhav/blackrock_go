import 'dart:developer';

import 'package:blackrock_go/controllers/timeline_post_controller.dart';
import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/views/screens/chats_page.dart';
import 'package:blackrock_go/views/screens/home_screen.dart';
import 'package:blackrock_go/views/screens/profile_screen.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  TimelinePostController controller = Get.find();
  int _selectedIndex = 2;
  static final List<Widget> _widgetOptions = <Widget>[
    const ChatsPage(),
    const ProfilePage(),
    const MapHomePage(),
  ];
  static final List<IconData> iconList = <IconData>[
    Icons.chat,
    Icons.person,
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'assets/bg.jpg',
                ),
                fit: BoxFit.cover)),
        child: Scaffold(
          extendBody: _selectedIndex == 2 ? true : false,
          backgroundColor: Colors.transparent,
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.black,
            shape: CircleBorder(side: BorderSide(color: Constants.primaryGold)),
            child: Center(
              child: Icon(
                _selectedIndex == 2 ? Icons.camera : Icons.home,
                size: 28.sp,
                color: Constants.primaryGold,
              ),
            ),
            onPressed: () async {
              final goRouter = GoRouter.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              if (_selectedIndex == 2) {
                String path = await controller.takePicture();
                log(path);
                if (path != "") {
                  goRouter.push('/storyDesigner', extra: path);
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text("No Picture taken"),
                    ),
                  );
                }
              }
              setState(() {
                _selectedIndex = 2;
              });
            },
            //params
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            height: 8.h,
            borderColor: Constants.primaryGold,
            backgroundColor: Colors.black,
            itemCount: _widgetOptions.length - 1,
            tabBuilder: (int index, bool isActive) {
              return Icon(
                iconList[index],
                size: 26.sp,
                color: Constants.primaryGold,
              );
            },
            activeIndex: _selectedIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.verySmoothEdge,
            leftCornerRadius: 21.sp,
            rightCornerRadius: 21.sp,
            onTap: (index) => setState(() => _selectedIndex = index),
          ),
        ),
      ),
    );
  }
}
