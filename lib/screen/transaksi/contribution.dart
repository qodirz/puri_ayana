import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/contributionModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ContributionPage extends StatefulWidget {
  final String from;
  const ContributionPage({this.from});

  @override
  _ContributionPageState createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  List<ContributionModel> _contributionList = [];

  String accessToken, uid, expiry, client, title, tagihan; 
  ContributionModel contributionModel; 
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getContributions();
  }

  getContributions() async {
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
                              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
                            }
                          },
                          child: Icon(Icons.arrow_back, size: 30,),
                          ),
                          SizedBox(width: 4, ),
                          Text(
                            "KONTRIBUSI",                              
                            style: TextStyle(fontSize: 20, fontFamily: "mon" ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    backgroundHeader(title, tagihan), 
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