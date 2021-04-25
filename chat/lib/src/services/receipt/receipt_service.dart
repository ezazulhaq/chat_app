// @dart = 2.9
import 'dart:async';

import 'package:chat/src/model/receipt.dart';
import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/receipt/receipt_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class ReceiptService implements IReceiptService {
  final Connection _connection;
  final Rethinkdb r;

  final _controller = StreamController<Receipt>.broadcast();
  // ignore: cancel_subscriptions
  StreamSubscription _changefeed;

  ReceiptService(this.r, this._connection);

  @override
  dispose() {
    if (_changefeed != null) _changefeed.cancel();
    _controller.close();
  }

  @override
  Stream<Receipt> receipts(User user) {
    _startReceivingReceipts(user);
    return _controller.stream;
  }

  @override
  Future<bool> send(Receipt receipt) async {
    var data = receipt.toJson();
    final record = await r.table("receipt").insert(data).run(_connection);

    return record["inserted"] == 1;
  }

  void _startReceivingReceipts(User user) {
    _changefeed = r
        .table("receipt")
        .filter({"receipient": user.id})
        .changes({"include_initial": true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData["new_val"] == null) return;

                final receipt = _receiptFromStream(feedData);
                _controller.sink.add(receipt);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Receipt _receiptFromStream(feedData) {
    var data = feedData["new_val"];
    return Receipt.fromJson(data);
  }
}
