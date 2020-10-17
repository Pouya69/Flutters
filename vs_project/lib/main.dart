import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/main_page.dart';
import 'pages/chat_page.dart';

void main() {
  runApp(App1());
}

class App1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEMO ME',
      theme: ThemeData(primaryColor: Colors.green),
      initialRoute: '/loginpage',
      routes: {
        '/mainpage': (context) => mainPage(),
        // When navigating to the "/" route, build the FirstScreen widget.
        '/loginpage': (context) => MyStateFul(
              title: 'Login',
            ),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/register': (context) => MyStateFulR(
              title: 'Register',
            ),
        '/chat': (context) => MyStateFulR(),
        //'/mainpage': (context) => MyStateFulR(),
      },
    );
  }
}
