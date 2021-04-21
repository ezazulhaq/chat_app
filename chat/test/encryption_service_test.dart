// @dart = 2.9
import 'package:chat/src/services/encryption/encruption_service.dart';
import 'package:chat/src/services/encryption/encryption_service_contract.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IEncryption encryptionService;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    encryptionService = EncryptionService(encrypter);
  });

  test("it encrypts plain text", () {
    final text = "this is a message";
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

    final encrypted = encryptionService.encrypt(text);
    expect(base64.hasMatch(encrypted), true);
  });

  test('it decrypts plain text', () {
    final text = "this is a message";
    final encrypted = encryptionService.encrypt(text);

    final decrypted = encryptionService.decrypt(encrypted);
    expect(decrypted, text);
  });
}
