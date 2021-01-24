import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/network/network.dart';
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
  final storage = new FlutterSecureStorage();

  String accessToken, uid, expiry, client; 
  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");     
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
    });       
  }
  
  getPengumumanDetail(pengumumanID) async {
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
      if(responJson["success"] == true){
              
      }else{
      }  
    }on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);            
    } catch (e) {
      print(e);      
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
    }
  }

  @override
  void initState() {
    super.initState();
    getStorage();
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