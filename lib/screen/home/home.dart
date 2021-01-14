import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/home/blok_detail.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman_detail.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:puri_ayana_gempol/custom/colored_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {  
  String accessToken, uid, expiry, client, greetingMes, name;
  int notifID, role;
  String notifTitle, notifDescription; 
  String bulan = "";
  String blok = "";
  int tagihan, tahun;
  dynamic pemasukan = 0, pengeluaran = 0, total = 0;
  final firebaseMessaging = FirebaseMessaging();
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
    });

    getHome();
  }

  getHome() async {
    print("masuk ke home yah");
    //try {
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
      debugPrint(responJson.toString());
      print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
      if(responJson["success"] == true){
        setState(() {
          blok = responJson['blok'];
          tagihan = responJson['tagihan'] == null ? 0 : responJson['tagihan'];
          bulan = responJson['cash_flow']['month'];
          tahun = responJson['cash_flow']['year'];
          pemasukan = responJson['cash_flow']['pemasukan'];
          pengeluaran = responJson['cash_flow']['pengeluaran'];
          total = pemasukan - pengeluaran;
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
    // } on SocketException {
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
    _pengumumanList.clear();    
    getPref();
  }

  static Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) {
    debugPrint('onBackgroundMessage: $message');   
    return null;
  }
  
  void _serialiseAndNavigate(Map<String, dynamic> message) {
    print("_serialiseAndNavigate");
    var notificationData = message['data'];
    print(notificationData);
    if (notificationData["notif_id"] != null) {
      final data = Data(
        pengumumanID: int.parse(notificationData["notif_id"]),
        from: "xxx"
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanDetailPage(data)));
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanDetailPage(int.parse(notificationData["notif_id"]))));
    }
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint('onMessage: $message');
        showTopSnackBar( context,
          CustomSnackBar.info(message: message["notification"]["title"]),
        );
      },
      onBackgroundMessage: onBackgroundMessage,
      onResume: (Map<String, dynamic> message) async {
        debugPrint('onResume: $message');
        _serialiseAndNavigate(message);        
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint('onLaunch: $message');
      },
    );
    firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(sound: true, badge: true, alert: true, provisional: true),
    );
    firebaseMessaging.onIosSettingsRegistered.listen((settings) {
      print('Settings registered: $settings');
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
    return 'Selamat Malam';
    }
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
                  ColoredCard(
                    padding: 2,
                    headerColor: Color(0xFF6078dc),
                    footerColor: Color(0xFF6078dc),
                    cardHeight: 140,
                    elevation: 4,
                    bodyColor: Color(0xFF6c8df6),
                    showFooter: false,
                    showHeader: false,
                    bodyGradient: LinearGradient(
                      colors: [
                        Colors.green[100],
                        Colors.green,
                        Colors.green[200],
                      ],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      stops: [0, 0.2, 1],
                    ),
                    bodyContent: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        top: 30,
                        right: 30,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Hi $name",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: "mon"),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "$greetingMes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: "mon",
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 5,),
                  if(role != 3) Card(
                    color: Colors.green[100],
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
                            Center(
                              child: blok == "" ?
                              CircularProgressIndicator(backgroundColor: Colors.white, ) :
                              Text( "$blok", style: TextStyle( color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                            ),
                          ],
                        )
                      )
                    )
                  ),
                  if(role != 3) Card(         
                    color: Colors.green[100],
                    child: InkWell(
                      onTap: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContributionPage(from: "home")));
                      },
                      child: Padding( 
                        padding: EdgeInsets.all(10),
                          child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,                              
                          children: <Widget>[
                            Text( "Tagihan anda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon" ), textAlign: TextAlign.left,),
                            Center(
                              child: tagihan == null ?
                              CircularProgressIndicator(backgroundColor: Colors.white, ) :
                              Text("$tagihan", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                            ),
                            Center(
                              child: Text( "kali", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                            ),
                          ],
                        )
                      )
                    )
                  ),
                  Card(                                       
                    color: Colors.green[100],
                    child: InkWell(
                      onTap: () {
                          print("tapping info");
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text( "Cash flow $bulan $tahun", style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                            SizedBox(height: 5),
                            Row(
                              children: <Widget>[
                                Column(
                                  children: <Widget>[
                                    Text("Pemasukan",style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                    Text(
                                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(pemasukan),
                                      style: TextStyle( fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon" ),
                                    ),
                                  ],
                                ),
                                Spacer(flex: 1,),
                                Column(
                                  children: <Widget>[
                                    Text("Pengeluaran",style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                    Text(
                                      NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(pengeluaran),
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "mon" ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("TOTAL", style: TextStyle( fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "mon" ),),
                                Text(
                                  NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(total), 
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold, 
                                    fontFamily: "mon", 
                                    color: (total < 0) ? Colors.red : Colors.blue 
                                  ), 
                                ),
                            ],)
                          ],
                        )
                      )
                      
                    )
                  ),
                  Card(
                    color: Colors.green[100],
                    child: InkWell(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlokDetailPage(blok)));
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text( "Pengumuman", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "mon" )),
                            SizedBox(height: 10),
                            SizedBox(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: BouncingScrollPhysics(),
                                itemCount: _pengumumanList.length,
                                itemBuilder: (BuildContext context, int index){
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListTile(
                                        tileColor: _pengumumanList[index][3] == true ? Colors.green[200] : Colors.green[400],
                                        title: Text(_pengumumanList[index][1],
                                          style: TextStyle(fontFamily: "mon", fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,                                          
                                        ),
                                        subtitle: Text(_pengumumanList[index][2],
                                          style: TextStyle(fontFamily: "mon",),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                        onTap: () {
                                          final data = Data(
                                            pengumumanID: _pengumumanList[index][0],
                                            from: "home"
                                          );
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanDetailPage(data)));                                          
                                        },
                                      ),
                                      Divider(), //                           <-- Divider
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],                        
                        ),
                      ),
                    ),
                  ),
                  
                    
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class Data {
  int pengumumanID;
  String from;
  Data({this.pengumumanID, this.from});
}