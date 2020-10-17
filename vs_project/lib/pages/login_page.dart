import 'dart:async';
import 'dart:convert';
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vs_project/sqlites/sqlite_con_me.dart' as dbb;
import 'package:vs_project/objects/me_object.dart';

String result = "Response comes here";

class Creds {
  final String response;

  Creds({this.response});

  factory Creds.fromJson(Map<String, dynamic> json) {
    return Creds(response: json['status']);
  }
}

bool _logincheck(Me me) {
  String responsee = "";
  Future<Creds> _futureAlbum = login(me.username, me.password, false);
  FutureBuilder<Creds>(
    future: _futureAlbum,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        responsee = snapshot.data.response;
      } else if (snapshot.hasError) {
        responsee = "${snapshot.error}";
      }

      return CircularProgressIndicator();
    },
  );

  if (responsee == "LOGGED IN") {
    return true;
  } else {
    return false;
  }
}

void _submitToSqlite(Me me){
  dbb.DBProvider.db.newMe(me);
}

bool _sqliteOK() {
  /*
  SQLITE
  return true;
  return false;
   */
  if (dbb.DBProvider.db.getMe() != null) {
    return true;
  } else {
    return false;
  }
}

String url = 'http://followerservicesp.hopto.org:8000/api/login/';
Future<Creds> login(String username, String password, bool isEmail) async {
  http.Response response;
  if (isEmail) {
    response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': username,
        'username': "",
        'password': password,
      }),
    );
  } else {
    response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': "",
        'username': username,
        'password': password,
      }),
    );
  }
  if (response.statusCode == 200) {
    // If the server did return a 200 CREATED response,
    // then parse the JSON.
    Me me = new Me.fromMap(json.decode(response.body));
    _submitToSqlite(me);
    return Creds.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 201 CREATED response,
    // then throw an exception.
    throw Exception('Something went bad');
  }
}

class MyStateFul extends StatefulWidget {
  MyStateFul({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _State createState() => _State();
}

class _State extends State<MyStateFul> {
  static final String _allowed = "";
  Future<Creds> _futureAlbum;
  String _username = "";
  String _password = "";

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void initState() {
    setState(() {
      if (_sqliteOK()) {
        //Go to the next page.
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/mainpage');
        });
      } else {
        //Login no user is in sqlite.
      }
    });
    super.initState();
  }

  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();

    _username = "";
    _password = "";
  }

  void resultt(bool ok, String response) {
    if (ok) {
      setState(() {
        result = "OK";
      });
    } else {
      setState(() {
        result = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                  fillColor: Colors.grey[350],
                  //border: InputBorder.none,
                  //focusedBorder: InputBorder.none,
                  //enabledBorder: InputBorder.none,
                  //errorBorder: InputBorder.none,
                  //disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Username,Email'),
              controller: usernameController,
            ),
            TextFormField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.visiblePassword,
              decoration: new InputDecoration(
                  fillColor: Colors.grey[350],
                  //border: InputBorder.none,
                  //focusedBorder: InputBorder.none,
                  //enabledBorder: InputBorder.none,
                  //errorBorder: InputBorder.none,
                  //disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Password'),
              controller: passwordController,
            ),
            RaisedButton(
              color: Colors.pink[300],
              child: Text(
                'login',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                String _username = usernameController.text;
                String _password = passwordController.text;

                bool isEmail = false;
                if ((_username.contains("@")) && (_username.contains("."))) {
                  isEmail = true;
                } else {
                  isEmail = false;
                }
                _futureAlbum = login(_username, _password, isEmail);
              },
            ),
            new Padding(padding: new EdgeInsets.fromLTRB(0, 10, 0, 0)),
            RaisedButton(
              color: Colors.yellow[400],
              child: Text(
                "Don't have an account? Sign up!",
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/register');
              },
            ),
            (_futureAlbum == null)
                ? Text('')
                : FutureBuilder<Creds>(
                    future: _futureAlbum,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, String> responsed= json.decode(snapshot.data.response);
                        if (responsed['status'] != "INVALID CREDENIALS"){Navigator.pushReplacementNamed(context, '/mainpage');}
                        return Text(responsed['status']);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }

                      return CircularProgressIndicator();
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
