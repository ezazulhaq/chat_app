// @dart = 2.9
import 'package:chat/src/model/message.dart';
import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/message/message_service.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  MessageService messageService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    messageService = MessageService(r, connection);
  });

  tearDown(() async {
    messageService.dispose();
    await cleanDb(r, connection);
  });

  final user1 = User.fromJson({
    "id": "111",
    "active": true,
    "timestamp": DateTime.now().toString(),
  });

  final user2 = User.fromJson({
    "id": "222",
    "active": true,
    "timestamp": DateTime.now().toString(),
  });

  test("Sent Message Succefully", () async {
    Message message = Message(
      from: user1.id,
      to: "333",
      timestamp: DateTime.now().toString(),
      content: "this is a message",
    );

    final result = await messageService.send(message);
    expect(result, true);
  });

  test("Successfully Subscribe and Receive Messages", () async {
    messageService.messages(activeUser: user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
        }, count: 2));

    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now().toString(),
      content: "this is message",
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now().toString(),
      content: "this is another message",
    );

    await messageService.send(message1);
    await messageService.send(message2);
  });

  test("Successfully Subscribe and Receive New Messages", () async {
    Message message1 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now().toString(),
      content: "this is message",
    );

    Message message2 = Message(
      from: user1.id,
      to: user2.id,
      timestamp: DateTime.now().toString(),
      content: "this is another message",
    );

    await messageService.send(message1);
    await messageService.send(message2).whenComplete(
          () => messageService.messages(activeUser: user2).listen(
                expectAsync1(
                  (message) {
                    expect(message.to, user2.id);
                  },
                  count: 2,
                ),
              ),
        );
  });
}
