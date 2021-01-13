import 'package:flutter/material.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/cashflowModel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CashflowPertahunPage extends StatefulWidget {
  @override
  _CashflowPertahunPageState createState() => _CashflowPertahunPageState();
}

class _CashflowPertahunPageState extends State<CashflowPertahunPage> {
  List<CashflowModel> _cashflowList = [];

  String accessToken, uid, expiry, client, title, cashflowYear; 
  dynamic totalCashIn = 0; 
  dynamic totalCashOut = 0;
  dynamic grandTotal = 0;
  bool isLoading = false;
  
  getPref() async {
    var date = new DateTime.now().toString(); 
    var dateParse = DateTime.parse(date); 
    var year = dateParse.year.toString();

    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
      cashflowYear = year;
    });
    getCashFlows(cashflowYear);
  }

  getCashFlows(year) async {
    _cashflowList.clear();
    
    final response = await http.get(NetworkURL.cashFlow(year), 
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
      final data = responJson["cash_flows"];
      setState(() {
        isLoading = false;
        title = responJson["title"];
        totalCashIn = responJson["total_cash_in"];
        totalCashOut = responJson["total_cash_out"];
        grandTotal = responJson["grand_total"];
        for (Map i in data) {
          _cashflowList.add(CashflowModel.fromJson(i));
        }          
      });
    }else{

    }  
  }

  @override
  void initState() {
    super.initState();
    getPref();    
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(         
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          InkWell(
                          onTap: () {
                            Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
                          },
                          child: Icon(Icons.arrow_back, size: 30,),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "CASHFLOW PERTAHUN",
                            style: TextStyle(
                              fontSize: 20, fontFamily: "mon"
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    backgroundHeader(title), 
                    _dataTableWidget(),   
                    _totalCash(),                
                  ],
                ),
              ),
            ],
          ),
        )
        
      )
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
      if(totalCashIn == 0){
        return Container(      
          height: 100,
          color: Colors.green[50],
          child: Center(
            child: Text("NO DATA", style: TextStyle(fontFamily: "mon"),),
          )
        );  
      }else{
        return Container(      
          height: (MediaQuery.of(context).size.height - 350),
          child: HorizontalDataTable(
            leftHandSideColumnWidth: 100,
            rightHandSideColumnWidth: 450,
            isFixedHeader: true,
            headerWidgets: _getTitleWidget(),
            leftSideItemBuilder: _generateFirstColumnRow,
            rightSideItemBuilder: _generateRightHandSideColumnRow,
            itemCount: _cashflowList.length,
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
      _getTitleItemWidget('Bulan', 100),      
      _getTitleItemWidget('Cash In', 150),
      _getTitleItemWidget('Cash Out', 150),
      _getTitleItemWidget('Total', 150),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "mon")),
      width: width,
      height: 56,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text(_cashflowList[index].month.toString()),
      width: 50,
      height: 52,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[       
        Container(
          child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_cashflowList[index].cashIn)),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_cashflowList[index].cashOut)),
          width: 150,
          height: 52,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: _cashflowList[index].total < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_cashflowList[index].total), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)) : 
            Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(_cashflowList[index].total), style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          width: 150,
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
                  Text("Total Cash in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon")),
                  totalCashIn < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalCashIn), style: TextStyle(color: Colors.red[100], fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")) : 
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalCashIn), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")),
                ],)
              ),
            ),
            Expanded(
              child: Container(
                height: 60,
                color: Colors.green[300],
                child: Column(children: <Widget>[
                  SizedBox(height: 10),
                  Text("Total Cash Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "mon")),
                  totalCashIn < 0 ? Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalCashOut), style: TextStyle(color: Colors.red[100], fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")) : 
                  Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalCashOut), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: "mon")),
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
      height: 120,
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
                    int year = int.parse(cashflowYear) - 1;
                    setState(() {
                      cashflowYear = year.toString();
                      isLoading = true;
                    });                    
                    getCashFlows(year.toString());
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
                    int year = int.parse(cashflowYear) + 1;
                    setState(() {
                      cashflowYear = year.toString();
                      isLoading = true;
                    });                    
                    getCashFlows(year.toString());
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
