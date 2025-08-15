class TimelinePosts {
  String imageUrl;

  int timestamp;

  TimelinePosts({
    required this.imageUrl,
    required this.timestamp,
  });

  TimelinePosts.fromJson(Map<String, dynamic> json)
      : imageUrl = json['imageUrl'] as String,
        timestamp = json['timestamp'] as int;

  Map<String, Object> toJson() {
    return {
      'imageUrl': imageUrl,
      'timestamp': timestamp,
    };
  }
}
