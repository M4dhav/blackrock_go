import 'dart:developer';
import 'dart:typed_data';
import 'package:blackrock_go/models/timeline_post_model.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';

class TimelinePostController extends GetxController {
  RxList<TimelinePosts> posts = <TimelinePosts>[].obs;
  final Database database = Get.find<Database>();

  Future<void> getPosts() async {
    posts.clear();
    final List<Map<String, Object?>> postsMap =
        await database.query('timeline_posts');
    for (Map<String, Object?> post in postsMap) {
      posts.insert(0, TimelinePosts.fromJson(post));
    }
  }

  Future<String> takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);

    if (photo != null) {
      log(photo.name);
      return photo.path;
    } else {
      return "";
    }
  }

  Future<void> addPostToTimeline(String path) async {
    try {
      final newPost = TimelinePosts(
          imageUrl: path, timestamp: DateTime.now().millisecondsSinceEpoch);
      await database.insert('timeline_posts', newPost.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      posts.insert(0, newPost);
      log(posts.length.toString(), name: "addPostToTimelineLength");
    } catch (e) {
      log(e.toString(), name: "addPostToTimelineError");
    }
  }
}
