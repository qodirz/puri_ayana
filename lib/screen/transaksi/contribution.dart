import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/contributionModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';

class ContributionPage extends StatefulWidget {
  final String from;
  const ContributionPage({this.from});

  @override
  _ContributionPageState createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  final storage = new FlutterSecureStorage();
  List<ContributionModel> _contributionList = [];

  String accessToken, uid, expiry, client, title, tagihan;
  ContributionModel contributionModel;

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
    getContributions();
  }

  getContributions() async {
    try {
      _contributionList.clear();
      final response =
          await http.get(NetworkURL.contributions(), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
        final data = responJson["contributions"];
        setState(() {
          title = responJson["title"];
          tagihan = responJson["tagihan"];
          for (Map i in data) {
            _contributionList.add(ContributionModel.fromJson(i));
          }
        });
      } else {}
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
    getContributions();
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
                  if (widget.from == "home") {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Menu(selectIndex: 0)));
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Menu(selectIndex: 2)));
                  }
                },
              ),
              title: Text("KONTRIBUSI"),
              centerTitle: true,
            ),
            body: Container(
              child: RefreshIndicator(
                onRefresh: onRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    backgroundHeader(title, tagihan),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          _listContribution(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }

  Widget _listContribution() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _contributionList.length,
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
                  _contributionList[index].payAt.toString().toString(),
                  style: TextStyle(
                      fontFamily: 'bold', fontSize: 20, color: Colors.white),
                ),
              ),
              title: Text(
                NumberFormat.currency(
                        locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                    .format(_contributionList[index].contribution),
              ),
              subtitle:
                  Text(_contributionList[index].contributionDesc.toString()),
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

Widget backgroundHeader(title, tagihan) {
  return Container(
    color: Colors.lightBlue[600],
    width: double.infinity,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          title == null
              ? Container(
                  margin: EdgeInsets.only(top: 20),
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ))
              : Column(
                  children: <Widget>[
                    Text(
                      "$title",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'bold',
                      ),
                    ),
                    Text(
                      "$tagihan kali",
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ],
                )
        ],
      ),
    ),
  );
}
