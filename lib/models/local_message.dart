import 'package:chat/chat.dart';

class LocalMessage {
  String chatId;
  String? _id;
  Message message;
  ReceiptStatus receipt;

  String get id => _id!;

  LocalMessage(this.chatId, this.message, this.receipt);

  Map<String, dynamic> toMap() => {
        "chat_id": chatId,
        "id": id,
        ...message.toJson(),
        "receipt": receipt.values()
      };

  factory LocalMessage.fromMap(Map<String, dynamic> json) {
    final message = Message(
      from: json["from"],
      to: json["to"],
      timestamp: json["timestamp"],
      content: json["content"],
    );

    final localmessage = LocalMessage(
      json["chat_id"],
      message,
      json["receipt"],
    );
    localmessage._id = json["id"];

    return localmessage;
  }
}
