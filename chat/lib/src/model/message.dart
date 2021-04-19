class Message {
  String from;
  String to;
  String timestamp;
  String content;
  String _id = "";

  Message({
    required this.from,
    required this.to,
    required this.timestamp,
    required this.content,
  });

  String get id => _id;

  toJson() => {
        "from": this.from,
        "to": this.to,
        "timestamp": this.timestamp,
        "content": this.content
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    final message = Message(
      from: json["from"],
      to: json["to"],
      timestamp: json["timestamp"],
      content: json["content"],
    );
    message._id = json["id"];
    return message;
  }
}
