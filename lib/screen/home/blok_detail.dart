import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';

class BlokDetailPage extends StatefulWidget {
  final String blok;
  BlokDetailPage(this.blok);

  @override
  _BlokDetailPagePageState createState() => _BlokDetailPagePageState();
}

class _BlokDetailPagePageState extends State<BlokDetailPage> {
  final storage = new FlutterSecureStorage();
  List<UserModel> _userList = [];

  String accessToken, uid, expiry, client, tagihan;
  double contribution;

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
    getBlokInfo();
  }

  getBlokInfo() async {
    try {
      _userList.clear();
      final response = await http
          .get(NetworkURL.blockDetail(widget.blok), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
        final data = responJson["users"];
        setState(() {
          contribution = double.parse(responJson["address"]["contribution"]);
          tagihan = responJson["tagihan"].toString();
          for (Map i in data) {
            _userList.add(UserModel.fromJson(i));
          }
        });
      } else {}
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: "No Internet connection!",
      ).show(context);
    } catch (e) {
      print(e);
      FlushbarHelper.createError(
        title: 'Error',
        message: "Error connection with server!",
      ).show(context);
    }
  }

  Future<void> onRefresh() async {
    getStorage();
  }

  @override
  void initState() {
    getStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 26),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => Menu(selectIndex: 0)));
          },
        ),
        title: Text("Blok Info " + widget.blok),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              backgroundHeader(tagihan, contribution),
              Expanded(
                child: ListView(
                  children: <Widget>[
                    _listMember(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listMember() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _userList.length,
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: <Widget>[
            ListTile(
              dense: true,
              tileColor: Colors.lightBlue[50],
              leading: Container(
                alignment: Alignment.center,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  color: Colors.lightBlue[700],
                ),
                child: Text(
                  (index + 1).toString(),
                  style: TextStyle(
                      fontFamily: 'bold', fontSize: 20, color: Colors.white),
                ),
              ),
              title: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.account_box,
                        size: 14,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(width: 4),
                      Text(_userList[index].name.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.alternate_email_outlined,
                        size: 14,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(width: 4),
                      Text(_userList[index].email.toString()),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 14,
                        color: Colors.lightBlue,
                      ),
                      SizedBox(width: 4),
                      Text(_userList[index].phoneNumber.toString()),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              height: 2,
              color: Colors.grey,
            ),
          ],
        );
      },
    );
  }
}

Widget backgroundHeader(tagihan, contribution) {
  return Container(
    color: Colors.lightBlue[600],
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          tagihan == null
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
              : Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Tagihan",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "$tagihan kali",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Kontribusi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(contribution),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )
        ],
      ),
    ),
  );
}
