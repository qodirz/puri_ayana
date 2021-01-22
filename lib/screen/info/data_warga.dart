import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:puri_ayana_gempol/custom/flushbar_helper.dart';
import 'package:puri_ayana_gempol/menu.dart';
import 'package:puri_ayana_gempol/network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataWargaPage extends StatefulWidget {
  DataWargaPage({ Key key }) : super(key: key);
  @override
  _DataWargaPageState createState() => new _DataWargaPageState();

}

class _DataWargaPageState extends State<DataWargaPage>
{
  Widget appBarTitle = new Text("DATA WARGAx", style: new TextStyle(color: Colors.white),);
  Icon actionIcon = new Icon(Icons.search, color: Colors.white,);
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<Map<String, dynamic>> _list = [] ;

  bool _isSearching;
  String _searchText = "";
  bool isLoading = false;

  String accessToken, uid, expiry, client, tagihan; 
  double contribution;
  getPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
      accessToken = pref.getString("accessToken");      
      uid = pref.getString("uid");
      expiry = pref.getString("expiry");
      client = pref.getString("client");
    });
    getUsers();
  }

  _DataWargaPageState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _isSearching = false;
          _searchText = "";
        });
      }
      else {
        setState(() {
          _isSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  getUsers() async {
    try{
      _list.clear();
      final response = await http.get(NetworkURL.listWarga(), 
      headers: <String, String>{ 
        'Content-Type': 'application/json; charset=UTF-8', 
        'access-token': accessToken,
        'expiry': expiry,
        'uid': uid,
        'client': client,
        'token-type': "Bearer"
      });
      
      final responJson = json.decode(response.body);
      print("getUsers");
      print(responJson);
      if(responJson["success"] == true){
        final data = responJson["users"];
        setState(() {
          isLoading = false;
          for (Map i in data) {
            _list.add( {
              'email': i["email"], 
              'name': i["name"],
              'blok': i["blok_name"] == null ? "-" : i["blok_name"] 
            });
          }          
        });      
      }else{
        setState(() {
          isLoading = false;                   
        });
      }  
    }on SocketException {
      FlushbarHelper.createError(title: 'Error',message: 'No Internet connection!',).show(context);      
    } catch (e) {
      FlushbarHelper.createError(title: 'Error',message: 'Error connection with server!',).show(context);
      print("ERROR.........");
      print(e);      
    }    
  }

  @override
  void initState() {
    super.initState();
    _isSearching = false;
    getPref();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: buildBar(context),
      body: new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: _isSearching ? _buildSearchList() : _buildList(),
      ),
    );
  }

  List<ChildItem> _buildList() {
    return _list.map((contact) => new ChildItem(contact['email'], contact['name'], contact['blok'])).toList();
  }

  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list.map((contact) => new ChildItem(contact['email'], contact['name'], contact['blok']))
          .toList();
    }
    else {
      List<Map<String, dynamic>> _searchList = [];
      for (int i = 0; i < _list.length; i++) {
        String email = _list.elementAt(i)['email'];
        String name = _list.elementAt(i)['name'];
        String blok = _list.elementAt(i)['blok'];
        if (blok.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add({'email': email, 'name': name, 'blok': blok});
        }
      }
      return _searchList.map((contact) => new ChildItem(contact['email'], contact['name'], contact['blok']))
          .toList();
    }
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 26),
        onPressed: () {
          Navigator.push(context,MaterialPageRoute(builder: (context) => Menu(selectIndex: 1)));
        },
      ), 
      backgroundColor: Colors.green,
      centerTitle: true,
      title: appBarTitle,
      actions: <Widget>[
        new IconButton(icon: actionIcon, onPressed: () {
          setState(() {
            if (this.actionIcon.icon == Icons.search) {
              this.actionIcon = new Icon(Icons.close, color: Colors.white,);
              this.appBarTitle = new TextField(
                controller: _searchQuery,
                style: new TextStyle(
                  color: Colors.white,
                ),
                decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search, color: Colors.white),
                  hintText: "Search...",
                  hintStyle: TextStyle(fontFamily: "mon", color: Colors.white),
                ),
              );
              _handleSearchStart();
            }
            else {
              _handleSearchEnd();
            }
          });
        },),
      ]
    );
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(Icons.search, color: Colors.white,);
      this.appBarTitle =
      new Text("DATA WARGAx", style: new TextStyle(color: Colors.white),);
      _isSearching = false;
      _searchQuery.clear();
    });
  }
}

class ChildItem extends StatelessWidget {
  final String email;
  final String name;
  final String blok;
  ChildItem(this.email, this.name, this.blok);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          tileColor: Colors.green[50],
          leading: Text(this.blok.toString(), style: TextStyle(fontFamily: "mon", fontSize: 32),),                                
          title: new Text(this.email.toString()),
          subtitle: new Text(this.name.toString()),
        ),
        Divider(height: 1, color: Colors.green),
      ],
    );
  }

}