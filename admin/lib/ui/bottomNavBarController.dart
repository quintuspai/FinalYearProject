import 'package:admin/pages/booking_page.dart';
import 'package:admin/pages/qr_scanner.dart';
import 'package:flutter/material.dart';
String _adminKey,_busNo;
class BottomNavigationBarController extends StatefulWidget{
  String adminKey, busNo;
  BottomNavigationBarController({Key key, @required this.adminKey, @required this.busNo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    _adminKey = this.adminKey;
    _busNo = this.busNo;
    // TODO: implement createState
    return _BottomNavigationBarControllerState();
  }
}

class _BottomNavigationBarControllerState extends State<BottomNavigationBarController>{
  final List<Widget> pages = [
    BookingPage(
        key: PageStorageKey('Page1'),
        adminKey: _adminKey,
      busNo: _busNo,
    ),
    QrScanner(
      key: PageStorageKey('Page2'),
    ),
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex){
    return BottomNavigationBar(
        backgroundColor: Colors.black,
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.purpleAccent,
        items: const <BottomNavigationBarItem> [
          BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Book')),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), title: Text('Scan')),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PageStorage(bucket: bucket, child: pages[_selectedIndex]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child:  _bottomNavigationBar(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
