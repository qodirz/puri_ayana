import 'dart:io';
import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class PengumumanPage extends StatefulWidget {
  final String from;
  const PengumumanPage({this.from});

  @override
  _PengumumanPageState createState() => _PengumumanPageState();
}

class _PengumumanPageState extends State<PengumumanPage> {
  List _pengumumanList = [];

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
    try{
      _pengumumanList.clear();
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
      print("getPengumuman");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["user_notifications"];
        setState(() {
          for (Map i in data) {
            _pengumumanList.add( [i["notification"]["id"], i["notification"]["title"], i["notification"]["notif"], i["is_read"]] );            
          }          
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
                    ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: _pengumumanList.length,
                      itemBuilder: (BuildContext context, int index){
                        return new ListTile(
                          tileColor: _pengumumanList[index][3] == true ? Colors.green[50] : Colors.green[100],
                          title: Text(_pengumumanList[index][1]),
                          subtitle: Text(_pengumumanList[index][2]),
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanDetailPage(_pengumumanList[index][0]) ));
                          },
                        );
                      },
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