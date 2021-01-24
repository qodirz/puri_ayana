import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
  
  String accessToken, uid, expiry, client, name, phoneNumber, role;
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
    String nameStorage = await storage.read(key: "name");
    String roleStorage = await storage.read(key: "role");  
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      name = nameStorage;
      role = roleStorage;
    });    
  }

  cek() {
    if (_key.currentState.validate()) {
      isloading = true;
      submit();
    }
  }

  submit() async {    
    final response = await http.post(NetworkURL.newUser(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    },body: jsonEncode(<String, String>{ 
      "email": emailController.text.trim(),        
      "name": nameController.text.trim(), 
      "phoneNumber": phoneNumberController.text.trim(),       
    }));

    final responJson = json.decode(response.body);
    if (responJson != null) {
      Navigator.pop(context);
      
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
                      TextFormField(                        
                        controller: emailController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Email",
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(                        
                        controller: nameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Nama",
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(                        
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Telpon",
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
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
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