import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/application_helper.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';

class IuranBulananPage extends StatefulWidget {
  @override
  _IuranBulananPageState createState() => _IuranBulananPageState();
}

class _IuranBulananPageState extends State<IuranBulananPage> {
  final storage = new FlutterSecureStorage();
  String dropdownValue = '1';
  String paymentOption = 'Cash';
  final searchValidator = RequiredValidator(errorText: 'blok is required');

  TextEditingController searchController = TextEditingController();

  String accessToken, uid, expiry, client, blockAddress, lastPayDate;
  String message = "";
  bool loading = false;
  bool isPresent = false;
  bool submitted = false;
  int tagihan, addressID;
  double kontribusi = 0;
  dynamic lastPayAmount = 0;

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
  }

  final _key = GlobalKey<FormState>();

  cek() {
    if (_key.currentState.validate()) {
      getBlokInfo();
      setState(() {
        loading = true;
      });
    }
  }

  getBlokInfo() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      final response = await http.get(
          NetworkURL.blockDetail(searchController.text),
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
        setState(() {
          isPresent = true;
          loading = false;
          message = "";
          blockAddress = responJson["address"]["block_address"];
          kontribusi = double.parse(responJson["address"]["contribution"]);
          tagihan = responJson["tagihan"];
          addressID = responJson["address"]["id"];
          if (responJson["last_contribution"] != null) {
            lastPayDate = responJson["last_contribution"]["pay_at"];
            lastPayAmount = responJson["last_contribution"]["contribution"];
          }
        });
      } else {
        setState(() {
          isPresent = false;
          loading = false;
          message = responJson["message"];
        });
      }
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'Error connection with server!',
      ).show(context);
    }
  }

  _confirmDialog() {
    Widget yesButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.cyan,
        backgroundColor: Colors.cyan[100],
        side: BorderSide(color: Colors.cyan),
      ),
      onPressed: () {
        payContribution();
        setState(() {
          submitted = true;
        });
      },
      child: Text('yes'),
    );

    Widget noButton = OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.orange,
        backgroundColor: Colors.orange[50],
        side: BorderSide(color: Colors.orange),
      ),
      onPressed: () => Navigator.pop(context),
      child: Text('no'),
    );

    confirmDialogWithActions(
        "Warning",
        "Apakah Anda Yakin Akan Membayar IURAN?",
        [noButton, yesButton],
        context);
  }

  payContribution() async {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
      final response = await http.post(NetworkURL.payContribution(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'access-token': accessToken,
            'expiry': expiry,
            'uid': uid,
            'client': client,
            'token-type': "Bearer"
          },
          body: jsonEncode(<String, dynamic>{
            "address_id": addressID,
            "contribution": kontribusi,
            "total_bayar": int.parse(dropdownValue),
            "pay_at": DateTime.now().toString(),
            "payment_type": paymentOption == "Cash" ? 1 : 2,
            "blok": blockAddress.replaceAll(RegExp('[0-9]'), '')
          }));

      final responJson = json.decode(response.body);
      if (responJson["success"] == true) {
        setState(() {
          isPresent = false;
          submitted = false;
          message = responJson["message"];
        });
      } else {
        setState(() {
          isPresent = false;
          submitted = false;
          loading = false;
          message = responJson["message"];
        });
      }
    } on SocketException {
      FlushbarHelper.createError(
        title: 'Error',
        message: 'No Internet connection!',
      ).show(context);
    } catch (e) {
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
                  builder: (context) => Menu(selectIndex: 2),
                ),
              );
            },
          ),
          title: Text("BAYAR IURAN BULANAN"),
          centerTitle: true,
        ),
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 40),
                  children: <Widget>[
                    _formSearchBayarIuran(),
                    SizedBox(
                      height: 30,
                    ),
                    showDatasearch(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showDatasearch() {
    if (loading == true) {
      return Center(
        heightFactor: 1,
        widthFactor: 1,
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
          ),
        ),
      );
    } else {
      return _resultContainer();
    }
  }

  Widget _formSearchBayarIuran() {
    return Form(
      key: _key,
      child: Container(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 180,
              child: TextFormField(
                validator: searchValidator,
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Cari blok",
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: baseColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: baseColor400),
                  ),
                  errorBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: baseColor)),
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),
            Spacer(),
            InkWell(
              onTap: () {
                cek();
              },
              child: customButton("CARI"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataUser() {
    return Column(
      children: <Widget>[
        if (lastPayDate != null) iuranTitle("Pembayaran Terakhir"),
        if (lastPayDate != null) iuranInfo("Tanggal", lastPayDate),
        if (lastPayDate != null)
          iuranInfo(
              "Jumlah",
              NumberFormat.currency(
                      locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                  .format(lastPayAmount)),
        SizedBox(
          height: 20,
        ),
        iuranTitle("Iuran Info"),
        iuranInfo("Blok", blockAddress),
        iuranInfo("Tagihan", "$tagihan kali"),
        iuranInfo(
            "Kontribusi",
            NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                .format(kontribusi)),
      ],
    );
  }

  Widget iuranTitle(title) {
    return Center(
      child: Text(title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget iuranInfo(title, value) {
    return Container(
        padding: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: baseColor100, width: 2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(title, style: TextStyle(fontFamily: 'bold')),
            ),
            Container(
              child: Text(value),
            ),
          ],
        ));
  }

  Widget _bayarField() {
    List<String> bayarOptions = ['1', '2', '3', '4', '5'];
    return Container(
        padding: EdgeInsets.only(left: 8),
        height: 40,
        width: double.infinity,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: baseColor100, width: 2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                "Bayar",
                style: TextStyle(fontFamily: 'bold'),
              ),
            ),
            Container(
              child: DropdownButton<String>(
                value: dropdownValue,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                underline: Container(
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    dropdownValue = newValue;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return bayarOptions.map<Widget>((String item) {
                    return SizedBox(
                      width: 50,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(item),
                      ),
                    );
                  }).toList();
                },
                items:
                    bayarOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        value,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ));
  }

  Widget _paymentField() {
    List<String> targetPaymentOptions = ['Cash', 'Transfer'];
    return Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: 8),
        height: 40,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: baseColor100, width: 2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                "Payment type",
                style: TextStyle(fontFamily: 'bold'),
              ),
            ),
            Container(
              child: DropdownButton<String>(
                value: paymentOption,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                underline: Container(
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    paymentOption = newValue;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return targetPaymentOptions.map<Widget>((String item) {
                    return SizedBox(
                        width: 100,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(item)));
                  }).toList();
                },
                items: targetPaymentOptions
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ));
  }

  Widget _resultContainer() {
    if (isPresent == true) {
      return Column(
        children: <Widget>[
          _dataUser(),
          _bayarField(),
          _paymentField(),
          SizedBox(
            height: 20,
          ),
          _btnBayar(),
        ],
      );
    } else {
      return Container(
        margin: EdgeInsets.all(20),
        width: double.infinity,
        child: Text(
          message,
          style: TextStyle(fontSize: 20),
        ),
      );
    }
  }

  Widget _btnBayar() {
    if (submitted == true) {
      return Container(
        width: double.infinity,
        child: customButton("loading..."),
      );
    } else {
      return Container(
        width: double.infinity,
        child: InkWell(
          onTap: () {
            _confirmDialog();
          },
          child: customButton("BAYAR"),
        ),
      );
    }
  }
}
