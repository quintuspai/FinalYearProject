import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String, dynamic> map;
var busName = [];

class BookingPageHelper extends StatelessWidget {
  var sId, dId;
  var flag = true;

  BookingPageHelper({Key key, @required this.sId, @required this.dId})
      : super(key: key);

  Future _fetchBus() async {
    Firestore _instance = Firestore.instance;
    var s = 'routeStationList.' + sId.toString();
    var d = 'routeStationList.' + dId.toString();
    busName.clear();
    await _instance
        .collection("Routes")
        .where(s, isEqualTo: true)
        .where(d, isEqualTo: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      var li = snapshot.documents.asMap();
      li.forEach((i, j) {
        map = j.data;
        busName.add(map['routeName']);
      });
      flag = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      //backgroundColor: Colors.black,
      body: Container(
          color: Colors.black,
          child: FutureBuilder(
              future: _fetchBus(),
              builder: (BuildContext context, AsyncSnapshot projectSnap) {
                if (projectSnap.connectionState == ConnectionState.none) {
                  return Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 30,
                          ),
                          Text(
                              "Looks like you are not connected to the internet"),
                        ],
                      ),
                    ),
                  );
                } else if (projectSnap.connectionState ==
                    ConnectionState.waiting) {
                  return Container(
                    child: Center(
                      child: new CircularProgressIndicator(
                        backgroundColor: Colors.black,
                      ),
                    ),
                  );
                } else if (projectSnap.connectionState == ConnectionState.done) {
                  return !(flag)? ListView.separated(
                    itemBuilder: (context, index) {
                      return Card(
                        child: GestureDetector(
                          onTap: (){
                            _sendDataBack(context, busName[index]);
                          },
                          child: ListTile(
                            title: Text(busName[index]),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.white,
                      );
                    },
                    itemCount: busName.length,
                  ) : Container(
                    alignment: Alignment.center,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(Icons.error_outline,color: Colors.red,size: 30,),
                          Text("Please select source and destination",style: TextStyle(color: Colors.red,fontSize: 20),),
                        ],
                      )
                    ),
                  );
                } else {
                  return Container(
                    child: Center(
                      child: Text("Please try again..."),
                    ),
                  );
                }
              })),
    );
  }

  void _sendDataBack(BuildContext context, String busStopName) {
    var result = [];
    result.add(busStopName);
    Navigator.pop(context, result);
  }

}
