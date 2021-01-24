import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
      statusBarColor: Colors.green[100], 
    ));

		return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.green,         
        title: Text("INFO", style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'mon')),
        centerTitle: true,
      ),
      body: new Container(
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                cardList('PENGUMUMAN', "pengumuman", context),
                cardList('DATA WARGA', "data_warga", context),
                if (role == "2" || role == "3") cardList('BUAT PENGUMUMAN', "buat_pengumuman", context),
              ],
            ),
          ],
        )
      ),
		);
	}
}

Widget cardList(title, page, context) {
   return Column(
     children: [
       ListTile(  
        tileColor: Colors.green[50],
        title: Text(
          title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "mon"),
        ),
        trailing: Icon(Icons.chevron_right, size: 26, color: Colors.green,),
        onTap: () {  
          if (page == "pengumuman"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PengumumanPage()));  
          }else if(page == "data_warga"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DataWargaPage()));            
          }else if(page == "buat_pengumuman"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BuatPengumumanPage()));
          }
        }
      ),
      Divider(height: 1, color: Colors.green,)
     ],
   );
    
}
