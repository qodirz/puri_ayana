import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/screen/reset_password.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();

  final _key = GlobalKey<FormState>();
  final storage = new FlutterSecureStorage();

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try {
      customDialogWait(context);

      final response = await http.post(NetworkURL.resetPasswordToken(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            "email": emailController.text.trim(),
          }));

      final responJson = json.decode(response.body);
      print("forgot password");
      print(responJson);

      if (responJson['success'] == true) {
        Navigator.pop(context);
        await storage.write(key: "forgotEmail", value: responJson['email']);

        Widget okButton = OutlinedButton(
          style: OutlinedButton.styleFrom(
              primary: Colors.cyan,
              backgroundColor: Colors.cyan[100],
              side: BorderSide(color: Colors.cyan)),
          onPressed: () => {
            responJson['success'] == true
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPassword()),
                  )
                : Navigator.pop(context)
          },
          child: Text('ok'),
        );

        confirmDialogWithActions(
            "Forgot Password", responJson['message'], [okButton], context);
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
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                        padding: EdgeInsets.all(40),
                        children: <Widget>[
                          logo(),
                          EmailField(
                            controller: emailController,
                            hintText: "Email",
                          ),
                          InkWell(
                            onTap: () {
                              cek();
                            },
                            child: customButton("MINTA TOKEN"),
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
                                      exitPage: ForgotPassword(),
                                      enterPage: Login()));
                            },
                            child: Text("Kembali ke Login?"),
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
