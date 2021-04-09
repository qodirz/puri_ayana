import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
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
  final descriptionValidator =
      RequiredValidator(errorText: 'Deskripsi harus di isi!');

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

  _confirmDialog() {
    Widget yesButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.blue,
        side: BorderSide(color: Colors.blue),
      ),
      onPressed: () => {Navigator.pop(context), buatPengumuman()},
      child: Text('YA'),
    );

    Widget noButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.red,
        side: BorderSide(color: Colors.red),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text('Tidak'),
    );

    confirmDialogWithActions(
        "Pengumuman",
        "Apakah Anda Yakin Akan Membuat Pengumuman?",
        [noButton, yesButton],
        context);
  }

  cek() {
    if (_key.currentState.validate()) {
      _confirmDialog();
    }
  }

  buatPengumuman() async {
    setState(() => {isloading = true});
    customDialogWait(context);
    final response = await http.post(NetworkURL.createNotification(),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'access-token': accessToken,
          'expiry': expiry,
          'uid': uid,
          'client': client,
          'token-type': "Bearer"
        },
        body: jsonEncode(<String, String>{
          "title": titleController.text.trim(),
          "notif": descriptionController.text.trim(),
        }));

    final responJson = json.decode(response.body);

    if (responJson["success"] == true) {
      FlushbarHelper.createSuccess(
        title: 'Berhasil',
        message: responJson["message"],
      ).show(context);
      setState(() {
        titleController.text = '';
        descriptionController.text = '';
        isloading = false;
      });
    } else {
      FlushbarHelper.createError(
        title: 'Error',
        message: responJson["message"],
      ).show(context);
      setState(() => {isloading = false});
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
                      builder: (context) => Menu(selectIndex: 1)));
            },
          ),
          title: Text("BUAT PENGUMUMAN"),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            mainBg(),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Form(
                      key: _key,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 40),
                        children: <Widget>[
                          CustomTextField(
                              controller: titleController, hintText: "Judul"),
                          _descriptionField(),
                          _btnSimpan(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _descriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Deskripsi",
          style: TextStyle(fontFamily: 'bold', color: baseColor900),
        ),
        SizedBox(height: 4),
        TextFormField(
          validator: descriptionValidator,
          controller: descriptionController,
          keyboardType: TextInputType.multiline,
          maxLines: 6,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: baseColor),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10),
              borderSide: BorderSide(color: baseColor400),
            ),
            errorBorder: OutlineInputBorder(
                borderRadius: new BorderRadius.circular(10),
                borderSide: BorderSide(color: baseColor)),
            errorStyle: TextStyle(color: Colors.redAccent),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _btnSimpan() {
    if (isloading == true) {
      return Container(
        width: double.infinity,
        child: customButton("loading..."),
      );
    } else {
      return Container(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            cek();
          },
          child: customButton("SIMPAN"),
        ),
      );
    }
  }
}
