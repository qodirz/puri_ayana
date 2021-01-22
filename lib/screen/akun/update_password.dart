import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/password_field.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePasswordPage extends StatefulWidget {
  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePasswordPage> {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmationController = TextEditingController();
  String accessToken, uid, expiry, client, name, phoneNumber, role, addressId, picBlok;

  final currentPasswordValidator = MultiValidator([  
    RequiredValidator(errorText: 'password saat ini harus di isi!'),  
    MinLengthValidator(8, errorText: 'sandi harus terdiri dari minimal 8 digit'),  
    PatternValidator(r'([0-9])', errorText: 'kata sandi harus memiliki setidaknya satu angka')  
  ]); 

  final newPasswordValidator = MultiValidator([  
    RequiredValidator(errorText: 'password baru harus di isi!'),  
    MinLengthValidator(8, errorText: 'sandi harus terdiri dari minimal 8 digit'),  
    PatternValidator(r'([0-9])', errorText: 'kata sandi harus memiliki setidaknya satu angka')  
  ]); 

  
  final _key = GlobalKey<FormState>();
  var obSecureCurrentPwd = true;
  var obSecurePwd = true;
  var obSecurePwdConf = true;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");      
    });

    print("update password page");
    print(accessToken);
    print(uid);
  }

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
    
    final response = await http.put(NetworkURL.updatePassword(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    },body: jsonEncode(<String, String>{        
      "current_password": currentPasswordController.text.trim(), 
      "password": passwordController.text.trim(), 
      "password_confirmation": passwordConfirmationController.text.trim(), 
    }));

    final responJson = json.decode(response.body);
    if (responJson != null) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(responJson['success'] == true ? "successfully updated password." : "failed update password!"),
            actions: <Widget>[
              FlatButton(
                onPressed: () => {
                  responJson['success'] == true ? 
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Menu(selectIndex: 3)))
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
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.green[100], 
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 3)));
            },
          ), 
          title: Text("UPDATE PASSWORD", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
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
                      SizedBox(height: 20,),   
                      PasswordField(controller: currentPasswordController, hintText: "Password saat ini",),                                                              
                      SizedBox(height: 16,),
                      PasswordField(controller: currentPasswordController, hintText: "Password",),                       
                      SizedBox(height: 16,),
                      TextFormField(
                        validator: (val) => MatchValidator(errorText: 'passwords tidak sama').validateMatch(val, passwordConfirmationController.text),       
                        controller: passwordConfirmationController,
                        obscureText: obSecurePwdConf,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: "Password Konfirmasi",
                            hintStyle: TextStyle(fontFamily: "mon"),
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
                                obSecurePwdConf ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obSecurePwdConf = !obSecurePwdConf;
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