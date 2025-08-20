import 'package:blackrock_go/models/const_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final prefs = Get.find<SharedPreferencesWithCache>();
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg.jpg"), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/blackrock_logo_transparent.png",
                        height: 32.h,
                      ),
                      Text(
                        "BlackRock Go",
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: const Color(0xffb4914b),
                            fontSize: 23.sp),
                      ),
                      Text(
                        "Experience the Network",
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 19.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 67.w,
                  child: ElevatedButton(
                      onPressed: () async {
                        await prefs.setBool('isEntered', true);
                        context.push(
                          '/home',
                        );
                      },
                      style: Constants.buttonStyle,
                      child: Text(
                        "Enter a new world",
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 17.sp),
                      )),
                ),
                Image.asset(
                  'assets/pcg.jpg',
                  height: 10.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
