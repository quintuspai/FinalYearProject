import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connection/main.dart';
import 'package:connection/pages/Settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';

var a = Map();
var now = new DateTime.now();
Map<dynamic, dynamic> docs;
final FirebaseDatabase database = FirebaseDatabase.instance;

class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _AccountPageState();
  }
}

class _AccountPageState extends State<AccountPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _firebaseDb;
  FirebaseUser user;
  bool isSignedIn = false,_isTicketBooked = true;
  String imageUrl;
  String emailId;
  String displayName = '...';
  var uid;
  var ticketCount;

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user == null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyHomePage()));
      }
    });
  }

  getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isSignedIn = true;
      });
      await database
          .reference()
          .child("${user.uid}")
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> list = snapshot.value;
        setState(() {
          this.imageUrl = list['displayPicture'];
          this.displayName = list['Name'];
          this.emailId = list['email'];
          this.ticketCount = list['ticketCounter'];
        });
      });
    }
  }

  _checkTickets() async {
    _firebaseDb = FirebaseDatabase.instance
        .reference()
        .child('${user.uid}/Tickets')
        .orderByChild('index')
        .once().then((DataSnapshot snapshot){
          docs = snapshot.value;
          docs.forEach((i, j) {
            a['${j['index']}'] = j;
          });
      }).catchError((error){
    });
  }

  _signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: <Widget>[
          PopupMenuButton(
              color: Colors.black,
              onSelected: choiceAction,
              itemBuilder: (BuildContext context) {
                return Constants.choices.map((String choice) {
                  return PopupMenuItem<String>(
                    child: Text(choice),
                    value: choice,
                  );
                }).toList();
              })
        ],
        //backgroundColor: Colors.black,
      ),
      body: !isSignedIn // setting isSignedIn to true
          ? Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ),
            )
          : Container(
              child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate([
                    Padding(
                      padding: EdgeInsets.only(top: 40),
                    ),
                    Center(
                      child: Hero(
                          tag: 'displayPicture',
                        child: Container(
                            height: 150,
                            width: 150,
                            decoration: new BoxDecoration(
                              color: Colors.black,
                              image: new DecorationImage(
                                image: imageUrl != null
                                    ? CachedNetworkImageProvider(imageUrl)
                                    : AssetImage('assets/blank_profile.png'),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
                              border: new Border.all(
                                color: Colors.black,
                                width: 5.0,
                              ),
                            ),
                          ),
                      )
                    ),
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(15),
                        child: Text(
                          '${displayName == null ? emailId : displayName}',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left:8.0,right: 8.0),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                  ])),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        (ticketCount != 0) ? FutureBuilder(
                            future: _checkTickets(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.none) {
                                return SnackBar(
                                    content: Text("Check your connection!!!"));
                              }  else if (snapshot.connectionState == ConnectionState.waiting) {
                                return Container(
                                  height: MediaQuery.of(context).size.height,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black,
                                  child: Center(
                                    child: CircularProgressIndicator(backgroundColor: Colors.black,),
                                  ),);
                              }  else {
                                _isTicketBooked = !_isTicketBooked;
                                return TicketUi(
                                  counter: a,
                                );
                              }
                            }
                        ) : NoTicketUi(),
                        Padding(padding: EdgeInsets.all(20))
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.Settings) {
      Navigator.push(
          context, CupertinoPageRoute(builder: (context) => SettingPage(userDpUrl: imageUrl,userEmail: emailId,userName: displayName,)));
      //Navigator.push(context, MaterialPageRoute(builder: (context) => SettingPage()));
    } else if (choice == Constants.SignOut) {
      _signOut();
    }
  }
}

class ScaleRoute extends PageRouteBuilder {
  final Widget page;
  ScaleRoute({this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        ),
  );
}

class Constants {
  static const String Settings = "Settings";
  static const String SignOut = "Sign Out";

  static const List<String> choices = <String>[Settings, SignOut];
}

class CurvePainter extends CustomPainter {
  final date, time, flag;
  CurvePainter(this.date, this.time, this.flag);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Colors.black;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2.0;
    var path = Path();
    path.moveTo(4, 5);
    path.lineTo(4, 120.99);
    path.lineTo(size.width / 3.5, 120.99);
    path.lineTo(size.width / 3.2, 105.0);
    path.lineTo(size.width / 3, 120.99);
    path.lineTo(372.00, size.height);
    path.lineTo(372.00, 5);
    path.lineTo(size.width / 3, 5);
    path.lineTo(size.width / 3.2, 20);
    path.lineTo(size.width / 3.5, 5);
    path.lineTo(4, 5);
    canvas.drawPath(path, paint);
    var path1 = Path();
    var paint1 = Paint();
    paint1.style = PaintingStyle.stroke;
    paint1.strokeWidth = 2.0;
    paint1.color = Colors.grey;
    path1.moveTo(size.width / 3.2, 104.00);
    path1.lineTo(size.width / 3.2, 92);
    path1.moveTo(size.width / 3.2, 20);
    path1.lineTo(size.width / 3.2, 32);
    path1.moveTo(size.width / 3.2, 43);
    path1.lineTo(size.width / 3.2, 55);
    path1.moveTo(size.width / 3.2, 66);
    path1.lineTo(size.width / 3.2, 78);
    canvas.drawPath(path1, paint1);
    Color bandColor;
    var currentTime = new DateFormat('hh:mm:ss').format(now);
    var currentDate = new DateFormat('dd:mm:yyyy').format(now);
    var finalCurrentTime = new DateFormat("hh:mm:ss").parse(currentTime);

