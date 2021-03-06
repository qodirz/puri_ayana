import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman_detail.dart';
import 'dart:convert';

class PengumumanPage extends StatefulWidget {
  final String from;
  const PengumumanPage({this.from});

  @override
  _PengumumanPageState createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  final storage = new FlutterSecureStorage();
  List _pengumumanList = [];
  bool isLoading = false;

  String accessToken, uid, expiry, client;
  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    setState(() {
      isLoading = true;
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
    });
    getPengumuman();
  }

  getPengumuman() async {
    try {
      _pengumumanList.clear();
      final response =
          await http.get(NetworkURL.pengumuman(), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
        final data = responJson["user_notifications"];
        setState(() {
          isLoading = false;
          for (Map i in data) {
            _pengumumanList.add([
              i["notification"]["id"],
              i["notification"]["title"],
              i["notification"]["notif"],
              i["is_read"],
              i["notif_sent_at"]
            ]);
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      print(e);
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
    }
  }

  Future<void> onRefresh() async {
    _pengumumanList.clear();
    getStorage();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: baseColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 26),
          onPressed: () {
            if (widget.from == "home") {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(selectIndex: 0)));
            } else {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(selectIndex: 1)));
            }
          },
        ),
        title: Text("PENGUMUMAN"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                isLoading == true
                    ? Container(
                        height: 150,
                        color: baseColor50,
                        child: Center(
                            child: CircularProgressIndicator(
                          backgroundColor: baseColor,
                        )))
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _pengumumanList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: <Widget>[
                              PengumumanItem(
                                  _pengumumanList[index][0],
                                  _pengumumanList[index][1],
                                  _pengumumanList[index][2],
                                  _pengumumanList[index][3],
                                  _pengumumanList[index][4]),
                              Divider(
                                color: baseColor600,
                                height: 2,
                              )
                            ],
                          );
                        },
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
