import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cicilan_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CicilanPage extends StatefulWidget {
  @override
  _CicilanPageState createState() => _CicilanPageState();
}

class _CicilanPageState extends State<CicilanPage> {
  List _listCicilan = [];
  bool isLoading = false;

  String accessToken, uid, expiry, client, tagihan; 
  double contribution;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getCicilan();
  }

  getCicilan() async {
    try{
      _listCicilan.clear();
      final response = await http.get(NetworkURL.cicilan(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      print("getCicilan");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["installments"];
        setState(() {
          isLoading = false;
          for (Map i in data) {
            _listCicilan.add( [i["id"], i["description"], i["value"], i["total_paid"], i["paid_off"]] );            
          }          
        });      
      }else{
        setState(() {
          isLoading = false;                   
        });
      }  
    }on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);            
    } catch (e) {
      print("ERROR.........");
      print(e);
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
    }
    
  }
 
  Future<void> onRefresh() async {
    _listCicilan.clear();
    getPref();
  }

  @override
  void initState() {
    getPref();
    super.initState();
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
              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));              
            },
          ), 
          title: Text("CICILAN", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[                  
                  isLoading == true ?
                    Container(      
                      height: 150,
                      color: Colors.green[50],
                      child: Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.green,
                        )
                      )
                    ) :
                    RefreshIndicator(
                      onRefresh: onRefresh,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: _listCicilan.length,
                        itemBuilder: (BuildContext context, int index){
                          return Column(
                            children: <Widget>[
                              ListTile(
                                tileColor: Colors.green[50],
                                trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green,),
                                title: Text(_listCicilan[index][1].toString(), style: TextStyle(fontFamily: "mon", fontWeight: FontWeight.bold, fontSize: 18)),
                                isThreeLine: true,
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("Total cicilan : " + NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_listCicilan[index][2]), style: TextStyle(fontFamily: "mon")),
                                    ),
                                    SizedBox(height: 2,),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("Total bayar   : " + NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_listCicilan[index][3]), style: TextStyle(fontFamily: "mon")),
                                    ),
                                    SizedBox(height: 2,),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: Text("Status           : " + (_listCicilan[index][4] ? "LUNAS" : "BELUM LUNAS"), style: TextStyle(fontFamily: "mon"),)                                      
                                    ),
                                ],),
                                onTap: () {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CicilanDetailPage(_listCicilan[index][0]) ));
                                },
                              ),
                              Divider(height: 1, color: Colors.green,), //                           <-- Divider
                            ],
                          );
                        },
                      ),
                    )
                    
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}