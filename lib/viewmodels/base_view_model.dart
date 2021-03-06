// @dart=2.9
import 'package:chat_app/data/datasources/datasource_contract.dart';
import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/local_message.dart';
import 'package:flutter/material.dart';

abstract class BaseViewModel {
  IDataSource _datasource;
  BaseViewModel(this._datasource);

  @protected
  Future<void> addMessage(LocalMessage message) async {
    if (!(await _isExistingChat(message.chatId)))
      await _createNewChat(message.chatId);
    await _datasource.addMessage(message);
  }

  Future<bool> _isExistingChat(String chatId) async {
    return (await _datasource.findChat(chatId) != null ||
        // ignore: unrelated_type_equality_checks
        await _datasource.findChat(chatId) != "");
  }

  Future<void> _createNewChat(String chatId) async {
    final chat = Chat(chatId);
    await _datasource.addChat(chat);
  }
}
