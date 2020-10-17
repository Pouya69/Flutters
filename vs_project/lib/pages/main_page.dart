import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../utilities/things.dart' as things;
import '../sqlites/sqlite_con_me.dart' as me_sql;
import 'dart:async';
import 'dart:convert';
import '../sqlites/sqlite_con_chats.dart' as chat_sql;
import '../objects/chat_object.dart' as chat_obj;

var channel;
String url = things.siteURL() + 'users/';
List<chat_obj.Chat> mList = <chat_obj.Chat>[];

class Creds {
  final String response;

  Creds({this.response});

  factory Creds.fromJson(Map<String, dynamic> json) {
    return Creds(response: json['groups']);
  }
}

Future<Creds> register(
    String username,
    String password,
    String email,
    String gender,
    ) async {
  http.Response response;
  response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'email': email,
      'username': username,
      'password': password,
      'gender': gender.toString(),
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    return Creds.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Something went bad');
  }
}


class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  void syncDBChatWithInternet() async {
    channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
    mList = me_sql.DBProvider.db.getChatListMe();
    channel.stream.listen((receivedMessage) {
      final obj = chat_obj.Chat.fromMap(receivedMessage);
      stateCHAT(obj);
      addChatToDatabase(obj);
      //list.add(receivedMessage);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    syncDBChatWithInternet();
  }

  void _goToChatPage(chat_obj.Chat chat, BuildContext context) {
    Navigator.pushNamed(context, '/chatpage', arguments: chat);
  }

  void addChatToDatabase(chat_obj.Chat chat) async{
    if (chat_sql.DBProvider.db.getChat(chat.group_id.toString()) != null){
      chat_sql.DBProvider.db.newChat(chat);
    }else {
      chat_sql.DBProvider.db.changeChat(chat.group_id, chat);
    }
  }

  List<String> stateCHAT(chat_obj.Chat item) {
    if (!(mList.contains(item))) {
      setState(() {
        mList.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[300],
        title: Text(
          'Chats',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ListView.builder(
              itemCount: mList.length,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) {
                //addItem(context, snapshot.data.chat),
                return ListTile(
                  title: Text(mList[index].group_name),
                  onTap: () {
                    _goToChatPage(mList[index], context);
                  },
                );
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Find User Page
          Navigator.pushNamed(context, '/finduser');
        },
        child: Icon(
          Icons.add,
          color: Colors.red[800],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

}
