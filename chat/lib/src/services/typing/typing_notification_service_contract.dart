import 'package:chat/src/model/typing.dart';
import 'package:chat/src/model/user.dart';

abstract class ITypingNotification {
  Future<bool> send(TypingEvent event, User to);
  Stream<TypingEvent> subscribe(User user, List<String> userIds);
  void dispose();
}
