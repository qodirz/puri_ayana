import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
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
    try{
      _contributionList.clear();
      final response = await http.get(NetworkURL.contributions(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      print("getContributions");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["contributions"];
        setState(() {
          title = responJson["title"];
          tagihan = responJson["tagihan"];
          for (Map i in data) {
            _contributionList.add(ContributionModel.fromJson(i));
          }          
        });      
      }else{
      }  

    } on SocketException {
      print("ERROR.........");
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);            
    } catch (e) {
      print(e);      
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
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
      statusBarColor: Colors.green[100], 
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              if (widget.from == "home"){
                Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 0)));
              }else{
                Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
              }
            },
          ), 
          title: Text("KONTRIBUSI", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: Container(    
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(10),
                    children: <Widget>[                      
                      backgroundHeader(title, tagihan), 
                      _getBodyWidget(),                   
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        
      )
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 50,
        rightHandSideColumnWidth: 500,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: _contributionList.length,
        rowSeparatorWidget: const Divider(
          color: Colors.cyan,
          height: 1.0,
          thickness: 1.0,
        ),
        leftHandSideColBackgroundColor: Colors.green[50],
        rightHandSideColBackgroundColor: Colors.green[50],
      ),
      height: (MediaQuery.of(context).size.height - 200),
    );
  }

  List<Widget> _getTitleWidget() {
    return [      
      _getTitleItemWidget('No', 50),
      _getTitleItemWidget('Deskripsi', 200),      
      _getTitleItemWidget('Tanggal bayar', 150),
      _getTitleItemWidget('Iuran', 150),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon")),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text((index + 1).toString()),
      width: 100,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(_contributionList[index].contributionDesc.toString(), style: TextStyle(fontFamily: "mon")),
          width: 200,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(_contributionList[index].payAt.toString(), style: TextStyle(fontFamily: "mon"),),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_contributionList[index].contribution), style: TextStyle(fontFamily: "mon"),),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
      ],
    );
  }
}

Widget backgroundHeader(title, tagihan) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft:Radius.circular(30), topRight: Radius.circular(30)
      ),
      color: Colors.green
    ),
    height: 90,
    width: double.infinity,  
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          title == null ?
          Container( margin: EdgeInsets.only(top: 20), width: 30, height: 30, child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          )) : 
          Column(children: <Widget>[
            Text("$title",style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),),
            SizedBox(height: 6),
            Text("$tagihan kali",style: TextStyle(fontSize: 36, fontFamily: "mon", color: Colors.white),),
          ],)
        ],
      ),
    ),
  );
}