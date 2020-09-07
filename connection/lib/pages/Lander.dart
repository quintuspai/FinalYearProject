import 'package:cached_network_image/cached_network_image.dart';
import 'package:connection/pages/Map_page.dart';
import 'package:connection/pages/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import './SearchBus.dart';
import './Booking.dart';
import './Account.dart';

class BottomNavigationBarController extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BottomNavigationBarControllerState();
  }
}

class _BottomNavigationBarControllerState
    extends State<BottomNavigationBarController> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;
  String imageUrl;

  final List<Widget> pages = [
    SearchBusPage(key: PageStorageKey('Page1')),
    BookingPage(key: PageStorageKey('Page2')),
    Chat(key: PageStorageKey('Page3'),),
    AccountPage(key: PageStorageKey('Page4'))
  ];

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
      });
      await database
          .reference()
          .child("${user.uid}")
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> list = snapshot.value;
        setState(() {
          this.imageUrl = list['displayPicture'];
        });
      });
    }
  }

  final PageStorageBucket bucket = PageStorageBucket();
  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex) {
    return BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: selectedIndex,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.purpleAccent,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Image(
                image: AssetImage("assets/circle_bus.png"),
                height: 30,
                width: 30,
              ),
              title: Text('Search')),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            title: Text('Book'),
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text('Chat')),
          BottomNavigationBarItem(
              icon: Container(
                height: 30,
                width: 30,
                decoration: new BoxDecoration(
                  color: Colors.black,
                  image: new DecorationImage(
                    image: imageUrl != null
                        ? CachedNetworkImageProvider(imageUrl)
                        : AssetImage('assets/blank_profile.png'),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(30.0)),
                  border: new Border.all(
                    color: Colors.black,
                    width: 3.0,
                  ),
                ),
              ),
              title: Text('Account')),
        ]);
  }

  @override
  void initState() {
    this.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      //bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
      body: Stack(
        children: <Widget>[
          PageStorage(bucket: bucket, child: pages[_selectedIndex]),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _bottomNavigationBar(_selectedIndex),
          ),
        ],
      ),
    );
  }
}
