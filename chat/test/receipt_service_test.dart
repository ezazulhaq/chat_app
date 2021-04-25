// @dart = 2.9
import 'package:chat/src/model/receipt.dart';
import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/receipt/receipt_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  ReceiptService receiptService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    receiptService = ReceiptService(r, connection);
  });

  tearDown(() async {
    receiptService.dispose();
    await cleanDb(r, connection);
  });

  final user = User.fromJson({
    "id": "1234",
    "active": true,
    "lastseen": DateTime.now().toIso8601String()
  });

  test("sent receipt successfully", () async {
    Receipt receipt = Receipt(
      receipient: "1111",
      messageId: "1234",
      status: ReceiptStatus.sent,
      timestamp: DateTime.now().toIso8601String(),
    );

    final res = await receiptService.send(receipt);
    expect(res, true);
  });

  test("Successfully Subscribe and Receive Receipts", () async {
    receiptService.receipts(user).listen(expectAsync1((receipt) {
          expect(receipt.receipient, user.id);
        }, count: 2));

    Receipt receipt1 = Receipt(
      receipient: user.id,
      messageId: "1234",
      status: ReceiptStatus.sent,
      timestamp: DateTime.now().toIso8601String(),
    );

    Receipt receipt2 = Receipt(
      receipient: user.id,
      messageId: "1234",
      status: ReceiptStatus.sent,
      timestamp: DateTime.now().toIso8601String(),
    );

    await receiptService.send(receipt1);
    await receiptService.send(receipt2);
  });
}
