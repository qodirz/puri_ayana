import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  String accessToken, uid, expiry, client, role;

  getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");     
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    String roleStorage = await storage.read(key: "role");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      role = roleStorage;
    });

    print("ROLEEE");
    print(role);
  }
  
  _logOut(){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Warning"),
          content: Text("Are you sure want sign out?"),
          actions: <Widget>[
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("No")),
            FlatButton(
                onPressed: () {
                  signOut();
                },
                child: Text("Yes")),
          ],
        );
      }
    );
  }

  signOut() async {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Processing.."),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox( height: 16, ),
              Text("Please wait...")
            ],
          ),
        );
      }
    );
    
    final response = await http.delete(NetworkURL.logOut(), 
    headers: <String, String>{ 
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
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), 
      (Route<dynamic> route) => false);      
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Logout failed."),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Ok"),
              ),
            ],
          );
        }
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }
	@override
	Widget build(BuildContext context) {
		return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.green,         
        title: Text("Akun", style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'mon')),
        centerTitle: true,
      ),
      body: new Container(  
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  cardList('PROFIL', "profile", context),
                  cardList('UBAH PASSWORD', "update_password", context),
                  if (role == "2" || role == "3") cardList('BUAT USER BARU', "new_user", context),
                  ListTile(  
                    tileColor: Colors.redAccent,
                    title: Text(
                      "LOG OUT", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, fontFamily: "mon"),
                    ),
                    onTap: () {
                      _logOut();                        
                    }
                  ),
                ],
              ),
            ),
          ],
        )
      ),
		);
	}
}

Widget cardList(title, page, context) {
  return Column(
    children: [
      ListTile(  
        tileColor: Colors.green[50],
        title: Text(
          title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "mon"),
        ),
        trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green,),
        onTap: () {
          print(page);
          if (page == "profile"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));  
          }else if(page == "update_password"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => UpdatePasswordPage()));
          }else if(page == "new_user"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NewUserPage()));
          }
        }
      ),
      Divider(height: 1, color: Colors.green,)
    ]  
  );
}
