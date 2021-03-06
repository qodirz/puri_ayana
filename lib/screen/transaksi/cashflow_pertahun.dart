import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:http/http.dart' as http;
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/model/cashflowModel.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';

class CashflowPertahunPage extends StatefulWidget {
  final String from;
  const CashflowPertahunPage({this.from});

  @override
  _CashflowPertahunPageState createState() => _CashflowPertahunPageState();
}

class _CashflowPertahunPageState extends State<CashflowPertahunPage> {
  final storage = new FlutterSecureStorage();
  List<CashflowModel> _cashflowList = [];

  String accessToken, uid, expiry, client, title, cashflowYear;
  dynamic totalCashIn = 0;
  dynamic totalCashOut = 0;
  dynamic grandTotal = 0;
  bool isLoading = false;

  Future getStorage() async {
    var date = new DateTime.now().toString();
    var dateParse = DateTime.parse(date);
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
      cashflowYear = year;
    });
    getCashFlows(cashflowYear);
  }

  getCashFlows(year) async {
    try {
      _cashflowList.clear();
      final response =
          await http.get(NetworkURL.cashFlow(year), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
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
      } else {}
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      print(e);
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
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
      statusBarColor: baseColor100,
    ));

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: baseColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 26),
            onPressed: () {
              if (widget.from == "home") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Menu(selectIndex: 0)));
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Menu(selectIndex: 2)));
              }
            },
          ),
          title: Text("CASHFLOW PERTAHUN"),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
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
    if (isLoading == true) {
      return Container(
          height: 100,
          color: baseColor50,
          child: Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          )));
    } else {
      if (totalCashIn == 0) {
        return Container(
          height: 100,
          color: baseColor50,
          child: Center(
            child: Text("NO DATA"),
          ),
        );
      } else {
        return Container(
          height: (MediaQuery.of(context).size.height - 300),
          child: HorizontalDataTable(
            leftHandSideColumnWidth: 100,
            rightHandSideColumnWidth: 260,
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
            leftHandSideColBackgroundColor: baseColor50,
            rightHandSideColBackgroundColor: baseColor50,
          ),
        );
      }
    }
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('Bulan', 100),
      _getTitleItemWidget('Cash In', 130),
      _getTitleItemWidget('Cash Out', 130)
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      color: baseColor100,
      child: Text(label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          )),
      width: width,
      height: 48,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      color: baseColor100,
      child: Text(_cashflowList[index].month.toString()),
      width: 20,
      height: 40,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Text(NumberFormat.currency(
                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
              .format(_cashflowList[index].cashIn)),
          width: 130,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: Text(NumberFormat.currency(
                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
              .format(_cashflowList[index].cashOut)),
          width: 130,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
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
                  color: baseColor300,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "Total Cash in",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      totalCashIn < 0
                          ? Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(totalCashIn),
                              style: TextStyle(
                                color: Colors.red[100],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(totalCashIn),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ],
                  )),
            ),
            Expanded(
              child: Container(
                  height: 60,
                  color: baseColor300,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "Total Cash Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      totalCashIn < 0
                          ? Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(totalCashOut),
                              style: TextStyle(
                                color: Colors.red[100],
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                          : Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(totalCashOut),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                    ],
                  )),
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
                    child: Text(
                      "Grand Total:",
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  )),
            ),
            Expanded(
              child: Container(
                height: 60,
                color: Colors.teal[400],
                child: Align(
                  alignment: Alignment.center,
                  child: grandTotal < 0
                      ? Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format(grandTotal),
                          style: TextStyle(
                            color: Colors.red[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                      : Text(
                          NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format(grandTotal),
                          style: TextStyle(
                            color: Colors.yellowAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
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
      color: Colors.lightBlue[600],
      // height: 120,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
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
                  color: baseColor200,
                  splashColor: Colors.orange,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.white,
                  child: Text(
                    'Prev',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Text(
                  title == null ? "" : title,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'bold',
                  ),
                  textAlign: TextAlign.center,
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
                  color: baseColor200,
                  splashColor: Colors.orange,
                  disabledColor: Colors.grey,
                  disabledTextColor: Colors.white,
                  child: Text(
                    'Next',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
