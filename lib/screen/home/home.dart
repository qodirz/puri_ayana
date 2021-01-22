import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/local_notification.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/home/blok_detail.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman_detail.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cashflow_pertahun.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<dynamic> onBackgroundMessage(message) {
  if(message != null){
    return LocalNotification.showNotification(message);
  }  
}

class Home extends StatefulWidget {  
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {  
  final firebaseMessaging = FirebaseMessaging();
  String accessToken, uid, expiry, client, name, avatar;
  int notifID, role;
  String notifTitle, notifDescription; 
  String blok = "";
  int tagihan, tahun;
  dynamic pemasukan = 0, pengeluaran = 0, total = 0, totalSisa;
  String token = '';
  List _pengumumanList = [];
  
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");     
      name = pref.getString("name");
      role = pref.getInt("role");
      avatar = pref.getString("avatar");
    });
    getHome();
  }

  getHome() async {
    print("masuk ke home yah");
    try {
      _pengumumanList.clear();
      final response = await http.get(NetworkURL.homePage(), 
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
        setState(() {
          blok = responJson['blok'];
          tagihan = responJson['tagihan'] == null ? 0 : responJson['tagihan'];
          tahun = responJson['cash_flow']['year'];
          pemasukan = responJson['cash_flow']['pemasukan'];
          pengeluaran = responJson['cash_flow']['pengeluaran'];
          total = pemasukan - pengeluaran;
          totalSisa = responJson['total_sisa_kas'];
          for (Map i in responJson["notifications"]) {
            _pengumumanList.add( [i["notification"]["id"], i["notification"]["title"], i["notification"]["notif"], i["is_read"]] );            
          }
        });
      }else{
        //error, user harus login ulang
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), 
        (Route<dynamic> route) => false);  
      }    
    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      print("ERROR.........");
      print(e);
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);
    }
    
  }
  
  Future<void> onRefresh() async {
    _pengumumanList.clear();    
    getPref();
  }
  
  void _navigate(Map<String, dynamic> message) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanPage()));          
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (message) async {
        print('onMessage');
        print(message);
        if(message != null) LocalNotification.showNotification(message);
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (message) async {
        print('onResume');
        print(message);
        _navigate(message);
      },
      onLaunch: (message) async {
        print('onLaunch');
        print(message);  
        if(message != null) LocalNotification.showNotification(message);
      },
    );
    super.initState();
    getPref(); 
    _requestPermissions();  
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.green[50],
        body: RefreshIndicator(
          onRefresh: onRefresh,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    Stack(
                      clipBehavior: Clip.none,
                        fit: StackFit.loose,
                        children: <Widget>[
                          Container(
                            height: 180,
                            color: Colors.green[400],
                          ),
                          Positioned(
                            right: 80,
                            bottom: -60,
                            child: Center(
                              child: Container(
                                height: 200,
                                width: 200,
                                decoration: BoxDecoration(
                                  border:Border.all(width: 1, color: Colors.green[50]),
                                  shape: BoxShape.circle,                                                      
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.green[300],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: profileAvatar(avatar),                              
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]
                      ),
                    SizedBox(height: 60,),
                    Center(
                      child: Text(name != null ? name : "-",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, fontFamily: "mon"),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(height: 1, color: Colors.green,),
                    if(role != 3) ListTile(  
                      tileColor: Colors.green[50],
                      title: Text(
                        "Blok anda", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),
                      subtitle: blok == "" ?
                        null :
                        Text( "$blok", style: TextStyle( color: Colors.black, fontSize: 20, fontFamily: "mon" ),                                        
                      ),
                      trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green,),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlokDetailPage(blok)));
                      }
                    ),
                    Divider(height: 1, color: Colors.green,),
                    if(role != 3) ListTile(  
                      tileColor: Colors.green[50],
                      title: Text(
                        "Tagihan anda", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),
                      subtitle: tagihan == null ?
                        null :
                        Text( "$tagihan kali", style: TextStyle( color: Colors.black, fontSize: 20, fontFamily: "mon" ),                                        
                      ),
                      trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContributionPage(from: "home")));
                      }
                    ),
                    Divider(height: 1, color: Colors.green),
                    ListTile(  
                      tileColor: Colors.green[50],
                      title: Text(
                        "Cash flow $tahun", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text("TOTAL :", style: TextStyle( fontSize: 18, fontFamily: "mon", color: Colors.black ),),
                          ),
                          Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total), 
                              style: TextStyle(
                              fontSize: 18, 
                              fontFamily: "mon", 
                              color: (total < 0) ? Colors.red : Colors.blue 
                            ), 
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green,),
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CashflowPertahunPage(from: "home")));
                      }
                    ),
                    Divider(height: 1, color: Colors.green,),
                    ListTile(  
                      tileColor: Colors.green[50],
                      title: Text(
                        (totalSisa != null ? totalSisa["title"] : "0"), style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon"),
                      ),
                      subtitle: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format((totalSisa != null ? totalSisa["remaining"] : 0)), 
                          style: TextStyle(
                          fontSize: 18, 
                          fontFamily: "mon", 
                          color: (total < 0) ? Colors.red : Colors.blue 
                        ), 
                      ),   
                    ),
                    Divider(height: 1, color: Colors.green,),                
                    Container(
                      color: Colors.green[50],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16,),
                          Text( "Pengumuman", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, fontFamily: "mon" )),                        
                          SizedBox(height: 10),
                          Divider(height: 1, color: Colors.green,),                        
                          SizedBox(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemCount: _pengumumanList.length,
                              itemBuilder: (BuildContext context, int index){
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    PengumumanItem(_pengumumanList[index][0], _pengumumanList[index][1], _pengumumanList[index][2], _pengumumanList[index][3]),
                                    Divider(height: 1, color: Colors.green,),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],                        
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget profileAvatar(avatar) { 
  if(avatar != null){
    return Image.network(        
      "${avatar}",
      fit: BoxFit.cover,
      height: 200,
      width: 200
    );
  }else{
    return Icon(Icons.verified_user, size: 120, color: Colors.white,);
  }
}