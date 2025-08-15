import 'dart:io';

class User {
  File pfpUrl;
  final String accountName;

  User({
    required this.pfpUrl,
    required this.accountName,
  });

  User.fromMap(Map<String, dynamic> map)
      : pfpUrl = File(map['pfpUrl']),
        accountName = map['accountName'] ?? "";

  Map<String, dynamic> toJson() {
    return {
      'pfpUrl': pfpUrl.path,
      'accountName': accountName,
    };
  }
}
