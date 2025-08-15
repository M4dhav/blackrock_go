import 'package:blackrock_go/models/const_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/alpha.jpg",
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
                Column(
                  children: [
                    SizedBox(
                      width: 67.w,
                      child: ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/legal',
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
                    Padding(
                      padding: EdgeInsets.only(top: 3.h),
                      child: Text(
                        "POWERED BY BITCOIN",
                        style: TextStyle(
                            fontFamily: 'Cinzel',
                            color: Colors.white,
                            fontSize: 17.sp),
                      ),
                    ),
                    Text(
                      "MNEMONIC SEED PHRASE",
                      style: TextStyle(
                          fontFamily: 'Cinzel',
                          color: Colors.white,
                          fontSize: 15.sp),
                    ),
                  ],
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
