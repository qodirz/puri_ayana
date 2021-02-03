import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:puri_ayana_gempol/screen/home/home.dart';
import 'package:puri_ayana_gempol/screen/info/info.dart';
import 'package:puri_ayana_gempol/screen/transaksi/transaksi.dart';
import 'package:puri_ayana_gempol/screen/akun/akun.dart';

class Menu extends StatefulWidget {
  final int selectIndex;
  const Menu({this.selectIndex});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int selectIndex = 0;
  
  @override
  void initState() {
    super.initState(); 
    setState(() {
      selectIndex = widget.selectIndex == null ? 0 : widget.selectIndex;
    });    
  }

  var padding = EdgeInsets.symmetric(horizontal: 18, vertical: 5);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Offstage(
              offstage: selectIndex != 0,
              child: Home(),
            ),
            Offstage(
              offstage: selectIndex != 1,
              child: InfoPage(),
            ),
            Offstage(
              offstage: selectIndex != 2,
              child: TransaksiPage(),
            ),
            Offstage(
              offstage: selectIndex != 3,
              child: AkunPage(),
            ),
          ],
        ),
        bottomNavigationBar:SafeArea(            
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
              child: GNav(
                  curve: Curves.easeOutExpo,
                  duration: Duration(milliseconds: 900),
                  tabs: [
                    GButton(                      
                      gap: 2,
                      iconActiveColor: Colors.black,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      backgroundColor: Colors.green[200],
                      iconSize: 24,
                      padding: padding,
                      icon: LineIcons.home,
                      text: 'Home',
                      textStyle: TextStyle(fontFamily: "mon"),
                    ),
                    GButton(
                      gap: 2,
                      iconActiveColor: Colors.black,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      backgroundColor: Colors.green[200],
                      iconSize: 24,
                      padding: padding,
                      icon: LineIcons.info_circle,
                      text: 'Info',
                      textStyle: TextStyle(fontFamily: "mon"),
                    ),
                    GButton(
                      gap: 2,
                      iconActiveColor: Colors.black,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      backgroundColor: Colors.green[200],
                      iconSize: 24,
                      padding: padding,
                      icon: LineIcons.money,                      
                      text: 'Transaksi',
                      textStyle: TextStyle(fontFamily: "mon"),
                    ),
                    GButton(
                      gap: 2,
                      iconActiveColor: Colors.black,
                      iconColor: Colors.black,
                      textColor: Colors.black,
                      backgroundColor: Colors.green[200],
                      iconSize: 24,
                      padding: padding,
                      icon: LineIcons.user,                      
                      text: 'Akun',
                      textStyle: TextStyle(fontFamily: "mon"),
                    )
                  ],
                  selectedIndex: selectIndex,
                  onTabChange: (index) {                                 
                    setState(() {
                      selectIndex = index;
                    });                     
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
