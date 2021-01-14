import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/home/home.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';



class PengumumanDetailPage extends StatefulWidget {  
  final Data data;
  
  PengumumanDetailPage(this.data);  
  @override
  _PengumumanDetailPageState createState() => _PengumumanDetailPageState();
}

class _PengumumanDetailPageState extends State<PengumumanDetailPage> {
  
  String accessToken, uid, expiry, client, title, description; 
  
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getPengumumanDetail();
  }

  getPengumumanDetail() async {
    try{
      final response = await http.get(NetworkURL.pengumumanDetail(widget.data.pengumumanID), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      print("getPengumumanDetail");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["notification"];
        setState(() {
          title = data["title"];
          description = data["notif"];
        });      
      }else{
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
        body: RefreshIndicator(
          onRefresh: onRefresh,         
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
                            if (widget.data.from == "home"){
                            Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 0)));
                          }else{
                            Navigator.push(context,MaterialPageRoute(builder: (context) => PengumumanPage()));
                          }
                            
                          },
                          child: Icon(Icons.arrow_back, size: 30,),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "PENGUMUMAN DETAIL",                       
                            style: TextStyle(
                              fontSize: 20, fontFamily: "mon"
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 40,),                    
                    title == null ?
                      Container(      
                        height: 150,
                        color: Colors.green[50],
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.green,
                          )
                        )
                      )
                    : Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 4),
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
                          ),
                          child: Text(title.toString(), style: TextStyle(fontSize: 20, fontFamily: "mon", fontWeight: FontWeight.bold),),
                        ),
                        //SizedBox(height: 20,),
                        Container(
                          padding: EdgeInsets.only(bottom: 6, top: 10),
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
                          ),
                          child: Text(description.toString(), style: TextStyle(fontSize: 16, fontFamily: "mon"),),
                        ),
                      ],
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        )
        
      )
    );
  }
}