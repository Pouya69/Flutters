import 'dart:async';
import 'dart:convert';
//import 'package:file_picker/file_picker.dart';
//import 'dart:io';
import 'package:http/http.dart' as http;

import '../utilities/things.dart' as things;
import '../sqlites/sqlite_con_messages.dart' as msg_sql;
import '../objects/message_object.dart';
import 'package:flutter/material.dart';

String groupName = "";

class ResponseStatus {
  String response;

  ResponseStatus({this.response});

  factory ResponseStatus.fromJson(Map<String, dynamic> json) {
    return ResponseStatus(
      response: json['status'],
    );
  }
}

Future<Message> sendMessage(
    String replyingTo, String fileURL, String creator, String message) async {
  http.Response response;
  response = await http.post(
    //WEBSOCKET AND STUFF
    things.siteURL() + 'messages/',
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'creator': creator,
      'content': message,
      'replying_to': replyingTo,
      'file': fileURL,
    }),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.

    //_State().resultt(true, code);
    return Message.fromMap(json.decode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.

    //_State().resultt(false, code);
    throw Exception('Something went bad');
  }
}

// Get chat image

String getChatImage() {
  String urlIMAGE = things.storageURL() + groupName;
  return urlIMAGE;
}

String getImageURL() {
  //Return the image
  return "";
}

// ---> WORK IN PROGRESS : Upload a file to online storage and then get the url and send the fileURL as a url.

// Also get the chat_id from the previous page.

// Get chats from SQLite and show in the list and also fetch messages from the server.

class ChatPage extends StatefulWidget {
  String title;
  ChatPage({Key key, this.title}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _message = "";
  final messageController = TextEditingController();

  List<String> getMessages() {}

  void setMessage() {
    setState(() {
      _message = messageController.text;
    });
  }

  void prep_message() {
    String _creator = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        title: Row(
          children: <Widget>[
            Container(
              width: 50,
              height: 50,
              color: Colors.black,
              child: Image.network(getChatImage(), fit: BoxFit.cover),
            ),
            new Padding(padding: new EdgeInsets.fromLTRB(10, 0, 0, 0)),
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //The list and the textbox and send button and stuff.
          Row(
            children: [
              RaisedButton(
                onPressed: () {
                  //Pick image and stuff
                },
                child: Image(
                  image: AssetImage('assets/attachment.png'),
                  width: 15,
                  height: 15,
                ),
              ),
              TextFormField(
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.blue,
                keyboardType: TextInputType.multiline,
                decoration: new InputDecoration(
                    fillColor: Colors.black,
                    //border: InputBorder.none,
                    //focusedBorder: InputBorder.none,
                    //enabledBorder: InputBorder.none,
                    //errorBorder: InputBorder.none,
                    //disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                        left: 15, bottom: 11, top: 11, right: 15),
                    hintText: 'Message'),
                controller: messageController,
              ),
              new Padding(padding: new EdgeInsets.fromLTRB(3, 0, 0, 0)),
              FlatButton(
                onPressed: () {
                  prep_message();
                },
                child: Text(
                  'Send',
                  style: TextStyle(color: Colors.green[600], fontSize: 15),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
