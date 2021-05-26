import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/local_message.dart';

abstract class IDataSource {
  Future<void> addChat(Chat chat);
  Future<void> addMessage(LocalMessage message);
  Future<Chat> findChat(String chatId);
  Future<List<Chat>> findAllChats();
  Future<void> updateMessage(LocalMessage message);
  Future<List<LocalMessage>> findMessage(String chatId);
  Future<void> deleteChat(String chatId);
}
