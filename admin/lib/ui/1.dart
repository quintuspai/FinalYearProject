import 'package:admin/pages/qr_scanner.dart';
import 'package:admin/ui/bottomNavBarController.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget{
  String adminKey, busNo;
  Home({Key key, @required this.adminKey, @required this.busNo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeState();
  }
}

class _HomeState extends State<Home>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
            debugShowCheckedModeBanner: false,
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: BottomNavigationBarController(
              adminKey: widget.adminKey,
              busNo: widget.busNo,
            ),
          );
  }
}
