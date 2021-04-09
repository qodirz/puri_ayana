import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/screen/forgot_password.dart';
import 'package:puri_ayana_gempol/model/loginModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final firebaseMessaging = FirebaseMessaging();
  final storage = new FlutterSecureStorage();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  LoginModel loginModel;
  UserModel userModel;
  String deviceType, deviceToken;

  getAccessToken() async {
    String token = await storage.read(key: "accessToken");
    token != null
        ? Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Menu()))
        : null;
  }

  var obSecure = true;
  final _key = GlobalKey<FormState>();

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      customDialogWait(context);
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
          },
          body: jsonEncode(<String, String>{
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
            "device_token": deviceToken,
            "device_type": deviceType
          }));

      final responJson = json.decode(response.body);
      if (response.headers['access-token'] != null) {
        loginModel = LoginModel.api(response.headers);
        userModel = UserModel.fromJson(responJson["me"]);
        await storage.write(key: "accessToken", value: loginModel.accessToken);
        await storage.write(key: "uid", value: loginModel.uid);
        await storage.write(key: "expiry", value: loginModel.expiry);
        await storage.write(key: "client", value: loginModel.client);
        await storage.write(key: "email", value: userModel.email);
        await storage.write(key: "name", value: userModel.name);
        await storage.write(key: "phoneNumber", value: userModel.phoneNumber);
        await storage.write(key: "role", value: userModel.role.toString());
        await storage.write(
            key: "addressId", value: userModel.addressId.toString());
        await storage.write(key: "picBlok", value: userModel.picBlok);
        await storage.write(key: "avatar", value: responJson["avatar"]);
        await storage.write(
            key: "hasDebt", value: responJson["has_debt"].toString());
        await storage.write(key: "headFamily", value: userModel.kk.toString());
        FocusScope.of(context).requestFocus(new FocusNode());
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Menu()));
      } else {
        Navigator.pop(context);
      }
      Widget okButton = OutlinedButton(
        style: OutlinedButton.styleFrom(
            primary: Colors.cyan,
            backgroundColor: Colors.cyan[100],
            side: BorderSide(color: Colors.cyan)),
        onPressed: () => Navigator.pop(context),
        child: Text('ok'),
      );

      confirmDialogWithActions(
          "Login", responJson['message'], [okButton], context);
    } on SocketException {
      Navigator.pop(context);
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      Navigator.pop(context);
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    getAccessToken();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            mainBg(),
            Container(
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(50),
                        children: <Widget>[
                          logo(),
                          EmailField(
                            controller: emailController,
                            hintText: "Email",
                          ),
                          PasswordField(
                            controller: passwordController,
                            hintText: "Password",
                          ),
                          InkWell(
                            onTap: () {
                              cek();
                            },
                            child: customButton("LOGIN"),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.teal,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                EnterExitRoute(
                                  exitPage: Login(),
                                  enterPage: ForgotPassword(),
                                ),
                              );
                            },
                            child: Text("Lupa password?"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
