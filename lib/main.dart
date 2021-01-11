import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var isLoggedIn = (prefs.getString("accessToken") == null) ? false : true;
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: isLoggedIn ? Menu() : Login(),
  ));
}
