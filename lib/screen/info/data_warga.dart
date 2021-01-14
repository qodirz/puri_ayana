import 'dart:io';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class DataWargaPage extends StatefulWidget {
  @override
  _DataWargaPageState createState() => _DataWargaPageState();
}

class _DataWargaPageState extends State<DataWargaPage> {
  List _listWarga = [];
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
    getUsers();
  }

  getUsers() async {
    try{
      _listWarga.clear();
      final response = await http.get(NetworkURL.listWarga(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      print("getUsers");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["users"];
        setState(() {
          isLoading = false;
          for (Map i in data) {
            _listWarga.add( [i["id"], i["email"], i["name"], i["phone_number"]] );            
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
    _listWarga.clear();
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
                          Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 1)));                          
                        },
                        child: Icon(Icons.arrow_back, size: 30,),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "DATA WARGA",                       
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
                      itemCount: _listWarga.length,
                      itemBuilder: (BuildContext context, int index){
                        return Column(
                          children: <Widget>[
                            ListTile(
                              tileColor: Colors.green[50],
                              leading: Icon(LineIcons.user, size: 50),
                              title: Text(_listWarga[index][1]),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(_listWarga[index][2]),
                                  ),
                                  SizedBox(height: 5,),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(_listWarga[index][3]),
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