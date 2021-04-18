// @dart = 2.9
import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/user/user_service.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

import 'helper.dart';

void main() {
  Rethinkdb r = Rethinkdb();
  Connection connection;
  UserService userService;

  setUp(() async {
    connection = await r.connect(host: "127.0.0.1", port: 28015);
    await createDb(r, connection);
    userService = UserService(r, connection);
  });

  tearDown(() async {
    //await cleanDb(r, connection);
  });

  test("Creates a New User Document in Database", () async {
    final user = User(
      username: "test",
      photourl: "url",
      active: true,
      lastseen: DateTime.now().toString(),
    );

    final userWithId = await userService.connect(user);
    expect(userWithId.id, isNotEmpty);
  });

  test("Get Online Users", () async {
    final user = User(
      username: "test",
      photourl: "url",
      active: true,
      lastseen: DateTime.now().toString(),
    );

    await userService.connect(user);

    final users = await userService.online();
    //expect(users.length, 1);
  });
}
