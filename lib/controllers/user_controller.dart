import 'dart:io';

import 'package:blackrock_go/models/user_model.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  User user = User(
    pfpUrl: File(''),
    accountName: '',
  );

  void setUser(User newUser) {
    user = newUser;
  }

  Future<User> getHost(String uid) async {
    // DocumentSnapshot userDoc = await FirebaseUtils.users.doc(uid).get();
    // return WalletUser.fromMap(userDoc.data() as Map<String, dynamic>);
    return User(
      pfpUrl: File(''),
      accountName: '',
    );
  }

  void updatePfp(File newPfp) {
    user.pfpUrl = newPfp;
  }
}
