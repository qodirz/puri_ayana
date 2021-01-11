import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/akun/new_user.dart';
import 'package:puri_ayana_gempol/screen/akun/profile.dart';
import 'package:puri_ayana_gempol/screen/akun/update_password.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AkunPage extends StatefulWidget {
  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
	GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController emailController = TextEditingController();
  String accessToken, uid, expiry, client, name, phoneNumber, picBlok;
  int role, addressId;
  
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");

      name = pref.getString("name");
      phoneNumber = pref.getString("phoneNumber");
      role = pref.getInt("role");
      addressId = pref.getInt("addressId");
      picBlok = pref.getString("picBlok");
    }); 
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
      print("sukses logout");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();    
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
          });
    }
  }

  @override
  void initState() {
    super.initState();
    getPref();    
  }
	@override
	Widget build(BuildContext context) {
		return new Scaffold(
      resizeToAvoidBottomInset: false, 
			key: _scaffoldKey,
      body: new Container(       
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,                
                    children: <Widget>[backgroundHeader()],
                  ),
                  SizedBox(height: 10),                  
                  cardList('PROFIL', "profile", true, context),
                  cardList('UBAH PASSWORD', "update_password", true, context),
                  if(role == 2) cardList('BUAT USER BARU', "new_user", true, context),
                  Card(    
                    color: Colors.red[200],
                    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                    elevation: 10,
                    child: ListTile(  
                      title: Text(
                        "LOG OUT",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, fontFamily: "mon"),
                      ),
                      onTap: () {
                        _logOut();                        
                      }
                    ),
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

Widget backgroundHeader() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.green[100], Colors.green[200] ]),
    ),
    height: 90,
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Akun",
            style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'mon'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget cardList(title, page, trailing, context) {
  return Card(    
    color: Colors.green[50],
    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
    elevation: 10,
    child: ListTile(  
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "mon"),
      ),
      trailing: trailing ? Icon(Icons.chevron_right, size: 26,) : null,
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
  );
}
