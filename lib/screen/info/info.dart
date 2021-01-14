import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/screen/info/buat_pengumuman.dart';
import 'package:puri_ayana_gempol/screen/info/data_warga.dart';
import 'package:puri_ayana_gempol/screen/info/pengumuman.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InfoPage extends StatefulWidget {
  
	@override
	State<StatefulWidget> createState() {
		return new _InfoPageState();
	}
}

class _InfoPageState extends State<InfoPage> {
	GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int role;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      role = pref.getInt("role");
    }); 
  }

  @override
  void initState() {
    getPref();
    super.initState();
  }

	@override
	Widget build(BuildContext context) {
		return new Scaffold(
      resizeToAvoidBottomInset: false, 
			key: _scaffoldKey,
      body: new Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    //overflow: Overflow.visible,                
                    children: <Widget>[backgroundHeader()],
                  ),
                  SizedBox(height: 10),                  
                  cardList('PENGUMUMAN', "pengumuman", context),
                  cardList('DATA WARGA', "data_warga", context),
                  if (role == 2 || role == 3) cardList('BUAT PENGUMUMAN', "buat_pengumuman", context),
                ],
              ),
            ),
          ],
        )
      ),
		);
	}

}

Widget backgroundHeader() {
  return Container(
    color: Colors.green[300],
    height: 90,
    width: double.infinity,    
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "INFO",
            style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'mon'),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

Widget cardList(title, page, context) {
  return Card(    
    color: Colors.green[100],
    margin: EdgeInsets.only(top: 10, left: 20, right: 20),
    elevation: 10,
    child: ListTile(  
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "mon"),
      ),
      trailing: Icon(Icons.chevron_right, size: 26,),
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
  );
}
