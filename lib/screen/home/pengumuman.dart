import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/model/userModel.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PengumumanPage extends StatefulWidget {
  final String from;
  const PengumumanPage({this.from});

  @override
  _PengumumanPageState createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  List<UserModel> _userList = [];

  String accessToken, uid, expiry, client, tagihan; 
  double contribution;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getPengumuman();
  }

  getPengumuman() async {
    _userList.clear();
    final response = await http.get(NetworkURL.pengumuman(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    });
    
    final responJson = json.decode(response.body);
    print("getgetPengumuman");
    print(responJson);
    if(responJson["success"] == true){
      final data = responJson;
      setState(() {
        contribution = double.parse(responJson["address"]["contribution"]);
        tagihan = responJson["tagihan"].toString();
        for (Map i in data) {
          _userList.add(UserModel.fromJson(i));
        }          
      });      
    }else{
    }  
  }
 
  @override
  void initState() {
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(          
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
                            if (widget.from == "home"){
                              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 0)));
                            }else{
                              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 1)));
                            }
                          },
                          child: Icon(Icons.arrow_back, size: 30,),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "PENGUMUMAN",                       
                            style: TextStyle(
                              fontSize: 20, fontFamily: "mon"
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 20,), 
                    _getBodyWidget(),                   
                  ],
                ),
              ),
            ],
          ),
        )
        
      )
    );
  }

  Widget _getBodyWidget() {
    return Container(
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 0,
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
        rightHandSideColBackgroundColor: Colors.green[50],
      ),
      height: (MediaQuery.of(context).size.height - 300 ),
    );
  }

  List<Widget> _getTitleWidget() {
    return [      
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