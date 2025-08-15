import 'dart:io';

import 'package:blackrock_go/models/const_model.dart';
import 'package:blackrock_go/views/widgets/navbar_widget.dart';
import 'package:blackrock_go/controllers/user_controller.dart';
import 'package:blackrock_go/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool isUploading = false;
  TextEditingController name = TextEditingController();

  final UserController userController = Get.find();
  final ImagePicker picker = ImagePicker();
  final SharedPreferencesWithCache prefs = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        appBar: CustomNavBar(
          leadingWidget: Padding(
            padding: EdgeInsets.all(1.w),
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFB4914B)),
            ),
          ),
          actionWidgets: SizedBox(
            width: 76.w,
            child: Row(
              children: [
                Text(
                  "Create Your Profile",
                  style: TextStyle(
                    color: const Color(0xFFB4914B), // Gold color
                    fontSize: 16.sp,
                    fontFamily: 'Cinzel',
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.only(top: 5.h, right: 5.w, left: 5.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: const Color(0xffb4914b),
                  foregroundImage: !isUploading
                      ? FileImage(userController.user.pfpUrl)
                      : null,
                  child: isUploading ? const CircularProgressIndicator() : null,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: ElevatedButton(
                    style: Constants.buttonStyle,
                    onPressed: () async {
                      setState(() {
                        isUploading = true;
                      });
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        File file = File(image.path);
                        await prefs.setString('pfpUrl', file.path);
                        userController.updatePfp(file);
                      }
                      setState(() {
                        isUploading = false;
                      });
                    },
                    child: const Text('Choose Profile Picture'),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: TextFormField(
                    style: Constants.inputStyle,
                    cursorColor: Colors.white,
                    decoration: Constants.inputDecoration.copyWith(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    maxLines: 1,
                    controller: name,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: ElevatedButton(
                      style: Constants.buttonStyle,
                      onPressed: () async {
                        await prefs.setString('accountName', name.text);
                        userController.setUser(User(
                          pfpUrl: userController.user.pfpUrl,
                          accountName: name.text,
                        ));

                        context.pushReplacement('/home');
                      },
                      child: const Text('Submit')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
