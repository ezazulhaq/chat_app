import 'package:chat/src/model/user.dart';
import 'package:chat/src/services/user/user_service_contract.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

class UserService implements IUserService {
  final Rethinkdb r;
  final Connection _connection;

  UserService(this.r, this._connection);

  @override
  Future<User> connect(User user) async {
    var data = user.toJson();
    // ignore: unnecessary_null_comparison
    //if (user.id != null) {
    //data["id"] = user.id;
    //}

    final result = await r.table("user").insert(data, {
      "conflict": "update",
      "return_changes": true,
    }).run(_connection);

    return User.fromJson(result["changes"].first["new_val"]);
  }

  @override
  Future<void> disconnect(User user) async {
    await r.table("user").update({
      "id": user.id,
      "active": false,
      "lastseen": DateTime.now().toString()
    }).run(_connection);
    _connection.close();
  }

  @override
  Future<List<User>> online() async {
    Cursor users =
        await r.table("user").filter({"active": true}).run(_connection);
    final userList = await users.toList();

    return userList.map((items) => User.fromJson(items)).toList();
  }
}
