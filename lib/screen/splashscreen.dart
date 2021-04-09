import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/screen/login.dart';

class Splashscreen extends StatefulWidget {
  @override
  SplashscreenState createState() => SplashscreenState();
}

class SplashscreenState extends State<Splashscreen> {
  final storage = new FlutterSecureStorage();
  String firstRun, firstRunStorage;

  Future getFirstRun() async {
    String firstRunStorage = await storage.read(key: "firstRun");

    setState(() {
      firstRun = firstRunStorage;
    });

    if (firstRunStorage == "false") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      await storage.write(key: "firstRun", value: "false");
      var duration = const Duration(seconds: 4);
      return Timer(duration, () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFirstRun();
  }

  @override
  Widget build(BuildContext context) {
    if (firstRun == "false") {
      return null;
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            height: 100,
            child: Image.asset('./assets/img/logo_app.png'),
          ),
        ),
      );
    }
  }
}
