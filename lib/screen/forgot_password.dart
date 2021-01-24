import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/screen/reset_password.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController emailController = TextEditingController();
  
  final _key = GlobalKey<FormState>();

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try{
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
        });
    
      final response = await http.post(NetworkURL.resetPasswordToken(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
      },body: jsonEncode(<String, String>{        
        "email": emailController.text.trim(), 
      }));

      final responJson = json.decode(response.body);
      if (responJson != null) {      
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(responJson['message']),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => {
                    responJson['success'] == true ? 
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResetPassword())) : Navigator.pop(context)
                  },
                  child: Text("Ok"),
                ),
              ],
            );
          }
        );
      } 

    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);
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
        body: Container(
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () {
                          cek();
                        },
                        child: CustomButton(
                          "MINTA TOKEN",
                          color: Colors.green[400],
                        ),
                      ),
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,EnterExitRoute(exitPage:  ForgotPassword(), enterPage: Login()));                          
                        },
                        child: Text(
                          "Kembali ke Login?",
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