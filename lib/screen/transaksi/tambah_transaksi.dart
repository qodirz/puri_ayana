import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:puri_ayana_gempol/custom/customButton.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'dart:convert';
import 'package:flutter_masked_text/flutter_masked_text.dart';

class TambahTransaksiPage extends StatefulWidget {
  @override
  _TambahTransaksiPageState createState() => _TambahTransaksiPageState();
}

class _TambahTransaksiPageState extends State<TambahTransaksiPage> {
  final storage = new FlutterSecureStorage();
  final totalController = new MoneyMaskedTextController(leftSymbol: "Rp " ,precision: 0);
  TextEditingController descriptionController = TextEditingController();  
  String paymentGroupOption = 'PEMASUKAN LAINNYA';
  String paymentOption = 'Debit';  
  int paymentGroupSelected = 6;
  DateTime _dateTime;
  
  final totalValidator = RequiredValidator(errorText: 'Total harus di isi!');  
  final descriptionValidator = RequiredValidator(errorText: 'Description harus di isi!');  
  
  String accessToken, uid, expiry, client;
  int selectedPayment = 1;
  bool isloading = false, tglError = false;

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
      if(_dateTime == null){
        setState(() {
          tglError = true;      
        });
      }else{
        addTransaction();
        setState(() {
          isloading = true;      
        }); 
      }
    }
  }

  addTransaction() async {
    print("post addTransaction");
    final response = await http.post(NetworkURL.addTransaction(), 
    headers: <String, String>{ 
      'Content-Type': 'application/json; charset=UTF-8', 
      'access-token': accessToken,
      'expiry': expiry,
      'uid': uid,
      'client': client,
      'token-type': "Bearer"
    },body: jsonEncode(<String, dynamic>{   
      "transaction_date": _dateTime.toString(),     
      "transaction_type": paymentOption == "Debit" ? 1 : 2,
      "transaction_group": paymentGroupSelected,
      "total": totalController.numberValue, 
      "description": descriptionController.text.trim(), 
    }));
    
    final responJson = json.decode(response.body);
    if(responJson["success"] == true){   
      FlushbarHelper.createSuccess(title: 'Berhasil',message: responJson["message"],).show(context);                    
      setState(() {
        totalController.text = '';
        descriptionController.text = '';
        isloading = false;  
      });      
    }else{
      FlushbarHelper.createError(title: 'Berhasil',message: responJson["message"],).show(context);                 
      setState(() {
        isloading = false;         
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
          title: Text("TAMBAH TRANSAKSI", style: TextStyle(fontFamily: "mon")),
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
                    Form(
                      key: _key,
                      child: Column(
                        children: [
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
            child: Text("Tanggal", style: TextStyle(fontFamily: "mon"),),
          ),
          Container(
            child: Row(              
              children: <Widget>[  
                tglError == true 
                ? Text("Tanggal harus di isi!", style: TextStyle(fontFamily: "mon", color: Colors.red),
                  ) 
                : Text(_dateTime == null ? "Pilih tanggal" : DateFormat('yyyy-MM-dd').format(_dateTime),
                  style: TextStyle(fontFamily: "mon"),
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
                        tglError = false;
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
    List<String> targetPaymentOptions = ['Debit', 'Credit'];
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
            child: Text("Tipe", style: TextStyle(fontFamily: "mon"),),
          ),
          Container(
            child: DropdownButton<String>(
                value: paymentOption,
                icon: Icon(Icons.arrow_drop_down),
                iconSize: 24,
                elevation: 16,
                style: TextStyle(fontFamily: "mon", color: Colors.black),
                underline: Container(                    
                  color: Colors.white,
                ),
                onChanged: (String newValue) {
                  setState(() {
                    if(newValue == 'Debit'){
                      paymentGroupOption = 'PEMASUKAN LAINNYA';  
                      paymentGroupSelected = 6;                  
                    }else{
                      paymentGroupOption = 'LAIN-LAIN';   
                      paymentGroupSelected = 5;                 
                    }
                    paymentOption = newValue;
                  });
                },
                selectedItemBuilder: (BuildContext context) {
                  return targetPaymentOptions.map<Widget>((String item) {
                    return SizedBox(width: 70, child: Align(alignment: Alignment.centerRight, 
                      child: Text(item,))
                    );
                  }).toList();
                },
                items: targetPaymentOptions.map<DropdownMenuItem<String>>((String value) {
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
      ) 
    );
  }

  Widget _transactionGroupField() {  
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
            child: Text("Grup", style: TextStyle(fontFamily: "mon"),),
          ),
          Container(
            child: Text(paymentGroupOption, style: TextStyle(fontFamily: "mon"),),  
          ),
        ],
      ) 
    );
  }

  Widget _totalField() {
    return Container(
      width: double.infinity, 
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text("Total", style: TextStyle(fontFamily: "mon"),),
          ),
          Container(
            width: 150,
            child: TextFormField( 
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              validator: totalValidator,                      
              controller: totalController,              
              decoration: InputDecoration(
                isDense: true,           
                contentPadding: EdgeInsets.only(top: 15, right: 10),
                filled: true,
                fillColor: Colors.white,
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
            )
          ),
        ],
      ) 
    );
  }

  Widget _descriptionField() {
    return Container(
      width: double.infinity, 
      height: 130,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.green[100], width: 2))            
      ),
      child: TextFormField(  
        keyboardType: TextInputType.multiline,
        maxLines: 5,
        validator: descriptionValidator,
        controller: descriptionController,              
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 20, left: 20),
          filled: true,
          hintText: "Description",
          hintStyle: TextStyle(fontFamily: "mon"),
          fillColor: Colors.white,
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
    );
  }
  
  Widget _btnTambahTransaksi() {
    if(isloading == true){
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
            cek();
          },
          child: CustomButton(
            "SIMPAN",
            color: Colors.green,
          ),
        ),
        
      );
    }    
  }

}
