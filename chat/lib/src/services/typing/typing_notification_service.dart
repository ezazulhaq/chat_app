// @dart = 2.9
import 'dart:async';

import 'package:chat/src/model/user.dart';
import 'package:chat/src/model/typing.dart';
import 'package:chat/src/services/typing/typing_notification_service_contract.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class TypingNotificationService implements ITypingNotification {
  final Connection _connection;
  final Rethinkdb _r;

  final _controller = StreamController<TypingEvent>.broadcast();
  StreamSubscription _changefeed;

  TypingNotificationService(this._r, this._connection);

  @override
  void dispose() {
    _changefeed?.cancel();
    _controller?.close();
  }

  @override
  Future<bool> send(TypingEvent event, User to) async {
    if (!to.active) return false;

    Map record = await _r
        .table("typing_event")
        .insert(event.toJson(), {"conflict": "update"}).run(_connection);

    return record["inserted"] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(User user, List<String> userIds) {
    _startReceivingTypingEvent(user, userIds);
    return _controller.stream;
  }

  void _startReceivingTypingEvent(User user, List<String> userIds) {
    _changefeed = _r
        .table("typing_event")
        .filter((event) {
          return event("to")
              .eq(user.id)
              .and(_r.expr(userIds).contains(event("from")));
        })
        .changes({"include_initial": true})
        .run(_connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData["new_val"] == null) return;

                final typing = _eventFromStream(feedData);
                _controller.sink.add(typing);
                _removeTypeEvent(typing);
              })
              .catchError((err) => print(err))
              .onError((error, stackTrace) => print(error));
        });
  }

  TypingEvent _eventFromStream(feedData) {
    var data = feedData["new_val"];
    return TypingEvent.fromJson(data);
  }

  void _removeTypeEvent(TypingEvent event) {
    _r
        .table("typing_event")
        .get(event.id)
        .delete({"return_changes": false}).run(_connection);
  }
}
