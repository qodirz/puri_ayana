import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
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
      final response = await http.get(NetworkURL.blockDetail(widget.blok), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      if(responJson["success"] == true){
        final data = responJson["users"];
        setState(() {
          contribution = double.parse(responJson["address"]["contribution"]);
          tagihan = responJson["tagihan"].toString();
          for (Map i in data) {
            _userList.add(UserModel.fromJson(i));
          }          
        });      
      }else{
      }  
    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: "No Internet connection!",).show(context);      
    } catch (e) {
      print(e);      
      FlushbarHelper.createError(title: 'Error',message: "Error connection with server!",).show(context);      
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
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 26),
          onPressed: () {
            Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 0)));            
          },
        ), 
        title: Text("Blok Info "+ widget.blok, style: TextStyle(fontFamily: "mon")),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(    
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10),
                  children: <Widget>[
                    SizedBox(height: 20,),
                    backgroundHeader(tagihan, contribution), 
                    _getBodyWidget(),                   
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
        itemCount: _userList.length,
        rowSeparatorWidget: const Divider(
          color: Colors.cyan,
          height: 1.0,
          thickness: 1.0,
        ),
        leftHandSideColBackgroundColor: Colors.green[50],
        rightHandSideColBackgroundColor: Colors.green[50],
      ),
      height: (MediaQuery.of(context).size.height - 300 ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [      
      _getTitleItemWidget('No', 50),
      _getTitleItemWidget('Email', 200),      
      _getTitleItemWidget('Nama', 150),
      _getTitleItemWidget('Phone number', 150),
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
          child: Text(_userList[index].email.toString(), style: TextStyle(fontFamily: "mon")),
          width: 200,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(_userList[index].name.toString(), style: TextStyle(fontFamily: "mon")),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(_userList[index].phoneNumber.toString(), style: TextStyle(fontFamily: "mon"),),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
       
      ],
    );
  }
}

Widget backgroundHeader(tagihan, contribution) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.only(
        topLeft:Radius.circular(30), topRight: Radius.circular(30)
      ),
      color: Colors.green
    ),
    height: 120,
    width: double.infinity,  
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          tagihan == null ?
          Container( margin: EdgeInsets.only(top: 20), width: 30, height: 30, child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          )) : 
          Column(children: <Widget>[            
            Row(
              children: <Widget>[                
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30,),
                      Text("Tagihan", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),),
                      Text("$tagihan kali", style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 30,),
                      Text("Kontribusi", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),),
                      Text(
                        NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(contribution)
                        , style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),                      
                    ],
                  ),
                ),
              ],
            ),
            
          ],)
        ],
      ),
    ),
  );
}