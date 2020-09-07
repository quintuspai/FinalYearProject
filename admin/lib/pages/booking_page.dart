import 'package:admin/pages/bus_route_display.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

FirebaseDatabase _firebaseDb = new FirebaseDatabase();
Map<String, dynamic> map;
var stationListName = [];
var stationIdList = [];

class BookingPage extends StatefulWidget {
  String adminKey, busNo;

  BookingPage({Key key, @required this.adminKey, @required this.busNo})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _BookingPageState();
  }
}

class _BookingPageState extends State<BookingPage> {
  var _halfTicket = 1, _fullTicket = 2;
  var _total = 0;
  bool flag = true;
  String _source = "Source";
  String _destination = "Destination";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _sourceTextFieldController = TextEditingController();
  TextEditingController _destinationTextFieldController =
      TextEditingController();
  var now = new DateTime.now();
  int _adultCounter = 0, _childCounter = 0;
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

  _calculateTicketCost() {
    setState(() {
      _total = ((_halfTicket * _childCounter).toInt() +
              (_fullTicket * _adultCounter))
          .toInt();
    });
    print(_total);
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
    // _buildStationRoute();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        body: !flag
            ? Container(
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.black,
              ),
            ))
            : Padding(
              padding: const EdgeInsets.only(top:25.0),
              child: Container(
          color: Colors.black,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                color: Colors.black12,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  color: Colors.black12,
                  child: Container(
                    child: ListView(
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
                                                    color:
                                                    Colors.white),
                                                focusNode:
                                                AlwaysDisabledFocusNode(),
                                                decoration:
                                                InputDecoration(
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .orangeAccent,
                                                        width: 5.0),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        30),
                                                  ),
                                                  border:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .orangeAccent,
                                                        width: 5.0),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        30),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                  Colors.black12,
                                                  focusColor:
                                                  Colors.black12,
                                                  hintText: _source,
                                                ),
                                              ),
                                            )),
                                        Padding(
                                            padding:
                                            EdgeInsets.all(10)),
                                        Container(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.only(
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
                                                    color:
                                                    Colors.white),
                                                focusNode:
                                                AlwaysDisabledFocusNode(),
                                                decoration:
                                                InputDecoration(
                                                  enabledBorder:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .orangeAccent,
                                                        width: 5.0),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        30),
                                                  ),
                                                  border:
                                                  OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                        color: Colors
                                                            .orangeAccent,
                                                        width: 5.0),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        30),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                  Colors.black12,
                                                  focusColor:
                                                  Colors.black12,
                                                  hintText:
                                                  _destination,
                                                ),
                                              ),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.all(20),
                                        ),
                                        Card(
                                          color: Colors.black12,
                                          child: Container(
                                            alignment:
                                            Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Travel date : ",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color:
                                                      Colors.white),
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
                                                      "${dayIndexes[now.weekday.toString()]} ${now.day} ${monthIndexes[now.month.toString()]}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors
                                                              .white),
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
                                            CrossAxisAlignment
                                                .center,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceEvenly,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: <Widget>[
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.remove,
                                                      color:
                                                      Colors.white,
                                                    ),
                                                    focusColor:
                                                    Colors.purple,
                                                    hoverColor:
                                                    Colors.purple,
                                                    onPressed:
                                                    _decrementAdultCounter,
                                                    tooltip:
                                                    "Remove a passenger",
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        "Adult : $_adultCounter",
                                                        style: TextStyle(
                                                            fontSize:
                                                            25,
                                                            color: Colors
                                                                .white)),
                                                  ),
                                                  IconButton(
                                                    focusColor:
                                                    Colors.purple,
                                                    hoverColor:
                                                    Colors.purple,
                                                    icon: Icon(
                                                        Icons.add,
                                                        color: Colors
                                                            .white),
                                                    onPressed:
                                                    _incrementAdultCounter,
                                                    tooltip:
                                                    "Add a passenger",
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                  padding:
                                                  EdgeInsets.only(
                                                      top: 10.0)),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                                children: <Widget>[
                                                  IconButton(
                                                    hoverColor:
                                                    Colors.purple,
                                                    splashColor:
                                                    Colors.purple,
                                                    color:
                                                    Colors.purple,
                                                    //highlightColor: Colors.purple,
                                                    icon: Icon(
                                                      Icons.remove,
                                                      color:
                                                      Colors.white,
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
                                                            fontSize:
                                                            25,
                                                            color: Colors
                                                                .white)),
                                                  ),
                                                  IconButton(
                                                    hoverColor:
                                                    Colors.purple,
                                                    splashColor:
                                                    Colors.purple,
                                                    color:
                                                    Colors.purple,
                                                    icon: Icon(
                                                        Icons.add,
                                                        color: Colors
                                                            .white),
                                                    onPressed:
                                                    _incrementChildCounter,
                                                    tooltip:
                                                    "Add passenger",
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
                                            alignment:
                                            Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Total :",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color:
                                                      Colors.white),
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
                                                      "Rs. $_total",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors
                                                              .white),
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
                                            shape:
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  40),
                                            ),
                                            child: Text("Book"),
                                            color: Colors.blueAccent,
                                            onPressed: (_source == 'Source' || _destination == 'Destination' || _total == 0)? null :() {
                                              _bookTicket();
                                              _sourceTextFieldController
                                                  .clear();
                                              _destinationTextFieldController
                                                  .clear();
                                              setState(() {
                                                _total = 0;
                                                _source = "Source";
                                                _destination =
                                                "Destination";
                                                _childCounter = 0;
                                                _adultCounter = 0;
                                              });
                                            },
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
                        Padding(
                          padding: const EdgeInsets.only(top: 350),
                          child: Divider(
                            color: Colors.grey,
                            thickness: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        context,
        MaterialPageRoute(
            builder: (context) => DisplayBusRoutesPage(
                  busNo: widget.busNo,
                )));
    // after the SecondScreen result comes back update the Text widget with it
    if (result != null) {
      setState(() {
        if (type == 0) {
          _source = result;
        } else {
          _destination = result;
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

  _bookTicket() async {
    var time = new DateFormat('hh:mm:ss').format(now);
    var date = new DateFormat('dd-MM-yyyy').format(now);
    _firebaseDb.reference().child('${widget.adminKey}').push().set({
      'source': '$_source',
      'destination': '$_destination',
      'bus-No': '${widget.busNo}',
      'time': '$time',
      'date': '$date',
      'adultCount': '$_adultCounter',
      'childCounter': '$_childCounter',
      'total': '$_total'
    }).then((_) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: <Widget>[
          Icon(
            Icons.done_outline,
            color: Colors.lightGreen,
          ),
          Text("Ticket Confirmed"),
        ],
      ),duration: Duration(seconds: 4),));
    }).catchError((onError) {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          Text("Oops...Some error occured try agian"),
        ],
      )));
    });

    print("Booked");
  }
}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
