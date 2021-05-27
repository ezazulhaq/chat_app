// @dart=2.9
import 'package:chat/chat.dart';
import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:chat_app/viewmodels/chat_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDataSource extends Mock implements IDataSource {}

void main() {
  ChatViewModel chatViewModel;
  MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    chatViewModel = ChatViewModel(mockDataSource);
  });

  final message = Message.fromJson({
    "from": "111",
    "to": "222",
    "contents": "hey",
    "timestamp": DateTime.now().toIso8601String(),
    "id": "444",
  });

  test("initial chats return empty List", () async {
    when(mockDataSource.findMessage(any)).thenAnswer((_) async => []);
    expect(await chatViewModel.getMessages("123"), isEmpty);
  });

  test("return list is messages from local storage", () async {
    final chat = Chat("123");
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.delivered);
    when(mockDataSource.findMessage(chat.id))
        .thenAnswer((_) async => [localMessage]);
    final messages = await chatViewModel.getMessages(chat.id);
    expect(messages, isNotEmpty);
    expect(messages.first.chatId, "123");
  });

  test("create new chat while sending messages for the first time", () async {
    when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
    await chatViewModel.sendMessage(message);
    verify(mockDataSource.addChat(any)).called(1);
  });

  test("Add new sent message to the chat", () async {
    final chat = Chat("123");
    final localMessage = LocalMessage(chat.id, message, ReceiptStatus.sent);
    when(mockDataSource.findMessage(chat.id))
        .thenAnswer((_) async => [localMessage]);

    await chatViewModel.getMessages(chat.id);
    await chatViewModel.sendMessage(message);

    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addMessage(any)).called(1);
  });

  test("Add new received message to the chat", () async {
    final chat = Chat("111");
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.delivered);
    when(mockDataSource.findMessage(chat.id))
        .thenAnswer((_) async => [localMessage]);
    when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => chat);

    await chatViewModel.getMessages(chat.id);
    await chatViewModel.receivedMessage(message);

    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addMessage(any)).called(1);
  });

  test("create a new chat when received message is not part of this chat",
      () async {
    final chat = Chat("123");
    final localMessage =
        LocalMessage(chat.id, message, ReceiptStatus.delivered);
    when(mockDataSource.findMessage(chat.id))
        .thenAnswer((_) async => [localMessage]);
    when(mockDataSource.findChat(chat.id)).thenAnswer((_) async => chat);

    await chatViewModel.getMessages(chat.id);
    await chatViewModel.receivedMessage(message);

    verify(mockDataSource.addChat(any)).called(1);
    verify(mockDataSource.addMessage(any)).called(1);
    expect(chatViewModel.otherMessages, 1);
  });
}
