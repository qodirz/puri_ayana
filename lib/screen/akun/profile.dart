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
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = new FlutterSecureStorage();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  UserModel userModel;
  String accessToken,
      uid,
      expiry,
      client,
      email,
      name,
      phoneNumber,
      picBlok,
      avatar,
      role,
      addressId;

  final _key = GlobalKey<FormState>();
  var obSecureCurrentPwd = true;
  var obSecurePwd = true;
  var obSecurePwdConf = true;

  File _image;

  fromGallery() async {
    final image = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      _image = File(image.path);
      Navigator.pop(context);
    });
  }

  fromCamera() async {
    final image = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      _image = File(image.path);
      Navigator.pop(context);
    });
  }

  void _modalImagePick(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return Container(
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20))),
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        dense: true,
                        title: Text("Foto Kamera"),
                        onTap: () => {fromCamera()},
                        leading: Icon(Icons.photo_camera),
                      ),
                      ListTile(
                        dense: true,
                        title: Text("Foto Galeri"),
                        onTap: () => {fromGallery()},
                        leading: Icon(Icons.photo_library),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    String nameStorage = await storage.read(key: "name");
    String emailStorage = await storage.read(key: "email");
    String phoneNumberStorage = await storage.read(key: "phoneNumber");
    String roleStorage = await storage.read(key: "role");
    String avatarStorage = await storage.read(key: "avatar");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      name = nameStorage;
      email = emailStorage;
      role = roleStorage;
      avatar = avatarStorage;

      emailController.text = email;
      nameController.text = name;
      phoneNumberController.text = phoneNumberStorage;
    });
  }

  cek() {
    if (_key.currentState.validate()) {
      submit();
    }
  }

  submit() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      customDialogWait(context);

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
      if (_image != null) {
        var stream = http.ByteStream(DelegatingStream.typed(_image.openRead()));
        var length = await _image.length();
        var multiPartFile = new http.MultipartFile(
            "user[avatar]", stream, length,
            filename: path.basename(_image.path));
        request.files.add(multiPartFile);
      }

      var response = await request.send();
      response.stream.transform(utf8.decoder).listen((a) {
        final data = jsonDecode(a);

        if (data['success'] == true) {
          userModel = UserModel.fromJson(data["me"]);
          updateProfileStorage(userModel, data["avatar"]);
          print("avatar");
          print(data["avatar"]);
          setState(() {
            _image = null;
            avatar = data["avatar"];
            emailController.text = userModel.email;
            nameController.text = userModel.name;
            phoneNumberController.text = userModel.phoneNumber;
          });
          FlushbarHelper.createSuccess(
            title: 'Berhasil',
            message: data['message'],
          ).show(context);
        } else {
          FlushbarHelper.createError(
            title: 'Error',
            message: data['message'],
          ).show(context);
        }
      });
      Navigator.pop(context);
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

  Future updateProfileStorage(userModel, avatar) async {
    await storage.write(key: "email", value: userModel.email);
    await storage.write(key: "name", value: userModel.name);
    await storage.write(key: "phoneNumber", value: userModel.phoneNumber);
    await storage.write(key: "role", value: userModel.role.toString());
    await storage.write(
        key: "addressId", value: userModel.addressId.toString());
    await storage.write(key: "picBlok", value: userModel.picBlok);
    await storage.write(key: "avatar", value: avatar);

    String nameStorage = await storage.read(key: "name");
    print(nameStorage);
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: baseColor100,
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: baseColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(selectIndex: 3)));
            },
          ),
          title: Text("PROFIL"),
          centerTitle: true,
        ),
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
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 40),
                        children: <Widget>[
                          Stack(fit: StackFit.loose, children: <Widget>[
                            Center(
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: baseColor50),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: baseColor300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: profileAvatar(avatar, _image),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 00,
                              right: 30,
                              child: Center(
                                child: InkWell(
                                  onTap: () => {_modalImagePick(context)},
                                  child: CircleAvatar(
                                    backgroundColor: baseColor200,
                                    radius: 25.0,
                                    child: new Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                          SizedBox(height: 20),
                          EmailField(
                            controller: emailController,
                            hintText: "Email",
                          ),
                          CustomTextField(
                              controller: nameController, hintText: "Nama"),
                          CustomNumberField(
                              controller: phoneNumberController,
                              hintText: "Telpon"),
                          InkWell(
                            onTap: () {
                              cek();
                            },
                            child: customButton("UBAH PROFIL"),
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

Widget profileAvatar(avatar, _image) {
  if (_image == null) {
    if (avatar != null) {
      return Image.network(avatar, fit: BoxFit.cover, height: 200, width: 200);
    } else {
      return Icon(
        Icons.account_circle,
        size: 120,
        color: Colors.white,
      );
    }
  } else {
    return Image.file(
      _image,
      width: 200,
      height: 200,
      fit: BoxFit.cover,
    );
  }
}