    var newTimeObj = new DateFormat("hh:mm:ss").parse(time);
    var finalDateTime = newTimeObj.add(Duration(hours: 1));

    print('${(currentDate.compareTo(date))}');
    if ((currentDate.compareTo(date) == 1) && (finalDateTime.isAfter(finalCurrentTime)) &&(flag == 0)) {
      bandColor = Colors.green;
    } else {
      bandColor = Colors.red;
    }
    var path2 = Path();
    var paint2 = Paint();
    paint2.color = bandColor;
    paint2.style = PaintingStyle.stroke;
    paint2.strokeWidth = 5.0;
    path2.moveTo(345.00, 5);
    path2.lineTo(372.00, size.height/4);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DoPaint extends CustomPainter{
  @override
  void paint(Canvas canvas, Size size) {
    // TODO: implement paint
    var path2 = Path();
    var paint2 = Paint();
    paint2.color = Colors.green;
    paint2.style = PaintingStyle.stroke;
    paint2.strokeWidth = 5.0;
    path2.moveTo(345.00, 5);
    path2.lineTo(372.00, size.height/4);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class TicketUi extends StatelessWidget {
  final Map counter;
  TicketUi({Key key, this.counter}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: ListView.builder(
        reverse: true,
          shrinkWrap: true,
          itemCount: counter.length,
          physics: BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, i) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomPaint(
                    painter: CurvePainter(
                      counter['$i']['date'], counter['$i']['time'],int.parse(counter['$i']['flag'])
                    ),
                    child: Container(
                      color: Colors.transparent,
                      height: 125,
                      child: Card(
                        elevation: 0.0,
                        color: Colors.transparent,
                        child: Container(
                            color: Colors.transparent,
                            height: MediaQuery.of(context).size.height,
                            child: Row(
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10.0,
                                        top: 10.0,
                                        left: 15.0,
                                      ),
                                      child: Container(
                                        height: 95,
                                        width: 80,
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: (){
                                              _displayDialog(context, counter['$i']['qrUrl']);
                                            },
                                            child: Image(
                                              image: CachedNetworkImageProvider(
                                                  counter['$i']['qrUrl']),
                                              alignment: Alignment.center,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 8.0,
                                    left: 28.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text('${counter['$i']['source'][0].toString().toUpperCase()}''${counter['$i']['source'].toString().toLowerCase().substring(1)}',style: TextStyle(color: Colors.white),),
                                      Text('to',style: TextStyle(color: Colors.grey,fontSize: 10),),
                                      //Icon(Icons.directions_bus,color: Colors.grey,size: 15,),
                                      Text(
                                          '${counter['$i']['destination'][0].toString().toUpperCase()}''${counter['$i']['destination'].toString().toLowerCase().substring(1)}',style: TextStyle(color: Colors.white),),
                                      Padding(
                                        padding: const EdgeInsets.only(top:4.0),
                                        child: Row(
                                          children: <Widget>[
                                            RichText(
                                              text: TextSpan(
                                                text: 'BusNo.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: ' ${counter['$i']['bus-No']}',style: TextStyle(color: Colors.white,fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:5.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: 'Adult.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: ' ${counter['$i']['adultCount']}',style: TextStyle(color: Colors.white,fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left:5.0),
                                              child: RichText(
                                                text: TextSpan(
                                                  text: 'Child.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: ' ${counter['$i']['childCounter']}',style: TextStyle(color: Colors.white,fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Booked on.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: ' ${counter['$i']['customDate']}',
                                                style: TextStyle(color: Colors.white,fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Valid Till.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: ' ${_vaildity(counter['$i']['time'],counter['$i']['date'])}',
                                                style: TextStyle(color: Colors.white,fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4.0),
                                        child: RichText(
                                          text: TextSpan(
                                            text: 'Ticket Cost.',style: TextStyle(color: Colors.grey,fontSize: 10),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'Rs. ${counter['$i']['total']}',
                                                style: TextStyle(color: Colors.white,fontSize: 10),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        ),
                      ),
                    )
                )
            );
          }),
    );
  }

  _displayDialog(context, var qr){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            alignment: Alignment.center,
            height: 250,
            width: 250,
            color: Colors.white,
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/6),
            child: Center(
              child: Image(
                image: CachedNetworkImageProvider(
                    qr),
                alignment: Alignment.center,
                fit: BoxFit.fill,
              ),
            )
          );
        });
  }

  _vaildity(var time, var date){
    var compressedDateTime = date + ' ' + time;
    var newDateTimeObj2 = new DateFormat("dd-MM-yyyy HH:mm:ss").parse(compressedDateTime);
    var finalDateTime = newDateTimeObj2.add(Duration(hours: 1));
    var res = '${finalDateTime.hour}:' + "${finalDateTime.minute}:" + "${finalDateTime.second}";
    return res;
  }
}

class NoTicketUi extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.all(60.0),
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.mood_bad,size: 25,color: Colors.grey,),
            Text("No tickets booked",style: TextStyle(fontSize: 25,color: Colors.grey),)
          ],
        ),
      ),
    ) ;
  }
}