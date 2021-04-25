enum Typing { start, stop }

extension EnumParsing on Typing {
  String values() {
    // return only values - start/stop
    return this.toString().split(".").last;
  }

  static Typing fromString(String status) {
    // return only values - Typing.start/stop
    return Typing.values.firstWhere((element) => element.values() == status);
  }
}

class TypingEvent {
  final String from;
  final String to;
  final Typing event;
  String? _id;

  String get id => _id!;

  TypingEvent({
    required this.from,
    required this.to,
    required this.event,
  });

  Map<String, dynamic> toJson() =>
      {"from": this.from, "to": this.to, "event": event.values()};

  factory TypingEvent.fromJson(Map<String, dynamic> json) {
    final typeEvent = TypingEvent(
      from: json["from"],
      to: json["to"],
      event: EnumParsing.fromString(json["event"]),
    );

    typeEvent._id = json["id"];

    return typeEvent;
  }
}
