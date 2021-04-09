import 'package:flutter/material.dart';
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

  var padding = EdgeInsets.symmetric(horizontal: 10, vertical: 10);

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
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedFontSize: 0,
          type: BottomNavigationBarType.fixed,
          elevation: 20,
          backgroundColor: Colors.lightBlue[700],
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.home_filled,
                color: Colors.white,
                size: 40,
              ),
              icon: Icon(Icons.home_outlined, color: Colors.white60),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.info_rounded,
                color: Colors.white,
                size: 40,
              ),
              icon: Icon(Icons.info_outline, color: Colors.white60),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 40,
              ),
              icon: Icon(Icons.monetization_on_outlined, color: Colors.white60),
              label: 'Transaksi',
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 40,
              ),
              icon: Icon(Icons.account_circle_outlined, color: Colors.white60),
              label: 'Profile',
            ),
          ],
          currentIndex: selectIndex,
          onTap: (indeks) {
            setState(() {
              selectIndex = indeks;
            });
          },
        ),
      ),
    );
  }
}
