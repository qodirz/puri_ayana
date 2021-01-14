import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HutangPage extends StatefulWidget {
  @override
  _HutangPageState createState() => _HutangPageState();
}

class _HutangPageState extends State<HutangPage> {
  List _listHutang = [];
  bool isLoading = false;

  String accessToken, uid, expiry, client; 
  dynamic totalPinjam, totalBayar, sisaHutang;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getHutang();
  }

  getHutang() async {
    //try{
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
      print("getHutang");
      print(responJson);
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
    // }on SocketException {
    //   showTopSnackBar( context,
    //     CustomSnackBar.error(message: "No Internet connection!"),
    //   );
    // } catch (e) {
    //   print("ERROR.........");
    //   print(e);
    //   showTopSnackBar( context,
    //     CustomSnackBar.error(message: "Error connection with server!"),
    //   );
    // }    
  }
 
  Future<void> onRefresh() async {
    _listHutang.clear();
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