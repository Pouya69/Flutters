import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:core';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vs_project/objects/me_object.dart';
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
      await db.execute("CREATE TABLE Me ("
          "username TEXT PRIMARY KEY,"
          "password TEXT,"
          "first_name TEXT,"
          "last_name TEXT,"
          "email TEXT,"
          "gender INTEGER,"
          "chatlist TEXT,"
          "friendlist TEXT,"
          "feelings TEXT"
          ")");
    });
  }

  newMe(Me newMe) async {
    final db = await database;
    //insert to the table using the new id
    var raw = await db.rawInsert(
        "INSERT Into Me (username,password,first_name,last_name,email,gender,chatlist,friendlist,feelings)"
        " VALUES (?,?,?,?,?,?,?,?,?)",
        [
          newMe.username,
          newMe.password,
          newMe.first_name,
          newMe.last_name,
          newMe.email,
          newMe.gender,
          newMe.chatlist,
          newMe.friendlist,
          newMe.feelings
        ]);
    return raw;
  }

  changeMe(Me oldme, Me newMe) async {
    final db = await database;
    var res = await db.update("Me", newMe.toMap(),
        where: "username = ?", whereArgs: [oldme.username]);
    return res;
  }

  /*updateMe(Me newClient) async {
    final db = await database;
    var res = await db.update("Me", newClient.toMap(),
        where: "username = ?", whereArgs: [newClient.username]);
    return res;
  }*/

  getMe() async {
    final db = await database;
    var res = await db.rawQuery("SELECT * FROM Me");
    return res.isNotEmpty ? Me.fromMap(res.first) : null;
  }

  getChatListMe() async {
    List<String> chatlist = [];
    final db = await database;
    var res = await db.rawQuery("SELECT chatlist FROM Me");
    if (res.isNotEmpty) {
      String result = res.toString();
      LineSplitter ls = new LineSplitter();
      chatlist = ls.convert(result);
    }
    return chatlist;
  }

  deleteMe(String username) async {
    final db = await database;
    return db.delete("Me", where: "username = ?", whereArgs: [username]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Me");
  }
}

/*Future<List<Me>> getAllClients() async {
    final db = await database;
    var res = await db.query("Me");
    List<Me> list =
        res.isNotEmpty ? res.map((c) => Me.fromMap(c)).toList() : [];
    return list;
  }*/
