// ignore: import_of_legacy_library_into_null_safe
import 'package:rethinkdb_dart/rethinkdb_dart.dart';

Future<void> createDb(Rethinkdb r, Connection connection) async {
  await r.dbCreate('test').run(connection).catchError((err) => {});
  await r.tableCreate('user').run(connection).catchError((err) => {});
  await r.tableCreate('message').run(connection).catchError((err) => {});
  await r.tableCreate('receipt').run(connection).catchError((err) => {});
  await r.tableCreate('typing_event').run(connection).catchError((err) => {});
}

Future<void> cleanDb(Rethinkdb r, Connection connection) async {
  await r.table('user').delete().run(connection);
  await r.table('message').delete().run(connection);
  await r.table('receipt').delete().run(connection);
  await r.table('typing_event').delete().run(connection);
}
