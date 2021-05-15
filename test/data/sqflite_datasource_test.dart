// @dart = 2.9
import 'package:chat/chat.dart';
import 'package:chat_app/data/datasources/sqflite_datasource.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqlite_api.dart';

class MockSqfliteDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

void main() {
  SqfLiteDatasource sut;
  MockSqfliteDatabase database;
  MockBatch batch;

  setUp(() {
    database = MockSqfliteDatabase();
    batch = MockBatch();
    sut = SqfLiteDatasource(database);
  });

  final message = Message.fromJson({
    "from": "111",
    "to": "222",
    "content": "Hi",
    "timestamp": DateTime.now().toIso8601String(),
    "id": "4444",
  });

  test("should perform insert of chat to the database", () async {
    final chat = Chat("1234");

    when(database.insert(
      "chat",
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((_) async => 1);

    await sut.addChat(chat);

    verify(database.insert(
      "chat",
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test("should perform insert of message to the database", () async {
    final localMessage = LocalMessage("1234", message, ReceiptStatus.sent);

    when(database.insert(
      "message",
      localMessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).thenAnswer((_) async => 1);

    await sut.addMessage(localMessage);

    verify(database.insert(
      "message",
      localMessage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test("should perform a database query and return message", () async {
    final messageMap = [
      {
        "chat_id": "111",
        "id": "4444",
        "from": "111",
        "to": "222",
        "content": "hey",
        "receipt": "sent",
        "timestamp": DateTime.now().toIso8601String(),
      },
    ];

    when(database.query(
      "message",
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) async => messageMap);

    var messages = await sut.findMessage("111");

    expect(messages.length, 1);
    expect(messages.first.chatId, "111");
    verify(database.query(
      "message",
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).called(1);
  });

  test("should perform database update on messages", () async {
    final localMessage = LocalMessage("1234", message, ReceiptStatus.sent);

    when(database.update(
      "message",
      localMessage.toMap(),
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
    )).thenAnswer((_) async => 1);

    await sut.updateMessage(localMessage);

    verify(database.update(
      "message",
      localMessage.toMap(),
      where: anyNamed("where"),
      whereArgs: anyNamed("whereArgs"),
      conflictAlgorithm: ConflictAlgorithm.replace,
    )).called(1);
  });

  test("should perform database batch delete of chats", () async {
    final chatId = "111";

    when(database.batch()).thenReturn(batch);

    await sut.deleteChat(chatId);

    verifyInOrder(
      [
        database.batch(),
        batch.delete(
          "message",
          where: anyNamed("where"),
          whereArgs: [chatId],
        ),
        batch.delete(
          "chat",
          where: anyNamed("where"),
          whereArgs: [chatId],
        ),
        batch.commit(noResult: true),
      ],
    );
  });
}
