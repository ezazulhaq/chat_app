import 'package:chat/src/model/message.dart';
import 'package:chat/src/model/user.dart';

abstract class IMessageService {
  Future<bool> send(Message message);
  Stream<Message> messages({required User activeUser});
  dispose();
}
