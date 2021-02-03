import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';

class TransaksiBulananPage extends StatefulWidget {
  @override
  _TransaksiBulananPageState createState() => _TransaksiBulananPageState();
}

class _TransaksiBulananPageState extends State<TransaksiBulananPage> {
  final storage = new FlutterSecureStorage();
  List<Map<dynamic, dynamic>> _transactionList = [] ;

  String accessToken, uid, expiry, client, title, transactionMonth, transactionYear; 
  dynamic debitTotal = 0; 
  dynamic creditTotal = 0;
  dynamic grandTotal = 0;
  bool isLoading = false;
  
  Future getStorage() async {
    var date = new DateTime.now().toString(); 
    var dateParse = DateTime.parse(date); 
    var month = dateParse.month.toString(); 
    var year = dateParse.year.toString();

    String tokenStorage = await storage.read(key: "accessToken");     
    String uidStorage = await storage.read(key: "uid");
    String expiryStorage = await storage.read(key: "expiry");
    String clientStorage = await storage.read(key: "client");
    setState(() {
      accessToken = tokenStorage;
      uid = uidStorage;
      expiry = expiryStorage;
      client = clientStorage;
      transactionMonth = month;
      transactionYear = year;
    });       
    getTransactionPerMonth(month, year);
  }

  getTransactionPerMonth(month, year) async {
    try{
      _transactionList.clear();
      final response = await http.get(NetworkURL.cashTransactions(month.toString(), year.toString()), 
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
        final data = responJson["transactions"];
        setState(() {
          isLoading = false;
          title = responJson["title"];
          debitTotal = responJson["debit_total"];
          creditTotal = responJson["credit_total"];
          grandTotal = responJson["grand_total"];
          for (Map i in data) {
            _transactionList.add({
              'type': i["type"], 
              'transaction_date': i["transaction_date"], 
              'description': i["description"],
              'total': i["total"]
            });
          }          
        });
      }else{

      }
    } on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      print(e);
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);
    }
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
              Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
            },
          ), 
          title: Text("TRANSAKSI BULANAN", style: TextStyle(fontFamily: "mon")),
          centerTitle: true,
        ),
        body: Container(         
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10),
                  children: <Widget>[
                    backgroundHeader(title), 
                    _dataTableWidget(),   
                    _totalCash(),                
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataTableWidget() {
    if(isLoading == true){
      return Container(      
        height: 100,
        color: Colors.green[50],
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          )
        )
      );
    }else{
      if(grandTotal == null){
        return Container(      
          height: 100,
          color: Colors.green[50],
          child: Center(
            child: Text("NO DATA", style: TextStyle(fontFamily: "mon"),),
          )
        );  
      }else{
        return Container(      
          height: (MediaQuery.of(context).size.height - 370),
          child: HorizontalDataTable(
            leftHandSideColumnWidth: 0,
            rightHandSideColumnWidth: 340,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: _transactionList.length,
            rowSeparatorWidget: const Divider(
              color: Colors.cyan,
              height: 1.0,
              thickness: 1.0,
            ),
            leftHandSideColBackgroundColor: Colors.green[50],
            rightHandSideColBackgroundColor: Colors.green[50],
          ),      
        );
      }
    }
    
  }

  List<Widget> _getTitleWidget() {
    return [      
      _getTitleItemWidget('', 0),
      _getTitleItemWidget('Date', 80),
      _getTitleItemWidget('Description', 150),
      _getTitleItemWidget('Total', 110),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      color: Colors.green[100],
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon")),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon")),
      width: 0,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[       
        Container(
          child: Text(_transactionList[index]["transaction_date"]),
          width: 80,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(_transactionList[index]["description"]),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: _transactionList[index]["type"] == "cash_in" ? 
            Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_transactionList[index]["total"]), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)) : 
            Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_transactionList[index]["total"]), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          width: 110,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        )
      ],
    );
  }

  Widget _totalCash() {
    return Column(
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[  
            Expanded(
              child: Container(
                height: 60,
                color: Colors.green[300],
                child: Column(children: <Widget>[
                  SizedBox(height: 10),
                  Text("Debit Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon")),
                  debitTotal < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(debitTotal), style: TextStyle(color: Colors.red[100], fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")) : 
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(debitTotal), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")),
                ],)
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                color: Colors.green[300],
                child: Column(children: <Widget>[
                  SizedBox(height: 10),
                  Text("Credit Total", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon")),
                  creditTotal < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(creditTotal), style: TextStyle(color: Colors.red[100], fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")) : 
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(creditTotal), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")),
                ],)
              ),
            )
          ],
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 60,
                width: 140,
                color: Colors.teal[400],
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text("Grand Total:", style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon"), textAlign: TextAlign.right,),
                )
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                color: Colors.teal[400],
                child: Align(
                  alignment: Alignment.center,
                  child: grandTotal < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(grandTotal), style: TextStyle(color: Colors.red[200], fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "mon")) : 
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(grandTotal), style: TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: "mon")), 
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget backgroundHeader(title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft:Radius.circular(30), topRight: Radius.circular(30)
        ),
        color: Colors.green
      ),
      height: 140,
      width: double.infinity,  
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[          
            Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: title == null ? Container( margin: EdgeInsets.only(top: 10), width: 20, height: 20, child: CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )) : 
                Text("$title", 
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon"),
                textAlign: TextAlign.center,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      int month = int.parse(transactionMonth) - 1;
                      if(month == 0){                        
                        transactionMonth = "12";                      
                        int year = int.parse(transactionYear) - 1;
                        transactionYear = year.toString();
                      }else{
                        transactionMonth = month.toString();
                      }
                      isLoading = true;
                    });                    
                    getTransactionPerMonth(transactionMonth, transactionYear);
                  },
                  shape: const StadiumBorder(),
                  color: Colors.green[200],
                  splashColor: Colors.orange,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.white,
                  child: Text('Prev', style: TextStyle(fontFamily: "mon", color: Colors.white),),
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      int month = int.parse(transactionMonth) + 1; 
                      if(month == 13){
                        transactionMonth = "1";
                        int year = int.parse(transactionYear) + 1;
                        transactionYear = year.toString();
                      }else{
                        transactionMonth = month.toString();
                      }
                      isLoading = true;
                    });                    
                    getTransactionPerMonth(transactionMonth.toString(), transactionYear.toString());
                  },
                  shape: const StadiumBorder(),
                  color: Colors.green[200],
                  splashColor: Colors.orange,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.white,
                  child: Text('Next', style: TextStyle(fontFamily: "mon", color: Colors.white),),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
