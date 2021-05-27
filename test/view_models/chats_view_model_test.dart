// @dart=2.9
import 'package:chat/chat.dart';
import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/viewmodels/chats_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDataSource extends Mock implements IDataSource {}

void main() {
  ChatsViewModel chatsViewModel;
  MockDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockDataSource();
    chatsViewModel = ChatsViewModel(mockDataSource);
  });

  final message = Message.fromJson({
    "from": "111",
    "to": "222",
    "contents": "hey",
    "timestamp": DateTime.now().toIso8601String(),
    "id": "444",
  });

  test("initial chats return empty List", () async {
    when(mockDataSource.findAllChats()).thenAnswer((_) async => []);
    expect(await chatsViewModel.getChats(), isEmpty);
  });

  test("return list is chats", () async {
    final chat = Chat("123");
    when(mockDataSource.findAllChats()).thenAnswer((_) async => [chat]);
    final chats = await chatsViewModel.getChats();
    expect(chats, isNotEmpty);
  });

  test("create new chat while receiving messages for the first time", () async {
    when(mockDataSource.findChat(any)).thenAnswer((_) async => null);
    await chatsViewModel.receivedMessage(message);
    verify(mockDataSource.addChat(any)).called(1);
  });

  test("Add new message to existing chat", () async {
    final chat = Chat("123");
    when(mockDataSource.findChat(any)).thenAnswer((_) async => chat);
    await chatsViewModel.receivedMessage(message);
    verifyNever(mockDataSource.addChat(any));
    verify(mockDataSource.addChat(any)).called(1);
  });
}
