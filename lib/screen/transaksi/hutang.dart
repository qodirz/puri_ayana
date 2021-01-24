import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';

class HutangPage extends StatefulWidget {
  @override
  _HutangPageState createState() => _HutangPageState();
}

class _HutangPageState extends State<HutangPage> {
  final storage = new FlutterSecureStorage();
  List _listHutang = [];
  bool isLoading = false;

  String accessToken, uid, expiry, client; 
  dynamic totalPinjam, totalBayar, sisaHutang;

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
    getHutang();     
  }

  getHutang() async {
    try{
      _listHutang.clear();
      final response = await http.get(NetworkURL.hutang(), 
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
        final data = responJson["debts"];
        setState(() {
          isLoading = false;
          totalPinjam = responJson["total_pinjam"];
          totalBayar = responJson["total_bayar"];
          sisaHutang = responJson["sisa_hutang"];
          for (Map i in data) {
            _listHutang.add( [i["id"], i["description"], i["value"], i["debt_date"]] );            
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
      print(e);      
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
    }    
  }
 
  Future<void> onRefresh() async {    
    getHutang();
  }

  @override
  void initState() {
    super.initState();
    getStorage();
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
                padding: EdgeInsets.all(10),
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
                          "DATA HUTANG",                       
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
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _listHutang.length,
                      itemBuilder: (BuildContext context, int index){
                        return Column(
                          children: <Widget>[
                            ListTile(
                              tileColor: Colors.green[50],
                              title: Text(_listHutang[index][1].toString(), style: TextStyle(fontFamily: "mon", fontWeight: FontWeight.bold, fontSize: 18)),                              
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("Jumlah   : " + NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_listHutang[index][2]), style: TextStyle(fontFamily: "mon")),                                    
                                  ),
                                  SizedBox(height: 5,),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(_listHutang[index][3]),
                                  ),
                              ],), 
                              isThreeLine: true,                              
                            ),
                            Divider(),
                          ],
                        );
                      },
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