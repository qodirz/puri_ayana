import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/custom/local_notification.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/home/blok_detail.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman.dart';
import 'package:puri_ayana_gempol/screen/login.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cashflow_pertahun.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<dynamic> onBackgroundMessage(message) {
  if (message != null) {
    return LocalNotification.showNotification(message);
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final firebaseMessaging = FirebaseMessaging();
  final storage = new FlutterSecureStorage();
  String accessToken, uid, expiry, client, name, role, avatar;
  int notifID;
  String notifTitle, notifDescription;
  String blok = "";
  int tagihan, tahun;
  dynamic pemasukan = 0, pengeluaran = 0, total = 0, totalSisa;
  String token = '';

  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    String nameStorage = await storage.read(key: "name");
    String roleStorage = await storage.read(key: "role");
    String avatarStorage = await storage.read(key: "avatar");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      name = nameStorage;
      role = roleStorage;
      avatar = avatarStorage;
    });
    getHome();
  }

  getHome() async {
    try {
      final response =
          await http.get(NetworkURL.homePage(), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
        setState(() {
          blok = responJson['blok'];
          tagihan = responJson['tagihan'] == null ? 0 : responJson['tagihan'];
          tahun = responJson['cash_flow']['year'];
          pemasukan = responJson['cash_flow']['pemasukan'];
          pengeluaran = responJson['cash_flow']['pengeluaran'];
          total = pemasukan - pengeluaran;
          totalSisa = responJson['total_sisa_kas'];
        });
      } else {
        //error, user harus login ulang
        await storage.deleteAll();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false);
      }
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
    }
  }

  Future<void> onRefresh() async {
    getHome();
  }

  void _navigate(Map<String, dynamic> message) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => PengumumanPage()));
  }

  @override
  void initState() {
    firebaseMessaging.configure(
      onMessage: (message) async {
        print('onMessage');
        print(message);
        if (message != null) LocalNotification.showNotification(message);
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
        if (message != null) LocalNotification.showNotification(message);
      },
    );
    super.initState();
    getStorage();
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
        body: Container(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(20),
                    children: <Widget>[
                      Stack(
                        clipBehavior: Clip.none,
                        fit: StackFit.loose,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
                            height: 180,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.cyan[400], width: 2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18)),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.cyan[100],
                                  Colors.lightBlue[100],
                                  Colors.cyan[500]
                                ],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  name != null ? name : "-",
                                  style: TextStyle(
                                    fontFamily: 'bold',
                                    color: Colors.blueGrey[700],
                                    fontSize: 24,
                                  ),
                                ),
                                if (role != 3)
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BlokDetailPage(blok),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          blok != null ? "BLOK $blok" : null,
                                          style: TextStyle(
                                            fontFamily: 'bold',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Colors.white),
                                        ),
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ContributionPage(
                                                      from: "home"),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          tagihan != null
                                              ? "Tagihan: " +
                                                  tagihan.toString() +
                                                  " kali"
                                              : "-",
                                          style: TextStyle(
                                            fontFamily: 'bold',
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Center(
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: baseColor50),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  backgroundColor: baseColor300,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: profileAvatar(avatar),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(2),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple[200]),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          color: Colors.purple[50],
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            width: 48,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.purple[200],
                            ),
                            child: Icon(
                              Icons.attach_money_outlined,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          title: Text("Transaksi $tahun",
                              style: TextStyle(
                                fontFamily: 'bold',
                                color: Colors.purple[400],
                              )),
                          subtitle: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "TOTAL :",
                                  style: TextStyle(
                                    fontFamily: 'bold',
                                    color: Colors.purple[400],
                                  ),
                                ),
                              ),
                              Text(
                                NumberFormat.currency(
                                        locale: 'id',
                                        symbol: 'Rp ',
                                        decimalDigits: 0)
                                    .format(total),
                                style: TextStyle(
                                    fontFamily: 'bold',
                                    color:
                                        (total < 0) ? Colors.red : Colors.blue),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.more_vert,
                            color: Colors.purple[400],
                          ),
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CashflowPertahunPage(from: "home"),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(2),
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.cyan[300]),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                          color: Colors.cyan[100],
                        ),
                        child: ListTile(
                          dense: true,
                          leading: Container(
                            width: 48,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              color: Colors.cyan[300],
                            ),
                            child: Icon(
                              Icons.attach_money_outlined,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            (totalSisa != null ? totalSisa["title"] : "0"),
                            style: TextStyle(
                                fontFamily: 'bold', color: Colors.cyan[400]),
                          ),
                          subtitle: Text(
                            NumberFormat.currency(
                                    locale: 'id',
                                    symbol: 'Rp ',
                                    decimalDigits: 0)
                                .format((totalSisa != null
                                    ? totalSisa["remaining"]
                                    : 0)),
                            style: TextStyle(
                                fontFamily: 'bold',
                                color: (totalSisa != null &&
                                        totalSisa["remaining"] < 0)
                                    ? Colors.red
                                    : Colors.blue),
                          ),
                          trailing: Icon(
                            Icons.more_vert,
                            color: Colors.cyan[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget profileAvatar(avatar) {
  if (avatar != null) {
    return Image.network(avatar, fit: BoxFit.cover, height: 200, width: 200);
  } else {
    return Icon(
      Icons.verified_user,
      size: 120,
      color: Colors.white,
    );
  }
}
