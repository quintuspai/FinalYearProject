import 'dart:io';
import 'dart:typed_data';
import 'package:connection/SearchBusPages/Search_bus.dart';
import 'package:connection/SearchBusPages/booking_page_helper.dart';
import 'package:connection/pages/payment_worker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui';

class BookingPage extends StatefulWidget {
  BookingPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BookingPageState();
  }
}

class _BookingPageState extends State<BookingPage> {
  GlobalKey globalKey = new GlobalKey();
  FirebaseDatabase _firebaseDb = new FirebaseDatabase();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> map;
  var stationListName = [];
  var stationIdList = [];
  FirebaseUser user;
  bool isSignedIn = false;
  var _halfTicket = 1, _fullTicket = 2;
  var _total = 0;
  bool flag = true,statusFlag= false;
  String _source = "Source",
      _destination = "Destination",
      _busNo = "Tap to select a bus";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _sourceTextFieldController = TextEditingController();
  TextEditingController _destinationTextFieldController =
      TextEditingController();
  var now = new DateTime.now();
  int _sourceId, _destinationId;
  int _adultCounter = 0, _childCounter = 0;
  int _ticketCounter;
  var dayIndexes = {
    '1': "Mon",
    '2': "Tue",
    '3': "Wed",
    '4': "Thur",
    '5': "Fri",
    '6': "Sat",
    '7': "Sun"
  };
  var monthIndexes = {
    "1": "Jan",
    "2": "Feb",
    "3": "Mar",
    "4": "Apr",
    "5": "May",
    "6": "Jun",
    "7": "Jul",
    "8": "Aug",
    "9": "Sep",
    "10": "Oct",
    "11": "Nov",
    "12": "Dec"
  };


