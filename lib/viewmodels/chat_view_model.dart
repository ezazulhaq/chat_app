// @dart=2.9
import 'package:chat/chat.dart';
import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:chat_app/viewmodels/base_view_model.dart';

class ChatViewModel extends BaseViewModel {
  // ignore: unused_field
  IDdataSource _dataSource;
  String _chatId = "";
  int otherMessages = 0;

  ChatViewModel(IDdataSource _datasource) : super(_datasource);

  Future<List<LocalMessage>> getMessages(String chatId) async {
    final messages = await _dataSource.findMessage(chatId);
    if (messages.isNotEmpty) _chatId = chatId;
    return messages;
  }

  Future<void> sendMessage(Message message) async {
    LocalMessage localMessage =
        LocalMessage(message.to, message, ReceiptStatus.sent);
    if (_chatId.isNotEmpty) return await _dataSource.addMessage(localMessage);
    _chatId = localMessage.chatId;
    await addMessage(localMessage);
  }

  Future<void> receivedMessage(Message message) async {
    LocalMessage localMessage =
        LocalMessage(message.from, message, ReceiptStatus.delivered);
    if (localMessage.chatId != _chatId) otherMessages++;
    await addMessage(localMessage);
  }
}
