import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TambahTransaksiPage extends StatefulWidget {
  @override
  _TambahTransaksiPageState createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  String paymentGroupOption = 'IURAN WARGA';
  String paymentOption = 'Cash';  
  DateTime _dateTime;
  
  String accessToken, uid, expiry, client, blockAddress;
  String message = "";
  int selectedPayment = 1;
  bool loading = false;
  bool submitted = false;

  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
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

    print("masuk search getBlokInfo");
    final response = await http.get(NetworkURL.getProfile(), 
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
        loading = false;      
        message = "";
      });      
    }else{
      setState(() {
        loading = false;  
        message = responJson["message"];       
      }); 
    }  
  }
 
  @override
  void initState() {
    getPref();
    super.initState();
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
                          child: Icon(Icons.arrow_back),
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Text(
                            "Tambah Transaksi",                              
                            style: TextStyle(
                              fontSize: 16
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    _transactionDateField(),
                    SizedBox(height: 10,),
                    _transactionTypeField(),
                    SizedBox(height: 10,),
                    _transactionGroupField(),
                    SizedBox(height: 10,),
                    _totalField(),
                    SizedBox(height: 10,),
                    _descriptionField(),
                    SizedBox(height: 10,),
                    _btnTambahTransaksi(),
                  ],
                ),
              ),
            ],
          ),
        )        
      )
    );
  }

  Widget _transactionDateField() {
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
            child: Text("Tanggal", style: TextStyle(fontSize: 16),),
          ),
          Container(
            child: Row(              
              children: <Widget>[              
              Text(_dateTime == null ? "" : DateFormat('yyyy-MM-dd').format(_dateTime),
                style: TextStyle(fontSize: 18),
              ),
              InkWell(
                onTap: () {
                  showDatePicker(
                    context: context,                 
                    initialDate: _dateTime == null ? DateTime.now() : _dateTime, 
                    firstDate: DateTime(2001), 
                    lastDate: DateTime.now()
                  ).then((date) {
                    setState(() {
                      _dateTime = date;
                    });
                    
                  });
                },
                child: Icon(Icons.date_range, color: Colors.green,),
              ),
            ],)
          ),
        ],
      ) 
    );
  }

  Widget _transactionTypeField() {
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
            child: Text("Payment type", style: TextStyle(fontSize: 16),),
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
                    return SizedBox(width: 70, child: Align(alignment: Alignment.centerRight, child: Text(item)));
                  }).toList();
                },
                items: targetPaymentOptions.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(value),
                    ),
                  );
                }).toList(),
              ), 
          ),
        ],
      ) 
    );
  }

  Widget _transactionGroupField() {
    List<String> targetOptions = ['IURAN WARGA', 'GAJI DAN UPAH', 'KASBON', 'BAYAR KASBON', 'LAIN-LAIN', 'PEMASUKAN LAINNYA'];
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
            child: Text("Payment Group", style: TextStyle(fontSize: 16),),
          ),
          Container(
            child: DropdownButton<String>(              
                value: paymentGroupOption,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(color: Colors.black),
                underline: Container(                    
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    paymentGroupOption = newValue;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return targetOptions.map<Widget>((String item) {
                    return SizedBox(width: 150, child: Align(alignment: Alignment.centerRight, child: Text(item)));
                  }).toList();
                },                
                items: targetOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(value),
                  ),
                );
                }).toList(),
              ), 
          ),
        ],
      ) 
    );
  }

  Widget _totalField() {
    return Container(
      width: double.infinity, 
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text("Total", style: TextStyle(fontSize: 16),),
          ),
          Container(
            width: 150,
            child: TextFormField(  
              keyboardType: TextInputType.number,
              //validator: emailValidator,                      
              //controller: usernameController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 20, left: 20),
                filled: true,
                fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  errorStyle: TextStyle(color: Colors.red[100]),
                ),
            )
          ),
        ],
      ) 
    );
  }

  Widget _descriptionField() {
    return Container(
      width: double.infinity, 
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: TextFormField(  
        keyboardType: TextInputType.multiline,
        maxLines: 3,
        //validator: emailValidator,                      
        //controller: usernameController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, left: 20),
          filled: true,
          hintText: "Description",
          fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(16),
            ),
            errorStyle: TextStyle(color: Colors.red[100]),
          ),
      ),
    );
  }

  
  Widget _btnTambahTransaksi() {
    if(submitted == true){
      return Container(
        width: double.infinity,         
        child: CustomButton(
          "loading...",
          color: Colors.green,
        ),
      );
    }else{
      return Container(
        width: double.infinity,  
        child: InkWell(
          onTap: () {
            setState(() {
              submitted = true;
            });
          },
          child: CustomButton(
            "simpan",
            color: Colors.green,
          ),
        ),
        
      );
    }    
  }

}
