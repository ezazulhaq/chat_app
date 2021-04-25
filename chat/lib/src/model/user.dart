class User {
  String username;
  String photourl;
  String _id = "";
  bool active;
  String lastseen;

  User({
    required this.username,
    required this.photourl,
    required this.active,
    required this.lastseen,
  });

  String get id => _id;

  Map<String, dynamic> toJson() => {
        "username": username,
        "photourl": photourl,
        "active": active,
        "lastseen": lastseen
      };

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
      username: json["username"],
      photourl: json["photourl"],
      active: json["active"],
      lastseen: json["lastseen"],
    );
    user._id = json["id"];
    return user;
  }
}
