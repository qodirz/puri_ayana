import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PengumumanItem extends StatefulWidget {  
  final pengumumanID;
  bool isRead;
  final title;
  final description; 

  PengumumanItem(this.pengumumanID, this.title, this.description, this.isRead);

  @override
  _PengumumanItemState createState() => _PengumumanItemState();
}

class _PengumumanItemState extends State<PengumumanItem> {

  String accessToken, uid, expiry, client, tagihan; 
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
  }

  getPengumumanDetail(pengumumanID) async {
    print("get pengumuman detail");
    print(pengumumanID);
    print(accessToken);
    try{
      final response = await http.get(NetworkURL.pengumumanDetail(pengumumanID), 
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
        setState(() {
          
        });      
      }else{
      }  
    }on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);            
    } catch (e) {
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
      print("ERROR.........");
      print(e);      
    }
  }

  @override
  void initState() {
    getPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0) ,
      onPressed: () {
        _settingModalBottomSheet(context, widget.title, widget.description);          
        setState(() {
          widget.isRead = true;
        });
        // hit ke api supaya data isRead nya ke update di database
        getPengumumanDetail(widget.pengumumanID);
      }, 
      child: ListTile(
        trailing: Icon(
          Icons.notification_important, size: 26, 
            color: widget.isRead == true ? Colors.grey : Colors.green
          ),
        tileColor: widget.isRead == true ? Colors.green[50] : Colors.green[100],
        title: Text(widget.title,
          style: TextStyle(fontFamily: "mon",),
          overflow: TextOverflow.ellipsis,                                
        ),
        subtitle: Text(widget.description,
          style: TextStyle(fontFamily: "mon",),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    );    
  }

  void _settingModalBottomSheet(context, title, description){
      showModalBottomSheet(
        context: context,
        builder: (BuildContext bc){
          return Container(
            child: new Wrap(
            children: <Widget>[
              new ListTile(
                title: new Text(title, style: TextStyle(fontFamily: "mon", fontWeight: FontWeight.bold),),
                onTap: () => {}          
              ),
              Divider(height: 1, color: Colors.green,), 
              new ListTile(
                title: new Text(description, style: TextStyle(fontFamily: "mon"),),
                onTap: () => {},          
              ),
            ],
          ),
          );
        }
      );
  }

}