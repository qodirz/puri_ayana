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
import 'package:puri_ayana_gempol/custom/customButton.dart';
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
    try{
      FocusScope.of(context).requestFocus(new FocusNode());    
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Processing.."),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 16,),
                Text("Please wait...")
              ],
            ),
          );
        }
      );

      final response = await http.post(NetworkURL.newUser(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      },body: jsonEncode(<String, dynamic>{        
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
         FlushbarHelper.createSuccess(title: 'Berhasil',message: responJson['message'],).show(context);        
      }else{
         FlushbarHelper.createError(title: 'Error',message: responJson['message'],).show(context); 
      }
      setState(() {
        isloading = false;
      });
    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);
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
          title: Text("BUAT USER BARU", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: Container(          
          child: Form(
            key: _key,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[  
                SizedBox(height: 20,),                                        
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[
                      EmailField(controller: emailController, hintText: "Email",),                      
                      SizedBox(height: 16,),
                      CustomTextField(controller: nameController, hintText: "Nama"),
                      SizedBox(height: 16,),
                      CustomNumberField(controller: phoneNumberController, hintText: "Telpon"),
                      SizedBox(height: 16,),                     
                      _btnSimpan(),
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

  Widget _btnSimpan() {
    if(isloading == true){
      return Container(
        width: double.infinity,         
        child: CustomButton(
          "loading...",
          color: Colors.green,
        ),
      );
    }else{
      return Container(
        width: double.infinity,  
        child: InkWell(
          onTap: () {
            cek();
          },
          child: CustomButton(
            "SIMPAN",
            color: Colors.green,
          ),
        ),
        
      );
    }    
  }
}