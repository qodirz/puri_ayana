import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/home/blok_detail.dart';
import 'package:puri_ayana_gempol/screen/home/pengumuman.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {  
  String accessToken, uid, expiry, client, greetingMes, name, blok, pengumuman, bulan;
  String info = "";
  int tagihan, tahun;
  double pemasukan = 0, pengeluaran = 0;
  final firebaseMessaging = FirebaseMessaging();
  String token = '';
  
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");     
      name = pref.getString("name");     
    });

    getHome();
  }

  getHome() async {
    print("masuk ke home yah");
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
    print(responJson);
    if(responJson["success"] == true){
      setState(() {
        info = responJson['info'];
        blok = responJson['blok'];
        tagihan = responJson['tagihan'];
        bulan = responJson['cash_flow']['month'];
        tahun = responJson['cash_flow']['year'];
        pemasukan = responJson['cash_flow']['pemasukan'];
        pengeluaran = responJson['cash_flow']['pengeluaran'];
        pengumuman = responJson['information'];
      });
    }else{
      //error, user harus login ulang
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Login()), 
      (Route<dynamic> route) => false);  
    }  
  }
  
  Future<void> onRefresh() async {
    getPref();
  }

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage: $message');   
    return null;
  }

  void _serialiseAndNavigate(Map<String, dynamic> message) {
    print("_serialiseAndNavigate");
    var notificationData = message['data'];
    var view = notificationData['view'];
    print(message);
    print(notificationData);

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanPage(from: "home")));
    if (view != null) {
      // Navigate to the specific page view
      if (view == 'Home') {
       // Call the view method in the notification data
        //Get.to(Home()); // Use the Get Package
      }
    
    }
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        //_serialiseAndNavigate(message);
        debugPrint('onMessage: $message');
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        //_serialiseAndNavigate(message);
        debugPrint('onResume: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        //_serialiseAndNavigate(message);
        debugPrint('onLaunch: $message');
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      debugPrint('Settings registered: $settings');
    });
    super.initState();
    getPref();
    greetingMes = greetingMessage();
  }

  
  String greetingMessage(){
    var timeNow = DateTime.now().hour;    
    if (timeNow <= 12) {
      return 'Selamat Pagi';
    } else if ((timeNow > 12) && (timeNow <= 17)) {
    return 'Selamat Sore';
    } else {
    return 'Good Malam';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: Container(                        
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 250,
                  padding: EdgeInsets.all(10),                                        
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 0)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text("Hi $name, $greetingMes", style: 
                        TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "mon"),
                        textAlign: TextAlign.left,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                       
                        child: SizedBox(
                          height: 142,                                                    
                          child: ListView(                            
                            children: <Widget>[
                              Html(data: info),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                ),
                SizedBox(height: 20,),
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 165,                    
                    child: GridView.count(                        
                      childAspectRatio: 1,
                      crossAxisCount: 2,
                      children: <Widget>[                     
                        Card(
                          color: Colors.green[50],
                          child: InkWell(
                            onTap: () {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlokDetailPage(blok)));                                
                            },
                            child: Padding( 
                              padding: EdgeInsets.all(10),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text( "Blok anda", style: TextStyle( color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon"), textAlign: TextAlign.left,),
                                  SizedBox(height: 20),
                                  Center(
                                    child: blok == null ?
                                    CircularProgressIndicator(backgroundColor: Colors.white, ) :
                                    Text( "$blok", style: TextStyle( color: Colors.black, fontSize: 50, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                  ),
                                ],
                              )
                            )
                          )
                        ),
                        Card(         
                          color: Colors.green[50],
                          child: InkWell(
                            onTap: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContributionPage(from: "home")));
                            },
                            child: Padding( 
                              padding: EdgeInsets.all(10),
                                child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,                              
                                children: <Widget>[
                                  Text( "Tagihan anda", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "mon" ), textAlign: TextAlign.left,),
                                  SizedBox(height: 20),
                                  Center(
                                    child: tagihan == null ?
                                    CircularProgressIndicator(backgroundColor: Colors.white, ) :
                                    Text("$tagihan", style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                  ),
                                  Center(
                                    child: Text( "kali", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                  ),
                                ],
                              )
                            )
                          )
                        ),
                      ],
                    )
                  )
                  
                ),
                SizedBox(height: 6,),
                Expanded(                                       
                  child: GridView.count(    
                    childAspectRatio: 3,
                    crossAxisCount: 1,
                    mainAxisSpacing: 2,
                    children: <Widget>[                     
                      Card(                              
                        color: Colors.green[50],
                        child: InkWell(
                          onTap: () {
                              print("tapping info");
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 5, left: 20, right: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text( "Cash flow $bulan $tahun", style: TextStyle( fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                Row(
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text("Pemasukan",style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                        Text(
                                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(pemasukan),
                                          style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon" ),
                                        ),
                                      ],
                                    ),
                                    Spacer(flex: 1,),
                                    Column(
                                      children: <Widget>[
                                        Text("Pengeluaran",style: TextStyle( fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                        Text(
                                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(pengeluaran),
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon" ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          )
                          
                        )
                      ),
                      Card(         
                        color: Colors.green[50],
                        child: InkWell(
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanPage(from: "home")));
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text( "Pengumuman", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                            ],
                          ),
                        )
                      ),
                    ],
                  )
                )
              ],
            ),
          )
        ),
      ),
    );
    
  }
}