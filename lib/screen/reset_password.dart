import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/custom_number_field.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  TextEditingController tokenController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController =
      TextEditingController();

  final storage = new FlutterSecureStorage();
  final _key = GlobalKey<FormState>();
  var obSecure = true;
  var obSecureConfirmation = true;

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try {
      customDialogWait(context);
      String forgotEmail = await storage.read(key: "forgotEmail");

      final response = await http.post(
        NetworkURL.resetPassword(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "email": forgotEmail,
          "token": tokenController.text.trim(),
          "new_password": newPasswordController.text.trim(),
          "new_password_confirmation":
              newPasswordConfirmationController.text.trim(),
        }),
      );

      final responJson = json.decode(response.body);
      if (responJson != null) {
        Navigator.pop(context);

        Widget okButton = OutlinedButton(
          style: OutlinedButton.styleFrom(
              primary: Colors.blue, side: BorderSide(color: Colors.blue)),
          onPressed: () => {
            responJson['success'] == true
                ? Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Login()))
                : Navigator.pop(context)
          },
          child: Text('OK'),
        );

        confirmDialogWithActions(
            "Reset Password", responJson['message'], [okButton], context);
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
                          CustomNumberField(
                            controller: tokenController,
                            hintText: "Token",
                          ),
                          PasswordField(
                            controller: newPasswordController,
                            hintText: "Password",
                          ),
                          Column(
                            children: [
                              Text(
                                "Password Konfirmasi",
                                style: TextStyle(
                                    fontFamily: 'bold', color: baseColor900),
                              ),
                              TextFormField(
                                validator: (val) => MatchValidator(
                                        errorText:
                                            'passwords konfirmasi tidak sama')
                                    .validateMatch(
                                        val, newPasswordController.text),
                                controller: newPasswordConfirmationController,
                                obscureText: obSecureConfirmation,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  filled: true,
                                  fillColor: Colors.white,
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: baseColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10.0)),
                                    borderSide: BorderSide(color: baseColor),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: baseColor300),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(10.0),
                                    borderSide: BorderSide(color: baseColor300),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                      borderSide:
                                          BorderSide(color: baseColor300)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obSecureConfirmation
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        obSecureConfirmation =
                                            !obSecureConfirmation;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 16)
                            ],
                          ),
                          SizedBox(height: 16),
                          InkWell(
                            onTap: () {
                              cek();
                            },
                            child: customButton("UBAH PASSWORD"),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              primary: Colors.teal,
                            ),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  EnterExitRoute(
                                      exitPage: ResetPassword(),
                                      enterPage: Login()));
                            },
                            child: Text("Kembali ke login?"),
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
