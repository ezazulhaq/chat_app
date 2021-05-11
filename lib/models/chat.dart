import 'package:chat_app/models/local_message.dart';

class Chat {
  String id;
  int unread = 0;
  List<LocalMessage>? message = [];
  LocalMessage? mostRecent;

  Chat(this.id, {this.message, this.mostRecent});

  Map<String, dynamic> toMap() => {
        "id": id,
      };

  factory Chat.fromMap(Map<String, dynamic> json) {
    return Chat(json["id"]);
  }
}