  _getUser() async {
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isSignedIn = true;
      });
      await _firebaseDb
          .reference()
          .child('${user.uid}')
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> list = snapshot.value;
        setState(() {
          _ticketCounter = int.parse(list['ticketCounter']);
        });
      });
    }
  }

  _calculateTicketCost() {
    setState(() {
      _total = ((_halfTicket * _childCounter).toInt() +
              (_fullTicket * _adultCounter))
          .toInt();
    });
  }

  _incrementAdultCounter() {
    setState(() {
      _adultCounter++;
    });
    _calculateTicketCost();
  }

  _decrementAdultCounter() {
    if (_adultCounter != 0) {
      setState(() {
        _adultCounter--;
        _calculateTicketCost();
      });
    }
  }

  _incrementChildCounter() {
    setState(() {
      _childCounter++;
    });
    _calculateTicketCost();
  }

  _decrementChildCounter() {
    if (_childCounter != 0) {
      setState(() {
        _childCounter--;
        _calculateTicketCost();
      });
    }
  }

  @override
  void initState() {
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: globalKey,
      body: !isSignedIn
          ? Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.black,
                ),
              ),
            )
          : Container(
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  color: Colors.black12,
                  child: Container(
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).viewInsets.bottom,
                    //height: MediaQuery.of(context).size.height/1.111,
                    color: Colors.black12,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          Card(
                            color: Colors.transparent,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(2),
                                  child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          GestureDetector(
                                              onTap: () {
                                                _awaitReturnValueFromSecondScreen(
                                                    context, 0);
                                              },
                                              child: AbsorbPointer(
                                                child: TextFormField(
                                                  controller:
                                                      _sourceTextFieldController,
                                                  enableInteractiveSelection:
                                                      false,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode:
                                                      AlwaysDisabledFocusNode(),
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .orangeAccent,
                                                          width: 5.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .orangeAccent,
                                                          width: 5.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black12,
                                                    focusColor: Colors.black12,
                                                    hintText: _source,
                                                  ),
                                                ),
                                              )),
                                          Padding(padding: EdgeInsets.all(10)),
                                          Container(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10.0),
                                              child: Text(
                                                "to",
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(10),
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                _awaitReturnValueFromSecondScreen(
                                                    context, 1);
                                              },
                                              child: AbsorbPointer(
                                                child: TextFormField(
                                                  controller:
                                                      _destinationTextFieldController,
                                                  enableInteractiveSelection:
                                                      false,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                  focusNode:
                                                      AlwaysDisabledFocusNode(),
                                                  decoration: InputDecoration(
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .orangeAccent,
                                                          width: 5.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors
                                                              .orangeAccent,
                                                          width: 5.0),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30),
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black12,
                                                    focusColor: Colors.black12,
                                                    hintText: _destination,
                                                  ),
                                                ),
                                              )),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              _awaitReturnValueFromBookingPageHelper(
                                                  context);
                                            },
                                            child: Card(
                                              color: Colors.black12,
                                              child: Container(
                                                alignment: Alignment.topLeft,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Text(
                                                      "Bus No. : ",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors.white),
                                                    ),
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "$_busNo",
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          Card(
                                            color: Colors.black12,
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                    "Travel date : ",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        "${dayIndexes[now.weekday.toString()]} ${now.day} ${monthIndexes[now.month.toString()]} ${now.year}",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                      ),
                                                      focusColor: Colors.purple,
                                                      hoverColor: Colors.purple,
                                                      onPressed:
                                                          _decrementAdultCounter,
                                                      tooltip:
                                                          "Remove a passenger",
                                                    ),
                                                    Container(
                                                      child: Text(
                                                          "Adult : $_adultCounter",
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    IconButton(
                                                      focusColor: Colors.purple,
                                                      hoverColor: Colors.purple,
                                                      icon: Icon(Icons.add,
                                                          color: Colors.white),
                                                      onPressed:
                                                          _incrementAdultCounter,
                                                      tooltip:
                                                          "Add a passenger",
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 10.0)),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    IconButton(
                                                      hoverColor: Colors.purple,
                                                      splashColor:
                                                          Colors.purple,
                                                      color: Colors.purple,
                                                      //highlightColor: Colors.purple,
                                                      icon: Icon(
                                                        Icons.remove,
                                                        color: Colors.white,
                                                      ),
                                                      onPressed:
                                                          _decrementChildCounter,
                                                      tooltip:
                                                          "Remove passenger",
                                                    ),
                                                    Container(
                                                      child: Text(
                                                          "Child : $_childCounter",
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                    IconButton(
                                                      hoverColor: Colors.purple,
                                                      splashColor:
                                                          Colors.purple,
                                                      color: Colors.purple,
                                                      icon: Icon(Icons.add,
                                                          color: Colors.white),
                                                      onPressed:
                                                          _incrementChildCounter,
                                                      tooltip: "Add passenger",
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          Card(
                                            color: Colors.black12,
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: <Widget>[
                                                  Text(
                                                    "Total :",
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        color: Colors.white),
                                                  ),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Text(
                                                        "Rs. $_total",
                                                        style: TextStyle(
                                                            fontSize: 25,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(20),
                                          ),
                                          Container(
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40),
                                              ),
                                              child: Text("Proceed to payment"),
                                              color: Colors.blueAccent,
                                              onPressed: (_busNo ==
                                              "Tap to select a bus" ||
                                                  _total == 0 ||
                                                  _source == "Source" ||
                                                  _destination == "Destination")?
                                              null:() {
                                                _awaitReturnStatusFromPaymentHelper(
                                                    context);
                                                _sourceTextFieldController
                                                    .clear();
                                                _destinationTextFieldController
                                                    .clear();
                                                setState(() {
                                                _busNo =
                                                "Tap to select a bus";
                                                _total = 0;
                                                _source = "Source";
                                                _destination = "Destination";
                                                _childCounter = 0;
                                                _adultCounter = 0;
                                              });
                                              }
                                            ),
                                          ),
                                        ],
                                      )),
                                )
                              ],
                            ),
                            elevation: 30,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(60),
                                    bottomRight: Radius.circular(60),
                                    bottomLeft: Radius.circular(60))),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _awaitReturnValueFromSecondScreen(BuildContext context, int type) async {
    // start the SecondScreen and wait for it to finish with a result
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => Searcher()));
    // after the SecondScreen result comes back update the Text widget with it
    if (result != null) {
      setState(() {
        if (type == 0) {
          _source = result[0];
          _sourceId = result[1];
        } else {
          _destination = result[0];
          _destinationId = result[1];
        }
      });
    } else {
      setState(() {
        if (type == 0) {
          _source = "Source";
        } else {
          _destination = "Destination";
        }
      });
    }
  }

  void _awaitReturnStatusFromPaymentHelper(BuildContext context) async {
    var _costOfTicket = _total;
    var s = _source;
    var d = _destination;
    var busNo = _busNo;
    var cCount = _childCounter;
    var ticketCountVal = _ticketCounter;
    var aCount = _adultCounter;
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentWorker(
        ticketCost: _costOfTicket)));
    if (result != null && (int.parse(result) == 1)) {
      Fluttertoast.showToast(msg: "Please wait. Generating ticket");
      _bookTicket(s, d, busNo, cCount, aCount, ticketCountVal, _costOfTicket);
    }  else {
      Fluttertoast.showToast(msg: "Some Error took place during payment");
    }

  }

  void _awaitReturnValueFromBookingPageHelper(BuildContext context) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                BookingPageHelper(sId: _sourceId, dId: _destinationId)));
    if (result != null) {
      setState(() {
        _busNo = result[0];
      });
    } else {
      setState(() {
        _busNo = "Please tap to select a bus";
      });
    }
  }

  _toQrImageData(var text, var qrData) async {
    try {
      final image = await QrPainter(
        data: qrData,
        version: QrVersions.auto,
        gapless: false,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      ).toImage(300);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);
      var name = user.uid + '${DateFormat('hh:mm:ss').format(now)}' + ".jpg/";
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child("$name");
      StorageUploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.onComplete;
      print('File Uploaded');
      await storageReference.getDownloadURL().then((fileUrl) {
        _firebaseDb.reference().child('${user.uid}/Tickets/$text').update({
          'qrUrl': '$fileUrl',
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _bookTicket(var s, var d, var busNo, var cCount, var aCount,var ticketCountVal,var total) async {
    var time = new DateFormat('hh:mm:ss').format(now);
    var date = new DateFormat('dd-MM-yyyy').format(now);
    print("time:$time");
    var ref = _firebaseDb.reference().child('${user.uid}/Tickets').push();
    ref.set({
      'index': '${ticketCountVal++}',
      'source': '$s',
      'destination': '$d',
      'bus-No': '$busNo',
      'time': '$time',
      'date': '$date',
      'customDate': '${dayIndexes[now.weekday.toString()]} ${now.day} ${monthIndexes[now.month.toString()]} ${now.year}',
      'adultCount': '$aCount',
      'childCounter': '$cCount',
      'total': '$total',
      'flag': '0',
    }).then((_) {
      var finalAddress = '${user.uid}/Tickets/${ref.key}';
      _toQrImageData(ref.key,finalAddress);
      _firebaseDb.reference().child("${user.uid}").update({
        'ticketCounter': "${ticketCountVal++}",
      });
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Row(
          children: <Widget>[
            Icon(
              Icons.done_outline,
              color: Colors.lightGreen,
            ),
            Text("Ticket confirmed"),
          ],
        ),
        duration: Duration(seconds: 6),
      ));
    }).catchError((onError) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text('Oops...looks like some error occured')
          ],
        ),
        duration: Duration(seconds:4 ),));
    });
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
