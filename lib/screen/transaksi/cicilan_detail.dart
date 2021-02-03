import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:puri_ayana_gempol/screen/transaksi/cicilan.dart';
import 'dart:convert';

class CicilanDetailPage extends StatefulWidget {  
  final int cicilanID;
  CicilanDetailPage(this.cicilanID);

  @override
  _CicilanDetailPageState createState() => _CicilanDetailPageState();
}

class _CicilanDetailPageState extends State<CicilanDetailPage> {
  final storage = new FlutterSecureStorage();
  String accessToken, uid, expiry, client, description; 
  dynamic totalPaid = 0, remainingInstallment = 0;
  List _listInstallmentTransactions = [];  
  bool isLoading = false;
  
  Future getStorage() async {
    String tokenStorage = await storage.read(key: "accessToken");     
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
    });    
    getCicilanDetail();   
  }

  getCicilanDetail() async {
    try{
      final response = await http.get(NetworkURL.cicilanDetail(widget.cicilanID), 
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
        final data = responJson["installment"];
        final installmentTransactionsData = responJson["installment_transactions"];
        setState(() {
          description = data["description"];
          totalPaid = data["total_paid"];
          remainingInstallment = data["remaining_installment"];
          isLoading = false;
          for (Map i in installmentTransactionsData) {
            _listInstallmentTransactions.add( [i["id"], i["description"], i["value"] ] );            
          }
        });      
      }else{
        setState(() {
          isLoading = false;
        });
      }  
    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      print(e);
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);      
    }
  }
 
  Future<void> onRefresh() async {
    _listInstallmentTransactions.clear();
    setState(() {
      isLoading = true;
    });
    getCicilanDetail();
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

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => CicilanPage()));
            },
          ), 
          title: Text("CICILAN DETAIL", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: onRefresh,         
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10),
                  children: <Widget>[
                    isLoading == true ?
                      Container(      
                        height: 150,
                        color: Colors.green[50],
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.green,
                          )
                        )
                      )
                    : Column(
                      children: [
                        Container(
                          width: double.infinity, 
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
                          ),
                          child: Text(description.toString(), style: TextStyle(fontSize: 22, fontFamily: "mon", fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(height: 20,),
                        _totalPaidData(),
                        _remainingInstallmentData(),
                        _installmentTransactions(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        
      )
    );
  }

  Widget _totalPaidData() {
    return Container(
      width: double.infinity, 
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text("Total Bayar", style: TextStyle(fontSize: 16, fontFamily: "mon"),),
          ),
          Container(
            child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalPaid), style: TextStyle(fontFamily: "mon")),            
          ),
          
        ],
      ) 
    );
  }

  Widget _remainingInstallmentData() {
    return Container(
      width: double.infinity, 
      height: 40,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text("Sisa Hutang", style: TextStyle(fontSize: 16, fontFamily: "mon"),),
          ),
          Container(
            child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(remainingInstallment), style: TextStyle(fontFamily: "mon")),
          ),
          
        ],
      ) 
    );
  }

  Widget _installmentTransactions(){
    if(_listInstallmentTransactions != [] ){
      return ListView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _listInstallmentTransactions.length,
        itemBuilder: (BuildContext context, int index){
          return Column(
            children: <Widget>[
              ListTile(
                tileColor: Colors.green[50],
                title: Text(_listInstallmentTransactions[index][1], style: TextStyle(fontFamily: "mon"),),
                subtitle:Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_listInstallmentTransactions[index][2]), style: TextStyle(fontFamily: "mon")),
              ),
              Divider(),
            ],
          );
        },
      );
    };
  }

  

}