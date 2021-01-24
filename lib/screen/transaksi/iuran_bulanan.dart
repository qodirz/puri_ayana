import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
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
  
  String accessToken, uid, expiry, client, blockAddress;
  String message = "";
  bool loading = false;
  bool isPresent = false;
  bool submitted = false;
  int tagihan, addressID;
  double kontribusi = 0;

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
    final response = await http.get(NetworkURL.blockDetail(searchController.text), 
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
      setState(() {
        isPresent = true;
        loading = false;      
        message = "";
        blockAddress = responJson["address"]["block_address"];
        kontribusi = double.parse(responJson["address"]["contribution"]);
        tagihan = responJson["tagihan"];
        addressID = responJson["address"]["id"];
      });      
    }else{
      setState(() {
        isPresent = false;
        loading = false;  
        message = responJson["message"];       
      }); 
    }  
  }

  payContribution() async {
    final response = await http.post(NetworkURL.payContribution(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    },body: jsonEncode(<String, dynamic>{        
      "address_id": addressID,
      "contribution": kontribusi, 
      "total_bayar": int.parse(dropdownValue),
      "pay_at": DateTime.now().toString(),
      "payment_type": paymentOption == "Cash" ? 1 : 2, 
      "blok": blockAddress.replaceAll(RegExp('[0-9]'), '')
    }));
    
    final responJson = json.decode(response.body);
    if(responJson["success"] == true){      
      setState(() {
        isPresent = false;
        submitted = false;
        message = responJson["message"];       
      });      
    }else{
      setState(() {
        isPresent = false;
        submitted = false;
        loading = false;  
        message = responJson["message"];       
      }); 
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
              Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 2)));
            },
          ), 
          title: Text("BAYAR IURAN BULANAN", style: TextStyle(fontFamily: "mon")),
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
                    _formSearchBayarIuran(),
                    SizedBox(height: 30,),
                    showDatasearch(),
                  ],
                ),
              ),
            ],
          ),
        )        
      )
    );
  }

  Widget showDatasearch(){
    if(loading == true){ 
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
    }else{
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
              width: 220,
              child: TextFormField(
                validator: searchValidator,                      
                controller: searchController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 20),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Search blok",
                  hintStyle: TextStyle(fontFamily: "mon"),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(16.0),
                    borderSide:  BorderSide(color: Colors.green[400] ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: Colors.green)
                  ),
                  errorStyle: TextStyle(color: Colors.red),
                ),
              ),
            ),         
            Spacer(),
            InkWell(
              onTap: () {
                cek();
              },
              child: CustomButton(
                "CARI",
                color: Colors.green[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
       
  Widget _dataUser() {            
    return Column(        
      children: <Widget>[
        _blokInfo(),
        _tagihanInfo(),
        _kontribusiInfo(),
        SizedBox(height: 10,),
      ],
    );
  }

  Widget _blokInfo() {
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
            child: Text("Blok", style: TextStyle(fontSize: 16, fontFamily: "mon")),
          ),
          Container(
            child: Text(blockAddress, style: TextStyle(fontSize: 18, fontFamily: "mon"),),
          ),
        ],
      ) 
    );
  }

  Widget _tagihanInfo() {
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
            child: Text("Tagihan", style: TextStyle(fontSize: 16, fontFamily: "mon")),
          ),
          Container(
            child: Text("$tagihan kali", style: TextStyle(fontSize: 18, fontFamily: "mon"),),
          ),
        ],
      ) 
    );
  }

  Widget _kontribusiInfo() {
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
            child: Text("Kontribusi", style: TextStyle(fontSize: 16, fontFamily: "mon")),
          ),
          Container(
            child: Text(NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(kontribusi), style: TextStyle(fontSize: 18, fontFamily: "mon"),),
          ),
        ],
      ) 
    );
  }

  Widget _bayarField() {
    List<String> bayarOptions = ['1', '2', '3', '4', '5'];
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
            child: Text("Bayar", style: TextStyle(fontSize: 16, fontFamily: "mon"),),
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
                    return SizedBox(width: 50, child: Align(alignment: Alignment.centerRight, child: Text(item, style: TextStyle(fontFamily: "mon", fontSize: 18),)));
                  }).toList();
                },
                items: bayarOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(value, style: TextStyle(fontFamily: "mon", fontSize: 18),),
                    ),
                  );
                }).toList(),
              ), 
          ),
        ],
      ) 
    );
  }

  Widget _paymentField() {
    List<String> targetPaymentOptions = ['Cash', 'Transfer'];
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
            child: Text("Payment type", style: TextStyle(fontSize: 16, fontFamily: "mon"),),
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
                    return SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text(item, style: TextStyle(fontFamily: "mon", fontSize: 18),)));
                  }).toList();
                },
                items: targetPaymentOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(value, style: TextStyle(fontFamily: "mon", fontSize: 18),),
                    ),
                  );
                }).toList(),
              ), 
          ),
        ],
      ) 
    );
  }

  Widget _resultContainer() {
    if (isPresent == true){
      return Column(
        children: <Widget>[
          _dataUser(),
          _bayarField(),
          _paymentField(), 
          SizedBox(height: 20,),
          _btnBayar(),
        ],
      );
    }else{
      return Container(
        margin: EdgeInsets.all(20),
        width: double.infinity,
        child: Text(message, style: TextStyle(fontSize: 20, fontFamily: "mon"),),
      );
    }      
  }

  Widget _btnBayar() {
    if(submitted == true){
      return Container(
        width: double.infinity,         
        child: CustomButton(
          "loading...",
          color: Colors.green[400],
        ),
      );
    }else{
      return Container(
        width: double.infinity,  
        child: InkWell(
          onTap: () {
            payContribution();
            setState(() {
              submitted = true;
            });
          },
          child: CustomButton(
            "BAYAR",
            color: Colors.green[400],
          ),
        ),
        
      );
    }    
  }

}
