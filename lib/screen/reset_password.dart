import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:puri_ayana_gempol/custom/enter_exit_route.dart';
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
   final emailValidator = MultiValidator([
    RequiredValidator(errorText: 'email is required'),
    EmailValidator(errorText: 'enter a valid email address')
  ]);   
  final passwordValidator = MultiValidator([  
    RequiredValidator(errorText: 'password is required'),  
    MinLengthValidator(8, errorText: 'password must be at least 8 digits long'),  
    PatternValidator(r'([0-9])', errorText: 'passwords must have at least one number')  
  ]); 

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
                    padding: EdgeInsets.all(16),
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
                      TextFormField(  
                        validator: emailValidator,                     
                        controller: emailController,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red[100]),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(16.0),
                            borderSide:  BorderSide(color: Colors.green[400] ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: Colors.green)
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        validator: RequiredValidator(errorText: 'token is required'),  
                        keyboardType: TextInputType.number,
                        controller: tokenController,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red[100]),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Token",
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.green),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(16.0),
                            borderSide:  BorderSide(color: Colors.green[400] ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(16.0),
                            borderSide: BorderSide(color: Colors.green)
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        validator: passwordValidator,
                        controller: newPasswordController,
                        obscureText: obSecure,
                        decoration: InputDecoration(
                          errorStyle: TextStyle(color: Colors.red[100]),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Password Baru",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide:  BorderSide(color: Colors.green[400] ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.green)
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obSecure ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obSecure = !obSecure;
                                });
                              },
                            )),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        validator: (val) => MatchValidator(errorText: 'passwords tidak sama').validateMatch(val, newPasswordController.text),       
                        controller: newPasswordConfirmationController,
                        obscureText: obSecureConfirmation,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Password Konfirmasi",
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide:  BorderSide(color: Colors.green[400] ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(16.0),
                              borderSide: BorderSide(color: Colors.green)
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
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () {
                          cek();
                        },
                        child: CustomButton(
                          "UBAH PASSWORD",
                          color: Colors.green[400],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
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