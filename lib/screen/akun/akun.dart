import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/akun/new_user.dart';
import 'package:puri_ayana_gempol/screen/akun/profile.dart';
import 'package:puri_ayana_gempol/screen/akun/update_password.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:http/http.dart' as http;

class AkunPage extends StatefulWidget {
  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  final storage = new FlutterSecureStorage();
  TextEditingController emailController = TextEditingController();
  String accessToken, uid, expiry, client, role, headFamily;

  getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    String roleStorage = await storage.read(key: "role");
    String headFamilyStorage = await storage.read(key: "headFamily");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      role = roleStorage;
      headFamily = headFamilyStorage;
    });
  }

  _logOut() {
    Widget yesButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.blue,
        side: BorderSide(color: Colors.blue),
      ),
      onPressed: () {
        signOut();
      },
      child: Text('Ya'),
    );

    Widget noButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
        side: BorderSide(color: Colors.red),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text('Tidak'),
    );

    confirmDialogWithActions("Logout", "Apakah anda yakin akan log out?",
        [noButton, yesButton], context);
  }

  signOut() async {
    Navigator.pop(context);
    customDialogWait(context);

    final response =
        await http.delete(NetworkURL.logOut(), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    });
    final data = jsonDecode(response.body);

    if (data['success'] == true) {
      await storage.deleteAll();
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Login()),
          (Route<dynamic> route) => false);
    } else {
      Navigator.pop(context);
      Widget okButton = OutlinedButton(
        style: OutlinedButton.styleFrom(
            primary: Colors.cyan,
            backgroundColor: Colors.cyan[100],
            side: BorderSide(color: Colors.cyan)),
        onPressed: () => Navigator.pop(context),
        child: Text('ok'),
      );

      confirmDialogWithActions("Logout", 'Logout failed.', [okButton], context);
    }
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: baseColor,
        title: Text("Akun", style: TextStyle(fontSize: 30, fontFamily: 'bold')),
        centerTitle: true,
      ),
      body: new Container(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                cardList(
                  'PROFIL',
                  "profile",
                  Icons.account_box_outlined,
                  Colors.lightBlue[50],
                  Colors.lightBlue[200],
                  context,
                ),
                cardList(
                  'UBAH PASSWORD',
                  "update_password",
                  Icons.star_rate_outlined,
                  Colors.orange[50],
                  Colors.orange[200],
                  context,
                ),
                if ((role == "1" && headFamily == "true") || role == "2")
                  cardList(
                    'BUAT USER BARU',
                    "new_user",
                    Icons.add_rounded,
                    Colors.green[50],
                    Colors.green[200],
                    context,
                  ),
                Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.red[300]),
                    borderRadius: BorderRadius.all(Radius.circular(18)),
                    color: Colors.red[50],
                  ),
                  child: ListTile(
                    dense: true,
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Colors.red[300],
                      ),
                      child: Icon(
                        Icons.logout,
                        size: 30,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      "LOG OUT",
                      style:
                          TextStyle(fontFamily: 'bold', color: Colors.red[300]),
                    ),
                    onTap: () {
                      _logOut();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

Widget cardList(title, page, IconData icon, bgColor, textColor, context) {
  return Container(
    padding: EdgeInsets.all(2),
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(color: textColor),
      borderRadius: BorderRadius.all(Radius.circular(18)),
      color: bgColor,
    ),
    child: ListTile(
      dense: true,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: textColor,
        ),
        child: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'bold', color: textColor),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: textColor,
      ),
      onTap: () {
        if (page == "profile") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => ProfilePage()));
        } else if (page == "update_password") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => UpdatePasswordPage()));
        } else if (page == "new_user") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => NewUserPage()));
        }
      },
    ),
  );
}
