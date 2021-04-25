enum ReceiptStatus { sent, delivered, read }

extension EnumParsing on ReceiptStatus {
  String values() {
    // return only values - sent/delivered/read
    return this.toString().split(".").last;
  }

  static ReceiptStatus fromString(String status) {
    return ReceiptStatus.values
        .firstWhere((element) => element.values() == status);
  }
}

class Receipt {
  final String receipient;
  final String messageId;
  final ReceiptStatus status;
  final String timestamp;
  String? _id;

  String get id => _id!;

  Receipt({
    required this.receipient,
    required this.messageId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        "receipient": this.receipient,
        "messageId": this.messageId,
        "status": status.values(),
        "timestamp": this.timestamp
      };

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final receipt = Receipt(
      receipient: json["receipient"],
      messageId: json["messageId"],
      status: EnumParsing.fromString(json["status"]),
      timestamp: json["timestamp"],
    );
    receipt._id = json["id"];

    return receipt;
  }
}
