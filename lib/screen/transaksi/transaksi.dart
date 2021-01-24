import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cashflow_pertahun.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cicilan.dart';
import 'package:puri_ayana_gempol/screen/transaksi/contribution.dart';
import 'package:puri_ayana_gempol/screen/transaksi/hutang.dart';
import 'package:puri_ayana_gempol/screen/transaksi/iuran_bulanan.dart';
import 'package:puri_ayana_gempol/screen/transaksi/tambah_transaksi.dart';
import 'package:puri_ayana_gempol/screen/transaksi/transaksi_bulanan.dart';

class TransaksiPage extends StatefulWidget {
	
  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  final storage = new FlutterSecureStorage();
	String role, hasDebt;

  Future getStorage() async {
    String roleStorage = await storage.read(key: "role");
    String hasDebtStorage = await storage.read(key: "hasDebt");
    setState(() {
      role = roleStorage;  
      hasDebt = hasDebtStorage;   
    });       
  }

  @override
  void initState() {
    super.initState();
    getStorage();
  }
	@override
	Widget build(BuildContext context) {
		return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: Colors.green,         
        title: Text("TRANSAKSI", style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'mon')),
        centerTitle: true,
      ),
      body: new Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  cardList('CASHFLOW PERTAHUN', "cashflow", context),
                  cardList('TRANSAKSI BULANAN', "transaksi_bulanan", context),
                  if (role != "3") cardList('DATA IURAN', "data_iuran", context),
                  if (hasDebt == "true") cardList('HUTANG SAYA', "hutang", context),
                  cardList('CICILAN', "cicilan", context),
                  if (role == "2" || role == "3") cardList('BAYAR IURAN BULANAN', "iuran_bulanan", context),
                  if (role == "2" || role == "3") cardList('TAMBAH TRANSAKSI', "tambah_transaksi", context),
                ],
              ),
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
          print(page);
          if (page == "cashflow"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CashflowPertahunPage()));  
          }else if (page == "transaksi_bulanan"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TransaksiBulananPage()));
          }else if (page == "data_iuran"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ContributionPage()));
          }else if (page == "hutang"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HutangPage()));
          }else if (page == "cicilan"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CicilanPage()));
          }else if (page == "iuran_bulanan"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => IuranBulananPage()));
          }else if (page == "tambah_transaksi"){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TambahTransaksiPage()));
          }
        }
      ),
      Divider(height: 1, color: Colors.green,)
     ]
  );
}
