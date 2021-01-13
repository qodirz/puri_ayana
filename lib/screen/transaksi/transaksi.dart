import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/screen/home/home.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cashflow_pertahun.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:puri_ayana_gempol/screen/transaksi/iuran_bulanan.dart';
import 'package:puri_ayana_gempol/screen/transaksi/tambah_transaksi.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransaksiPage extends StatefulWidget {
	@override
	State<StatefulWidget> createState() {
		return new _TransaksiPageState();
	}
}

class _TransaksiPageState extends State<TransaksiPage> {
	int role;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      role = pref.getInt("role");
    }); 
  }
	
  _gotoPage(){
     Navigator.of(context).push(MaterialPageRoute<Null>(builder: (BuildContext context) {
                  return new Home();
                }));
  }

  @override
  void initState() {
    super.initState();
    getPref();    
  }
	@override
	Widget build(BuildContext context) {
		return new Scaffold(
      resizeToAvoidBottomInset: false,			
      body: new Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    overflow: Overflow.visible,                
                    children: <Widget>[backgroundHeader()],
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 560,
                    child: ListView(                      
                      children: <Widget>[
                        cardList('CASHFLOW PERTAHUN', "cashflow", context),
                        cardList('TRANSAKSI BULANAN', _gotoPage, context),
                        cardList('DATA IURAN', "data_iuran", context),
                        cardList('HUTANG', "hutang", context),
                        if(role == 2) cardList('BAYAR IURAN BULANAN', "iuran_bulanan", context),
                        if(role == 2) cardList('TAMBAH TRANSAKSI', "tambah_transaksi", context),
                      ],
                    ),
                  ),
                  
                  
                  
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
            "TRANSAKSI",
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
        print(page);
        if (page == "cashflow"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CashflowPertahunPage()));  
        }else if (page == "data_iuran"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContributionPage()));
        }else if (page == "hutang"){
          
        }else if (page == "iuran_bulanan"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IuranBulananPage()));
        }else if (page == "tambah_transaksi"){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TambahTransaksiPage()));
        }
      }
    ),
  );
}
