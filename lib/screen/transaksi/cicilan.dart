import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cicilan_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

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
      showTopSnackBar( context,
        CustomSnackBar.error(message: "No Internet connection!"),
      );
    } catch (e) {
      print("ERROR.........");
      print(e);
      showTopSnackBar( context,
        CustomSnackBar.error(message: "Error connection with server!"),
      );
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
    return SafeArea(
      child: Scaffold(
        body: Column(
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
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
                        },
                        child: Icon(Icons.arrow_back, size: 30,),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "CICILAN",                       
                          style: TextStyle(
                            fontSize: 20, fontFamily: "mon"
                          ),
                        ),
                        
                      ],
                    ),
                  ),
                  SizedBox(height: 20,), 
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
                                tileColor: Colors.green[100],
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
                              Divider(), //                           <-- Divider
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