import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import '../utilities/things.dart' as things;
import '../sqlites/sqlite_con_me.dart' as me_sql;
import '../sqlites/sqlite_con_chats.dart' as chat_sql;
import '../objects/chat_object.dart' as chat_obj;

var channel;
List<chat_obj.Chat> chats = <chat_obj.Chat>[];

class mainPage extends StatefulWidget {
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  void syncDBChatWithInternet() async {
    channel = IOWebSocketChannel.connect('ws://echo.websocket.org');
    chats = me_sql.DBProvider.db.getChatListMe();
    channel.stream.listen((receivedMessage) {
      final obj = chat_obj.Chat.fromMap(receivedMessage);
      stateCHAT(obj, chats);
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

  bool addChatToDatabase(chat_obj.Chat chat){
    if (chat_sql.DBProvider.db.getChat(chat.group_id.toString()) != null){
      chat_sql.DBProvider.db.newChat(chat);
      return true;
    }else {
      chat_sql.DBProvider.db.changeChat(chat.group_id, chat);
      return false;
    }
  }

  List<String> stateCHAT(chat_obj.Chat item, List<chat_obj.Chat> mList) {
    if (!(mList.contains(item))) {
      setState(() {
        mList.add(item);
        if(!(chats.contains(item))){
          chats.add(item);
        }
        return mList;
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
              itemCount: chats.length,
              padding: EdgeInsets.all(10.0),
              itemBuilder: (BuildContext context, int index) {
                //addItem(context, snapshot.data.chat),
                return ListTile(
                  title: Text(chats[index].group_name),
                  onTap: () {
                    _goToChatPage(chats[index], context);
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
