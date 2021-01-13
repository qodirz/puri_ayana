import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {  
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  UserModel userModel;
  String accessToken, uid, expiry, client, email, name, phoneNumber, picBlok, avatar;
  int role, addressId;
  final emailValidator = RequiredValidator(errorText: 'Email harus di isi!');  
  final nameValidator = RequiredValidator(errorText: 'Nama harus di isi!');  
  final phoneValidator = RequiredValidator(errorText: 'Telpon harus di isi!');  
  final _key = GlobalKey<FormState>();
  var obSecureCurrentPwd = true;
  var obSecurePwd = true;
  var obSecurePwdConf = true;

  File _image;
  pilihGallery() async {
    final image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });    
  }


  getPref() async {
    print("masuk get pref");

    SharedPreferences pref = await SharedPreferences.getInstance();
    
    print(pref.getString("email"));
    print(pref.getString("avatar"));
    
    setState(() {
      accessToken = pref.getString("accessToken");
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");      

      email = pref.getString("email");
      name = pref.getString("name");
      phoneNumber = pref.getString("phoneNumber");
      role = pref.getInt("role");
      addressId = pref.getInt("addressId");
      picBlok = pref.getString("picBlok");
      avatar = pref.getString("avatar");

      emailController.text = email;
      nameController.text = name;
      phoneNumberController.text = phoneNumber;      
    });
  }

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    print("submitted");
    print(emailController.text);
    print(nameController.text);
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
              SizedBox(
                height: 16,
              ),
              Text("Please wait...")
            ],
          ),
        );
      });
    
      Map<String, String> headers = { 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      };
      var url = Uri.parse(NetworkURL.updateProfile());
      var request = http.MultipartRequest("PUT", url);
      request.headers.addAll(headers);
      request.fields['user[email]'] = emailController.text;
      request.fields['user[name]'] = nameController.text;
      request.fields['user[phone_number]'] = phoneNumberController.text;
      if(_image != null){
        var stream = http.ByteStream(DelegatingStream.typed(_image.openRead()));
        var length = await _image.length();
        var multiPartFile = new http.MultipartFile("user[avatar]", stream, length, filename: path.basename(_image.path));     
        request.files.add(multiPartFile);
      }
      
      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((a) {
        final data = jsonDecode(a);
        print("Update profile  xxxxxxxxxxxxx");
        print(data);
        if (data['success'] == true) {
          userModel = UserModel.fromJson(data["me"]); 
          print(userModel.avatar);
          print(userModel.email);
          print(userModel.name);
          savePref(
            userModel.email,
            userModel.name,
            userModel.phoneNumber,
            userModel.role,
            userModel.addressId,
            userModel.picBlok,
            data["avatar"]
          );
          setState(() {                         
            _image = null; 
            avatar = data["avatar"];
            emailController.text = userModel.email;
            nameController.text = userModel.name;
            phoneNumberController.text = userModel.phoneNumber; 
          });
                   
          showTopSnackBar( context,
            CustomSnackBar.success(message: data['message']),
          );        
        } else {
          showTopSnackBar( context,
            CustomSnackBar.error(message: data['message']),
          );                   
        }
        
      });
      Navigator.pop(context);    
  }

  savePref(
    String email, name, phoneNumber, role, addressId, picBlok, avatar
  ) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {      
      pref.setString("email", email);
      pref.setString("name", name);
      pref.setString("phoneNumber", phoneNumber);
      pref.setInt("role", role);
      pref.setInt("addressId", addressId);
      pref.setString("picBlok", picBlok);
      pref.setString("avatar", avatar);
    });
  }

  @override
  void initState() {
    super.initState();
    getPref();
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
                      Container(
                        child: Row(
                          children: <Widget>[
                            InkWell(
                            onTap: () {
                              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 3)));
                            },
                            child: Icon(Icons.arrow_back, size: 30,),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Text(
                              "PROFIL",                              
                              style: TextStyle(
                                fontSize: 20
                              ),
                            ),
                            
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      Center(
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            border:Border.all(width: 1, color: Colors.white),
                            shape: BoxShape.circle,                                                      
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.green[300],
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: profileAvatar(avatar, _image),                              
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: InkWell(                          
                          onTap: pilihGallery,
                          child: Text(
                            "ubah avatar",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "mon",
                              color: Colors.green
                            ),
                          ),
                        )
                        
                      ),                                        
                      SizedBox(
                        height: 40,
                      ),
                      TextFormField(                        
                        validator: emailValidator,
                        controller: emailController,
                        decoration: InputDecoration( 
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
                          errorStyle: TextStyle(color: Colors.red),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        validator: nameValidator,         
                        controller: nameController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Nama",
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
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        validator: phoneValidator,                    
                        keyboardType: TextInputType.number,    
                        controller: phoneNumberController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: "Telpon",
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
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      InkWell(
                        onTap: () {
                          cek();
                        },
                        child: CustomButton(
                          "UBAH PROFIL",
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

Widget profileAvatar(avatar, _image) { 
  if(_image == null){
    if(avatar != null){
      return Image.network(        
        "${avatar}",
        fit: BoxFit.cover,
        height: 200,
        width: 200
      );
    }else{
      return Icon(LineIcons.user, size: 120, color: Colors.white,);
    }

  }else{
    return Image.file(_image,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }
}