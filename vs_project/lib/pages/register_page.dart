import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utilities/things.dart' as things;

class Creds {
  final String response;

  Creds({this.response});

  factory Creds.fromJson(Map<String, dynamic> json) {
    return Creds(response: json['status']);
  }
}

String url = things.siteURL() + 'register/';

Future<Creds> register(
  String username,
  String password,
  String email,
  String gender,
  String age,
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
      'date_of_birth': age,
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

class MyStateFulR extends StatefulWidget {
  MyStateFulR({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _State createState() => _State();
}

class _State extends State<MyStateFulR> {

  showAlertDialog(BuildContext context, String mTitle, String mContent, String buttonText) {

    // set up the button
    Widget okButton = FlatButton(
      child: Text(buttonText),
      onPressed: () { 
        if (mTitle == "Verification"){
          Navigator.of(context).pushReplacementNamed('/loginpage');
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(mTitle),
      content: Text(mContent),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;

      switch (_radioValue) {
        case 0:
          _gender = 'true';
          break;
        case 1:
          _gender = 'false';
          break;
      }
    });
  }

  int _radioValue = 0;
  @override
  void initState() {
    setState(() {
      _radioValue = 0;
    });
    super.initState();
  }

  Future<Creds> _futureAlbum;

  String _username = "";
  String _password = "";
  String _email = "";
  String _gender = 'false';
  String _age = "";

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();

  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    passwordController.dispose();
    ageController.dispose();
    emailController.dispose();
    super.dispose();

    _username = "";
    _password = "";
    _email = "";
    _gender = 'true';
    _age = "";
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
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Username'),
              controller: usernameController,
            ),
            TextFormField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                  fillColor: Colors.grey[350],
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Email'),
              controller: emailController,
            ),
            TextFormField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.name,
              decoration: new InputDecoration(
                  fillColor: Colors.grey[350],
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Age'),
              controller: ageController,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              new Radio(
                value: 0,
                groupValue: _radioValue,
                onChanged: _handleRadioValueChange,
              ),
              new Text('male'),
              new Padding(padding: new EdgeInsets.fromLTRB(5, 0, 0, 0)),
              new Radio(
                value: 1,
                groupValue: _radioValue,
                onChanged: _handleRadioValueChange,
              ),
              new Text('female'),
            ]),
            TextFormField(
              cursorColor: Colors.black,
              keyboardType: TextInputType.visiblePassword,
              decoration: new InputDecoration(
                  fillColor: Colors.grey[350],
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: 'Password'),
              controller: passwordController,
            ),
            RaisedButton(
              color: Colors.pink[300],
              child: Text(
                'Register',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                String _username = usernameController.text;
                String _password = passwordController.text;
                String _email = passwordController.text;
                String _age = passwordController.text;
                _futureAlbum =
                    register(_username, _password, _email, _gender, _age);
              },
            ),
            new Padding(padding: new EdgeInsets.fromLTRB(0, 10, 0, 0)),
            RaisedButton(
              color: Colors.yellow[400],
              child: Text(
                "Already have an account? Login!",
                style: TextStyle(color: Colors.black54),
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            (_futureAlbum == null)
                ? Text('')
                : FutureBuilder<Creds>(
                    future: _futureAlbum,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, String> responsed = json.decode(snapshot.data.response);
                        String mTitle = "", mContent = "", buttonText = "";
                        if (responsed['status'] == 'REGISTER OK'){
                          mTitle = "Verification";
                          mContent = "Your account is created. Please verify your account with the link we sent to your email.";
                          buttonText = "Of Course!";
                        }else{
                          mTitle = "Failed";
                          mContent = "Failed to create the account : \n" + responsed['status'] ;
                          buttonText = "Ooh..";
                        }
                        showAlertDialog(context, mTitle, mContent, buttonText);
                        return Text(snapshot.data.response);
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
