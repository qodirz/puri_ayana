import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:http/http.dart' as http;

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePasswordPage> {
  final storage = new FlutterSecureStorage();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController =
      TextEditingController();
  String accessToken, uid, expiry, client;

  final _key = GlobalKey<FormState>();
  var obSecureCurrentPwd = true;
  var obSecurePwd = true;
  var obSecurePwdConf = true;

  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
    });
  }

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      customDialogWait(context);

      final response = await http.put(NetworkURL.updatePassword(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'access-token': accessToken,
            'expiry': expiry,
            'uid': uid,
            'client': client,
            'token-type': "Bearer"
          },
          body: jsonEncode(<String, String>{
            "current_password": currentPasswordController.text.trim(),
            "password": passwordController.text.trim(),
            "password_confirmation": passwordConfirmationController.text.trim(),
          }));

      final responJson = json.decode(response.body);
      if (responJson != null) {
        Navigator.pop(context);
        Widget okButton = OutlinedButton(
          style: OutlinedButton.styleFrom(
              primary: Colors.blue, side: BorderSide(color: Colors.blue)),
          onPressed: () => {
            responJson['success'] == true
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Menu(selectIndex: 3)),
                  )
                : Navigator.pop(context)
          },
          child: Text('ok'),
        );

        confirmDialogWithActions(
            "Ubah Password",
            (responJson['success'] == true
                ? "Berhasil ubah password."
                : "Gagal ubah password!"),
            [okButton],
            context);
      }
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: baseColor100,
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: baseColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(selectIndex: 3)));
            },
          ),
          title: Text("UPDATE PASSWORD"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            mainBg(),
            Container(
              child: Form(
                key: _key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 40),
                        children: <Widget>[
                          PasswordField(
                            controller: currentPasswordController,
                            hintText: "Password saat ini",
                          ),
                          PasswordField(
                            controller: passwordController,
                            hintText: "Password",
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Password Konfirmasi",
                                style: TextStyle(
                                    fontFamily: 'bold', color: baseColor900),
                              ),
                              SizedBox(height: 4),
                              TextFormField(
                                validator: (val) => MatchValidator(
                                        errorText:
                                            'passwords konfirmasi tidak sama')
                                    .validateMatch(
                                        val, passwordController.text),
                                controller: passwordConfirmationController,
                                obscureText: obSecurePwdConf,
                                decoration: InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: baseColor),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: baseColor400),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(10),
                                        borderSide:
                                            BorderSide(color: baseColor)),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obSecurePwdConf
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obSecurePwdConf = !obSecurePwdConf;
                                        });
                                      },
                                    )),
                              ),
                              SizedBox(height: 16)
                            ],
                          ),
                          InkWell(
                              onTap: () {
                                cek();
                              },
                              child: customButton("UBAH PASSWORD")),
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
