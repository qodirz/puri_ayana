import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/custom_number_field.dart';
import 'package:puri_ayana_gempol/custom/custom_text_field.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:http/http.dart' as http;

class NewUserPage extends StatefulWidget {
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final storage = new FlutterSecureStorage();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  String accessToken, uid, expiry, client;
  bool isloading = false;

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
      isloading = true;
      submit();
    }
  }

  submit() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      customDialogWait(context);

      final response = await http.post(NetworkURL.newUser(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'access-token': accessToken,
            'expiry': expiry,
            'uid': uid,
            'client': client,
            'token-type': "Bearer"
          },
          body: jsonEncode(<String, dynamic>{
            'user': <String, dynamic>{
              'email': emailController.text.trim(),
              'name': nameController.text.trim(),
              'phone_number': phoneNumberController.text.trim()
            }
          }));

      final responJson = json.decode(response.body);
      Navigator.pop(context);
      if (responJson['success'] == true) {
        setState(() {
          emailController.text = "";
          nameController.text = "";
          phoneNumberController.text = "";
        });
        FlushbarHelper.createSuccess(
          title: 'Berhasil',
          message: responJson['message'],
        ).show(context);
      } else {
        FlushbarHelper.createError(
          title: 'Error',
          message: responJson['message'],
        ).show(context);
      }
      setState(() {
        isloading = false;
      });
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
          title: Text("BUAT USER BARU"),
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
                          EmailField(
                              controller: emailController, hintText: "Email"),
                          CustomTextField(
                              controller: nameController, hintText: "Nama"),
                          CustomNumberField(
                              controller: phoneNumberController,
                              hintText: "Telpon"),
                          _btnSimpan(),
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

  Widget _btnSimpan() {
    if (isloading == true) {
      return Container(
        width: double.infinity,
        child: customButton("loading..."),
      );
    } else {
      return Container(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            cek();
          },
          child: customButton("SIMPAN"),
        ),
      );
    }
  }
}
