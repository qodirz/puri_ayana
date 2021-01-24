import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:puri_ayana_gempol/custom/custom_text_field.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';

class BuatPengumumanPage extends StatefulWidget {
  @override
  _BuatPengumumanPageState createState() => _BuatPengumumanPageState();
}

class _BuatPengumumanPageState extends State<BuatPengumumanPage> {
  final storage = new FlutterSecureStorage();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final titleValidator = RequiredValidator(errorText: 'Judul harus di isi!');
  final descriptionValidator = RequiredValidator(errorText: 'Deskripsi harus di isi!');
  
  String accessToken, uid, expiry, client, blockAddress;
  bool isloading = false;
  
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
  
  final _key = GlobalKey<FormState>();

  cek() {
    if (_key.currentState.validate()) {
      setState(() {
        isloading = true;      
      });
      buatPengumuman();       
    }
  }

  buatPengumuman() async {
    print("masuk buatPengumuman");
    final response = await http.post(NetworkURL.createNotification(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    },body: jsonEncode(<String, String>{        
      "title": titleController.text.trim(),
      "notif": descriptionController.text.trim(),      
    }));
    
    final responJson = json.decode(response.body);
    print(responJson);
    
    if(responJson["success"] == true){
      FlushbarHelper.createSuccess(title: 'Berhasil',message: responJson["message"],).show(context);           
      setState(() {
        titleController.text = '';
        descriptionController.text = '';
        isloading = false;    
      });        
    }else{
      FlushbarHelper.createError(title: 'Error',message: responJson["message"],).show(context);      
      setState(() {
        isloading = false;                
      }); 
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
              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 1)));
            },
          ), 
          title: Text("BUAT PENGUMUMAN", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: Container(          
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Form(
                  key: _key,
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[  
                      SizedBox(height: 20,), 
                      CustomTextField(controller: titleController, hintText: "Judul"),                                             
                      SizedBox(height: 10,),
                      _descriptionField(),
                      SizedBox(height: 10,),
                      _btnSimpan(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )        
      )
    );
  }
  
  Widget _descriptionField() {
    return TextFormField(  
      validator: descriptionValidator,                      
      controller: descriptionController,
      keyboardType: TextInputType.multiline,
      maxLines: 10,        
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        filled: true,
        fillColor: Colors.white,
          hintText: "DesKripsi",
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
          errorStyle: TextStyle(color: Colors.red),
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



