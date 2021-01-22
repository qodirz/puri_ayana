import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/screen/forgot_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puri_ayana_gempol/model/loginModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> { 
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LoginModel loginModel;
  UserModel userModel;
  String accessToken;
  final firebaseMessaging = FirebaseMessaging();
  String deviceType, deviceToken;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");

      accessToken != null ? 
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu())) : null;
    });
  }

  var obSecure = true;
  final _key = GlobalKey<FormState>();

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }    
  }

  submit() async {
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
            Text("Mohon Tunggu...")
          ],
        ),
      );
    });

    await firebaseMessaging.getToken().then((token) => setState(() {
      this.deviceToken = token;
    }));
    if (Platform.isIOS) {
      deviceType = "iphone";
    } else if (Platform.isAndroid) {
      deviceType = "android";
    }
    final response = await http.post(NetworkURL.login(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
    },body: jsonEncode(<String, String>{        
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "device_token": deviceToken,
      "device_type": deviceType  
    }));
    
    final responJson = json.decode(response.body);
    Navigator.pop(context);
    if (response.headers['access-token'] != null) {
      
      loginModel = LoginModel.api(response.headers);
      userModel = UserModel.fromJson(responJson["me"]);

      savePref(
        loginModel.accessToken,
        loginModel.uid,    
        loginModel.expiry,    
        loginModel.client,
        userModel.email, 
        userModel.name, 
        userModel.phoneNumber, 
        userModel.role, 
        userModel.addressId, 
        userModel.picBlok, 
        responJson["avatar"],
        responJson["has_debt"]
      );
      FocusScope.of(context).requestFocus(new FocusNode());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu()));
    } 
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(responJson['message']),
          actions: <Widget>[
            FlatButton(
              onPressed: () => {
                Navigator.pop(context)
              },
              child: Text("Ok"),
            ),
          ],
        );
      }
    );
  }

  savePref(
    String accessToken, uid, expiry, client,
    String email, name, phoneNumber, role, addressId, picBlok, avatar, hasDebt
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      pref.setString("accessToken", accessToken);
      pref.setString("uid", uid);
      pref.setString("expiry", expiry);
      pref.setString("client", client);
      
      pref.setString("email", email);
      pref.setString("name", name);
      pref.setString("phoneNumber", phoneNumber);
      pref.setInt("role", role);
      pref.setInt("addressId", addressId);
      pref.setString("picBlok", picBlok);
      pref.setString("avatar", avatar);
      pref.setBool("hasDebt", hasDebt);
    });
  }

  @override
  void initState() {    
    super.initState();
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[                
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[
                      SizedBox(height: 90,),
                      Center(
                        child: Column(
                          children: <Widget>[                             
                            Container(
                              width: 240,
                              child: Image.asset('./assets/img/logo_puri.png'),
                            ),
                        ],)
                      ),
                      SizedBox(height: 80,),
                      EmailField(controller: emailController, hintText: "Email",),
                      SizedBox(height: 16),
                      PasswordField(controller: passwordController, hintText: "Password",),                      
                      SizedBox(height: 16),
                      InkWell(
                        onTap: () {
                          cek();
                        },
                        child: CustomButton(
                          "LOGIN",
                          color: Colors.green[400],
                        ),
                      ),
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,EnterExitRoute(exitPage: Login(), enterPage: ForgotPassword()));                          
                        },
                        child: Text(
                          "Lupa password?",
                          style: TextStyle(fontFamily: "mon", fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}