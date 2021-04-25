import 'package:chat/src/model/receipt.dart';
import 'package:chat/src/model/user.dart';

abstract class IReceiptService {
  Future<bool> send(Receipt receipt);
  Stream<Receipt> receipts(User user);
  void dispose();
}
