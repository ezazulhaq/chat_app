// @dart = 2.9
import 'package:chat/src/model/typing.dart';
import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/typing/typing_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;

  TypingNotificationService typingService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    typingService = TypingNotificationService(r, connection);
  });

  tearDown(() async {
    typingService.dispose();
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    "id": "1111",
    "active": true,
    "lastseen": DateTime.now().toIso8601String()
  });

  final user2 = User.fromJson({
    "id": "2222",
    "active": true,
    "lastseen": DateTime.now().toIso8601String()
  });

  test("Sent Type Notification Successfully", () async {
    TypingEvent event =
        TypingEvent(from: user2.id, to: user1.id, event: Typing.start);

    final res = await typingService.send(event, user1);
    expect(res, true);
  });

  test("Successfully Subscribe and Receive Typing Events", () async {
    typingService.subscribe(user1, [user2.id]).listen(expectAsync1((event) {
      expect(event.from, user2.id);
    }, count: 2));

    TypingEvent startEvent = TypingEvent(
      from: user2.id,
      to: user1.id,
      event: Typing.start,
    );

    TypingEvent stopEvent = TypingEvent(
      from: user2.id,
      to: user1.id,
      event: Typing.stop,
    );

    await typingService.send(startEvent, user1);
    await typingService.send(stopEvent, user1);
  });
}
