import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vs_project/objects/chat_object.dart';
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
      await db.execute("CREATE TABLE Chats ("
          "group_id TEXT PRIMARY KEY NOT NULL,"
          "userslist TEXT,"
          "group_name TEXT,"
          "group_key TEXT,"
          ")");
    });
  }

  newChat(Chat newChat) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Chats (group_id,userlist,group_name,group_key)"
        " VALUES (?,?,?,?)",
        [
          newChat.group_id,
          newChat.userlist,
          newChat.group_name,
          newChat.group_key,
        ]);
    return raw;
  }

  changeChat(String id, Chat newChat) async {
    final db = await database;
    var res = await db.update("Chats", newChat.toMap(),
        where: "group_id = ?", whereArgs: [id]);
    return res;
  }

  /*updateMe(Me newClient) async {
    final db = await database;
    var res = await db.update("Me", newClient.toMap(),
        where: "username = ?", whereArgs: [newClient.username]);
    return res;
  }*/

  getChat(String id) async {
    final db = await database;
    var res = await db.query("Chats", where: "group_id = ?", whereArgs: [id]);
    return res.isNotEmpty ? Chat.fromMap(res.first) : null;
  }

  getUsersList() async {
    List<String> userslist = [];
    final db = await database;
    var res = await db.rawQuery("SELECT userslist FROM Chats");
    //var res = await db.query("Me", where: "chatlist = ? ", whereArgs: [1]);
    if (res.isNotEmpty) {
      String result = res.toString();
      LineSplitter ls = new LineSplitter();
      userslist = ls.convert(result);
    }
    return userslist;
  }

  deleteChat(String id) async {
    final db = await database;
    return db.delete("Chats", where: "group_id = ?", whereArgs: [id]);
  }

  deleteAllChats() async {
    final db = await database;
    db.rawDelete("Delete * from Chats");
  }
}

/*Future<List<Me>> getAllClients() async {
    final db = await database;
    var res = await db.query("Me");
    List<Me> list =
        res.isNotEmpty ? res.map((c) => Me.fromMap(c)).toList() : [];
    return list;
  }*/
