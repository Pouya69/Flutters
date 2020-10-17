import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vs_project/objects/message_object.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Messages ("
          "message_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
          "group_id INTEGER PRIMARY KEY,"
          "creator TEXT,"
          "message TEXT,"
          "replying_to TEXT,"
          "is_read INTEGER,"
          "file TEXT"
          ")");
    });
  }

  newMessage(Message newMessage) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Messages (group_id,creator,message,replying_to,is_read,file)"
        " VALUES (?,?,?,?,?,?)",
        [
          newMessage.group_id,
          newMessage.creator,
          newMessage.message,
          newMessage.replying_to,
          newMessage.is_read,
          newMessage.file,
        ]);
    return raw;
  }

  changeMessage(Message oldChat, Message newChat) async {
    final db = await database;
    var res = await db.update("Messages", newChat.toMap(),
        where: "group_id = ?", whereArgs: [oldChat.group_id]);
    return res;
  }

  /*updateMe(Me newClient) async {
    final db = await database;
    var res = await db.update("Me", newClient.toMap(),
        where: "username = ?", whereArgs: [newClient.username]);
    return res;
  }*/

  getMessage(String id) async {
    final db = await database;
    var res =
        await db.query("Messages", where: "message_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Message.fromMap(res.first) : null;
  }

  getMessageList(String id) async {
    List<String> messageList = [];
    final db = await database;
    var res =
        await db.query("Messages", where: "group_id = ?", whereArgs: [id]);
    //var res = await db.query("Me", where: "chatlist = ? ", whereArgs: [1]);
    if (res.isNotEmpty) {
      String result = res.toString();
      LineSplitter ls = new LineSplitter();
      messageList = ls.convert(result);
    }
    return messageList;
  }

  deleteMessage(String id) async {
    final db = await database;
    return db.delete("Messages", where: "message_id = ?", whereArgs: [id]);
  }

  deleteAllChats() async {
    final db = await database;
    db.rawDelete("Delete * from Messages");
  }

  deleteAllChatsFromChat(String id) async {
    final db = await database;
    return db.delete("Messages", where: "group_id = ?", whereArgs: [id]);
  }
}

/*Future<List<Me>> getAllClients() async {
    final db = await database;
    var res = await db.query("Me");
    List<Me> list =
        res.isNotEmpty ? res.map((c) => Me.fromMap(c)).toList() : [];
    return list;
  }*/
