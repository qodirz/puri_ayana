import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/custom/custom_number_field.dart';
import 'package:puri_ayana_gempol/custom/email_field.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:form_field_validator/form_field_validator.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {  
  TextEditingController emailController = TextEditingController();
  TextEditingController tokenController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newPasswordConfirmationController = TextEditingController();
  
  final _key = GlobalKey<FormState>();
  var obSecure = true;
  var obSecureConfirmation = true;

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
    
      final response = await http.post(NetworkURL.resetPassword(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
      },body: jsonEncode(<String, String>{        
        "email": emailController.text.trim(), 
        "token": tokenController.text.trim(), 
        "new_password": newPasswordController.text.trim(), 
        "new_password_confirmation": newPasswordConfirmationController.text.trim(), 
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
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login()))
                    : Navigator.pop(context)                  
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
                      CustomNumberField(controller: tokenController, hintText: "Token",),
                      SizedBox(height: 16,),
                      PasswordField(controller: newPasswordController, hintText: "Password",),
                      SizedBox(height: 16,),
                      TextFormField(
                        validator: (val) => MatchValidator(errorText: 'passwords tidak sama').validateMatch(val, newPasswordController.text),       
                        controller: newPasswordConfirmationController,
                        obscureText: obSecureConfirmation,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Password Konfirmasi",
                            hintStyle: TextStyle(fontFamily: "mon"),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16.0)),
                              borderSide: BorderSide(color: Colors.green, width: 2),              
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16.0)),
                              borderSide: BorderSide(color: Colors.green, width: 2),              
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green[300]),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide:  BorderSide(color: Colors.green[300]),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.green[300])
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obSecureConfirmation ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obSecureConfirmation = !obSecureConfirmation;
                                });
                              },
                            )),
                      ),
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () {
                          cek();
                        },
                        child: CustomButton(
                          "UBAH PASSWORD",
                          color: Colors.green[400],
                        ),
                      ),
                      SizedBox(height: 16,),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,EnterExitRoute(exitPage:  ResetPassword(), enterPage: Login()));                          
                        },
                        child: Text(
                          "Kembali ke login?",
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