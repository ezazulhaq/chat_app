// @dart=2.9
import 'package:chat/chat.dart';
import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:chat_app/viewmodels/base_view_model.dart';

class ChatsViewModel extends BaseViewModel {
  // ignore: unused_field
  IDataSource _dataSource;
  ChatsViewModel(IDataSource _datasource) : super(_datasource);

  Future<void> receivedMessage(Message message) async {
    LocalMessage localMessage =
        LocalMessage(message.from, message, ReceiptStatus.delivered);
    await addMessage(localMessage);
  }
}
