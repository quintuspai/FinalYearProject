import 'dart:async';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class QrScanner extends StatefulWidget{
  QrScanner({Key key, }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _QrScannerState();
  }
}

class _QrScannerState extends State<QrScanner> {
  String barcode = "";
  var backGroundColors = Colors.black;
  var childCounter="", adultCounter="", dateTime="";
  var flag;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    //SystemChrome.setEnabledSystemUIOverlays([]);
    return Scaffold(
        appBar:  AppBar(
          title:  Text('QR Code Scanner'),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        backgroundColor: backGroundColors,
        body: Padding(
          padding: const EdgeInsets.all(11.0),
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: RaisedButton(
                        color: Colors.blue,
                        textColor: Colors.white,
                        splashColor: Colors.blueGrey,
                        onPressed: scan,
                        child: const Text('START CAMERA SCAN')
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: <Widget>[
                        //Text(barcode, textAlign: TextAlign.center,),
                        Text(dateTime, textAlign: TextAlign.center,),
                        Text(adultCounter, textAlign: TextAlign.center,),
                        Text(childCounter, textAlign: TextAlign.center,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  _retrieveTicketData(var url) async {
    var tempDate,tempTime;
    var finalDateTime,newTimeObj;
    var now = new DateTime.now();
    var currentTime = new DateFormat('hh:mm:ss').format(now);
    var currentDate = new DateFormat('dd:mm:yyyy').format(now);
    var finalCurrentTime = new DateFormat("hh:mm:ss").parse(currentTime);
    FirebaseDatabase _firebaseDb = new FirebaseDatabase();
    await _firebaseDb.reference().child('$url').once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> list = snapshot.value;
      setState(() {
        this.childCounter = 'Child. ${list['childCounter']}';
        this.adultCounter = 'Adult. ${list['adultCount']}';
        this.dateTime = list['customDate']  + list['time'];
        this.flag = int.parse(list['flag']);
        tempDate = list['date'];
        tempTime = list['time'];
      });
      newTimeObj = new DateFormat("hh:mm:ss").parse(tempTime);
      finalDateTime = newTimeObj.add(Duration(hours: 1));

    });
    if (((currentDate.compareTo(tempDate) == 1) && (finalDateTime.isAfter(finalCurrentTime)) &&(flag == 0))) {
      await _firebaseDb.reference().child('$url').update({
        'flag' : '1',
      });
      setState(() {
        backGroundColors = Colors.lightGreenAccent;
      });
    }  else {
      backGroundColors = Colors.red;
    }
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.barcode = barcode);
      await _retrieveTicketData(barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}