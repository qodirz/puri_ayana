import 'dart:io';

import 'package:flutter/cupertino.dart';
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
import 'package:puri_ayana_gempol/custom/application_helper.dart';

class TransaksiBulananPage extends StatefulWidget {
  @override
  _TransaksiBulananPageState createState() => _TransaksiBulananPageState();
}

class _TransaksiBulananPageState extends State<TransaksiBulananPage> {
  final storage = new FlutterSecureStorage();
  List<Map<dynamic, dynamic>> _transactionList = [];

  String accessToken,
      uid,
      expiry,
      client,
      title,
      transactionMonth,
      transactionYear;
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
    try {
      _transactionList.clear();
      final response = await http.get(
          NetworkURL.cashTransactions(month.toString(), year.toString()),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'access-token': accessToken,
            'expiry': expiry,
            'uid': uid,
            'client': client,
            'token-type': "Bearer"
          });

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
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
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Menu(selectIndex: 2)));
            },
          ),
          title: Text("TRANSAKSI KAS BULANAN"),
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
      if (grandTotal == null) {
        return Container(
            height: 100,
            color: baseColor50,
            child: Center(
              child: Text("NO DATA"),
            ));
      } else {
        return Container(
          height: (MediaQuery.of(context).size.height - 300),
          child: HorizontalDataTable(
            leftHandSideColumnWidth: 0,
            rightHandSideColumnWidth: 355,
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
            leftHandSideColBackgroundColor: baseColor50,
            rightHandSideColBackgroundColor: baseColor50,
          ),
        );
      }
    }
  }

  List<Widget> _getTitleWidget() {
    return [
      _getTitleItemWidget('', 0),
      _getTitleItemWidget('Tanggal', 80),
      _getTitleItemWidget('Deskripsi', 160),
      _getTitleItemWidget('Total', 115),
    ];
  }

  Widget _getTitleItemWidget(String label, double width) {
    return Container(
      color: baseColor100,
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
      width: width,
      height: 48,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    return Container(
      child: Text("", style: TextStyle(fontWeight: FontWeight.bold)),
      width: 0,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: <Widget>[
        Container(
          child: Container(
            height: 30,
            width: 50,
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              color: baseColor700,
              borderRadius: new BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              _transactionList[index]["transaction_date"],
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
          width: 80,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.center,
        ),
        Container(
          child: Text(
            _transactionList[index]["description"],
            style: TextStyle(fontSize: 12),
          ),
          width: 160,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerLeft,
        ),
        Container(
          child: _transactionList[index]["type"] == "cash_in"
              ? Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(_transactionList[index]["total"]),
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12))
              : Text(
                  NumberFormat.currency(
                          locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                      .format(_transactionList[index]["total"]),
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
          width: 105,
          height: 40,
          padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
          alignment: Alignment.centerRight,
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
                  color: baseColor300,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        "Debit Total",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      debitTotal < 0
                          ? Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(debitTotal),
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
                                  .format(debitTotal),
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
                        "Credit Total",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      creditTotal < 0
                          ? Text(
                              NumberFormat.currency(
                                      locale: 'id',
                                      symbol: 'Rp ',
                                      decimalDigits: 0)
                                  .format(creditTotal),
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
                                  .format(creditTotal),
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
                    setState(() {
                      int month = int.parse(transactionMonth) - 1;
                      if (month == 0) {
                        transactionMonth = "12";
                        int year = int.parse(transactionYear) - 1;
                        transactionYear = year.toString();
                      } else {
                        transactionMonth = month.toString();
                      }
                      isLoading = true;
                    });
                    getTransactionPerMonth(transactionMonth, transactionYear);
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
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                MaterialButton(
                  onPressed: () {
                    setState(() {
                      int month = int.parse(transactionMonth) + 1;
                      if (month == 13) {
                        transactionMonth = "1";
                        int year = int.parse(transactionYear) + 1;
                        transactionYear = year.toString();
                      } else {
                        transactionMonth = month.toString();
                      }
                      isLoading = true;
                    });
                    getTransactionPerMonth(transactionMonth.toString(),
                        transactionYear.toString());
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
