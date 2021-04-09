import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/screen/info/buat_pengumuman.dart';
import 'package:puri_ayana_gempol/screen/info/data_warga.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final storage = new FlutterSecureStorage();
  String role;

  Future getStorage() async {
    String roleStorage = await storage.read(key: "role");
    setState(() {
      role = roleStorage;
    });
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: baseColor100,
    ));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: baseColor,
        title: Text("INFO", style: TextStyle(fontSize: 30, fontFamily: 'bold')),
        centerTitle: true,
      ),
      body: new Stack(children: [
        ListView(
          padding: EdgeInsets.all(20),
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                cardList(
                  'PENGUMUMAN',
                  "pengumuman",
                  Icons.view_list_outlined,
                  Colors.blue[50],
                  Colors.blue[200],
                  context,
                ),
                cardList(
                  'DATA WARGA',
                  "data_warga",
                  Icons.supervised_user_circle_sharp,
                  Colors.orange[50],
                  Colors.orange[200],
                  context,
                ),
                if (role == "2")
                  cardList(
                    'BUAT PENGUMUMAN',
                    "buat_pengumuman",
                    Icons.add_alert_outlined,
                    Colors.green[50],
                    Colors.green[200],
                    context,
                  ),
              ],
            ),
          ],
        )
      ]),
    );
  }
}

Widget cardList(title, page, IconData icon, bgColor, textColor, context) {
  return Container(
    padding: EdgeInsets.all(2),
    margin: EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      border: Border.all(color: textColor),
      borderRadius: BorderRadius.all(Radius.circular(18)),
      color: bgColor,
    ),
    child: ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50)),
          color: textColor,
        ),
        child: Icon(
          icon,
          size: 30,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'bold', color: textColor),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: textColor,
      ),
      onTap: () {
        if (page == "pengumuman") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => PengumumanPage()));
        } else if (page == "data_warga") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => DataWargaPage()));
        } else if (page == "buat_pengumuman") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => BuatPengumumanPage()));
        }
      },
    ),
  );
}
