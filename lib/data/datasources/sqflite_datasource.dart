import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:chat_app/models/chat.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class SqfLiteDatasource implements IDataSource {
  final Database _db;

  SqfLiteDatasource(this._db);

  @override
  Future<void> addChat(Chat chat) async {
    await _db.insert(
      "chat",
      chat.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> addMessage(LocalMessage message) async {
    await _db.insert(
      "message",
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteChat(String chatId) async {
    final batch = _db.batch();
    batch.delete("message", where: "chat_id = ?", whereArgs: [chatId]);
    batch.delete("chat", where: "id = ?", whereArgs: [chatId]);
    await batch.commit(noResult: true);
  }

  @override
  Future<List<Chat>> findAllChats() {
    return _db.transaction((txn) async {
      final chatwithLatestMessage = await txn.rawQuery(
        '''
        select message.* from 
        (
          select chat_id, max(created_at) as created_at
          from message
          group by chat_id
        )
        as latest_messages
        inner join message
        on message.chat_id = latest_messages.chat_id
        and message.created_at = latest_messages.created_at
        ''',
      );

      //setting NULL if chat doesn't exist
      if (chatwithLatestMessage.isEmpty) return [];

      final chatwithUnreadMessages = await txn.rawQuery(
        '''
        select chat_id, count(*) as unread
        from message
        where receipt = ?
        group by chat_id
        ''',
        ['delivered'],
      );

      return chatwithLatestMessage.map<Chat>((row) {
        final dynamic unread = chatwithUnreadMessages.firstWhere(
            (element) => row["chat_id"] == element["chat_id"],
            orElse: () => {"unread": 0})["unread"];

        final chat = Chat.fromMap(row);
        chat.unread = int.tryParse(unread)!;
        chat.mostRecent = LocalMessage.fromMap(row);

        return chat;
      }).toList();
    });
  }

  @override
  Future<Chat> findChat(String chatId) async {
    return await _db.transaction((txn) async {
      final listOfChatMaps = await txn.query(
        "chat",
        where: "id = ?",
        whereArgs: [chatId],
      );

      //setting NULL if chat doesn't exist
      if (listOfChatMaps.isEmpty) return Chat("");

      final unread = Sqflite.firstIntValue(await txn.rawQuery(
        '''
        select count(*) from message where chat_id = ? and receipt = ?
        ''',
        [chatId, 'delivered'],
      ));

      final mostrecentMessages = await txn.query(
        "message",
        where: "chat_id = ?",
        whereArgs: [chatId],
        orderBy: "created_at desc",
        limit: 1,
      );

      final chat = Chat.fromMap(listOfChatMaps.first);
      chat.unread = unread!;
      chat.mostRecent = LocalMessage.fromMap(mostrecentMessages.first);

      return chat;
    });
  }

  @override
  Future<List<LocalMessage>> findMessage(String chatId) async {
    final listOfMaps = await _db.query(
      "message",
      where: "chat_id = ?",
      whereArgs: [chatId],
    );

    return listOfMaps
        .map<LocalMessage>((map) => LocalMessage.fromMap(map))
        .toList();
  }

  @override
  Future<void> updateMessage(LocalMessage message) async {
    await _db.update(
      "message",
      message.toMap(),
      where: "id = ?",
      whereArgs: [message.message.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
