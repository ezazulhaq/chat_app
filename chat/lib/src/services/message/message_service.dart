// @dart=2.9
import 'dart:async';

import 'package:chat/src/model/user.dart';
import 'package:chat/src/model/message.dart';
import 'package:chat/src/services/message/message_service_contract.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class MessageService implements IMessageService {
  final Connection _connection;
  final Rethinkdb r;

  final _controller = StreamController<Message>.broadcast();
  // ignore: cancel_subscriptions
  StreamSubscription _changefeed;

  MessageService(this.r, this._connection);

  @override
  dispose() {
    if (_changefeed != null) _changefeed.cancel();
    _controller.close();
  }

  @override
  Stream<Message> messages({User activeUser}) {
    _startReceivingMessaged(activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> send(Message message) async {
    final record =
        await r.table("message").insert(message.toJson()).run(_connection);

    return record["inserted"] == 1;
  }

  void _startReceivingMessaged(User user) {
    _changefeed = r
        .table("message")
        .filter({"to": user.id})
        .changes({"include_initial": true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData["new_val"] == null) return;

                final message = _messageFromStream(feedData);
                _controller.sink.add(message);
                _removeDeliveredMessage(message);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  Message _messageFromStream(feedData) {
    return Message.fromJson(feedData["new_val"]);
  }

  void _removeDeliveredMessage(Message message) {
    r
        .table("message")
        .get(message.id)
        .delete({"return_changes": false}).run(_connection);
  }
}
