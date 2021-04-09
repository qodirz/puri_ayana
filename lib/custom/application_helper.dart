import 'package:flutter/material.dart';

final baseColor = Colors.cyan;
final baseColor50 = Colors.cyan[50];
final baseColor100 = Colors.cyan[100];
final baseColor200 = Colors.cyan[200];
final baseColor300 = Colors.cyan[300];
final baseColor400 = Colors.cyan[400];
final baseColor500 = Colors.cyan[500];
final baseColor600 = Colors.cyan[600];
final baseColor700 = Colors.cyan[700];
final baseColor800 = Colors.cyan[800];
final baseColor900 = Colors.cyan[900];

Widget customButton(text) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: Colors.lightBlue[800],
    ),
    child: Text(
      "$text",
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontFamily: 'bold',
      ),
    ),
  );
}

void customDialogWait(context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "Processing...",
          style: TextStyle(
            fontFamily: 'bold',
            color: Colors.lightBlue[800],
            fontSize: 12,
          ),
        ),
        content: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              LinearProgressIndicator(),
              SizedBox(height: 12),
              Text(
                "Please wait...",
                style: TextStyle(
                  fontFamily: 'bold',
                  color: Colors.lightBlue[800],
                  fontSize: 12,
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}

confirmDialogWithActions(title, content, actions, context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[for (var i in actions) i],
      );
    },
  );
}

Widget mainBg() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white,
          Colors.teal[100],
          Colors.white,
          Colors.teal[200],
        ],
      ),
    ),
  );
}

Widget circleBg() {
  return Stack(
    children: [
      Positioned(
        left: -100,
        top: -100,
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      Positioned(
        right: -100,
        bottom: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.green[50], baseColor100, Colors.green[50]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget logo() {
  return Column(
    children: [
      SizedBox(height: 60),
      Center(
        child: Container(
          width: 180,
          child: Image.asset('./assets/img/logo_puri.png'),
        ),
      ),
      SizedBox(height: 60),
    ],
  );
}
