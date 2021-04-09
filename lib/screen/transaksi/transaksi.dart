import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
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
        backgroundColor: baseColor,
        title: Text("TRANSAKSI",
            style: TextStyle(fontSize: 30, fontFamily: 'bold')),
        centerTitle: true,
      ),
      body: new Container(
          child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                cardList(
                  'TRANSAKSI KAS PERTAHUN',
                  "cashflow",
                  Icons.money,
                  Colors.green[50],
                  Colors.green[200],
                  context,
                ),
                cardList(
                  'TRANSAKSI KAS BULANAN',
                  "transaksi_bulanan",
                  Icons.monetization_on_outlined,
                  Colors.cyan[50],
                  Colors.cyan[200],
                  context,
                ),
                if (role != "3")
                  cardList(
                    'DATA IURAN',
                    "data_iuran",
                    Icons.attach_money,
                    Colors.orange[50],
                    Colors.orange[200],
                    context,
                  ),
                if (hasDebt == "true")
                  cardList(
                    'HUTANG SAYA',
                    "hutang",
                    Icons.money_off_csred_outlined,
                    Colors.teal[50],
                    Colors.teal[200],
                    context,
                  ),
                cardList(
                  'CICILAN',
                  "cicilan",
                  Icons.payments,
                  Colors.purple[50],
                  Colors.purple[200],
                  context,
                ),
                if (role == "2" || role == "3")
                  cardList(
                    'BAYAR IURAN BULANAN',
                    "iuran_bulanan",
                    Icons.payments_outlined,
                    Colors.red[50],
                    Colors.red[200],
                    context,
                  ),
                if (role == "2" || role == "3")
                  cardList(
                    'TAMBAH TRANSAKSI',
                    "tambah_transaksi",
                    Icons.add_box_outlined,
                    Colors.blue[50],
                    Colors.blue[200],
                    context,
                  ),
              ],
            ),
          ),
        ],
      )),
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
      dense: true,
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
      trailing: Icon(Icons.more_vert, color: textColor),
      onTap: () {
        if (page == "cashflow") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => CashflowPertahunPage()));
        } else if (page == "transaksi_bulanan") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TransaksiBulananPage()));
        } else if (page == "data_iuran") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => ContributionPage()));
        } else if (page == "hutang") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HutangPage()));
        } else if (page == "cicilan") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => CicilanPage()));
        } else if (page == "iuran_bulanan") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => IuranBulananPage()));
        } else if (page == "tambah_transaksi") {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => TambahTransaksiPage()));
        }
      },
    ),
  );
}
