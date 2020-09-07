import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Map<String,dynamic> map;
var busId = [];
var stationIdList = [];
var busName = [];

var a =[];
var list1 = Map();
var theList = Map();

// ignore: camel_case_types, must_be_immutable
class retrieveBusNoBasedOnInputs extends StatefulWidget{
  var sId,dId;
  retrieveBusNoBasedOnInputs({Key key, @required this.sId, @required this.dId}) : super(key : key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _retrieveBusNoBasedOnInputsState();
  }
}

class _retrieveBusNoBasedOnInputsState extends State<retrieveBusNoBasedOnInputs>{
  bool flag;
  String tappedBusNo;
  _showRoutes() async {
    Firestore _instance = Firestore.instance;
    var s = 'routeStationList.' + widget.sId.toString();
    var d = 'routeStationList.' + widget.dId.toString();
    busName.clear();
    busId.clear();
    //Get the busName based on the source and destination
    await _instance.collection("Routes")
        .where(s,isEqualTo: true)
        .where(d,isEqualTo: true)
        .getDocuments().then((QuerySnapshot snapshot) {
      var li = snapshot.documents.asMap();
      li.forEach((i, j){
        map = j.data;
        busName.add(map['routeName']);
        busId.add(map['routeId']);
        //tempList.add(map['routeStationList']);
      });
    });
    //get the list stationId for each bus and make a map
    for(int i = 0; i != busId.length; i++) {
      stationIdList.clear();
      a.clear();
      await _instance.collection("RouteStations")
          .where('rId', isEqualTo: busId[i])
          .orderBy("leg", descending: false)
          .getDocuments().then((QuerySnapshot snapshot) {
        var li = snapshot.documents.asMap();
        li.forEach((i ,j) {
          stationIdList.add(j.data['sId']);
          a = stationIdList;
        });
      });
      list1[busName[i]] = a;

    }
    _getStations();
  }

  _getStations() async{
    var tempStationIdList = [];
    var tempStationNameList =[];
    var x;
    Firestore _instance = Firestore.instance;
    for (int i = 0; i != list1.length; i++) {
      tempStationIdList.clear();
      tempStationNameList.clear();
      tempStationIdList = list1[busName[i]];
      for (int j = 0; j != tempStationIdList.length; j++) {
        x = tempStationIdList[j].toString();
        await _instance.collection("Stations").document('$x').get().then((DocumentSnapshot snapshot){
          tempStationNameList.add(snapshot.data['stationName']);
        });
      }
      theList[busName[i]] = tempStationNameList;
    }




/*      await Firestore.instance.collection("Stations")
          .getDocuments().then((QuerySnapshot snapshot) {
              var li = snapshot.documents.asMap();
              li.forEach((_, j) {
                map = j.data;
                if (tempStationIdList.contains(map['stationId'])) {
                      tempStationNameList.add(map['stationName']);
                      //print(tempStationNameList);
                  }
              });
      });
      theList[busName[i]] = tempStationNameList;

    }
 */
//    print(theList);
  }

  @override
  void initState() {
    super.initState();
    this.flag = false;
    //this._showRoutes();
  }
  var showThemStations = [];
  int indexVal;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      // ignore: non_constant_identifier_names
      body: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(20),
            child: FutureBuilder(
                future: _showRoutes(),
                builder: (BuildContext context, AsyncSnapshot projectSnap){
                  if (projectSnap.connectionState == ConnectionState.done) {
                    return ListView.separated(
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(busName[index]),
                            trailing: GestureDetector(
                              onTap: () {
                                setState(() {
                                  flag = true;
                                  //tappedBusNo = busName[index];
                                  indexVal = theList[busName[index]].length;
                                  showThemStations = theList[busName[index]];
                                  print(showThemStations);
                                  //print("Selected : $tappedBusNo");
                                });
                              },
                              child: Icon(Icons.arrow_drop_down, color: Colors.white,),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Colors.black,
                        );
                      },
                      itemCount: busId.length,
                    );
                  }  else {
                    return Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: Center(
                        child:  new CircularProgressIndicator(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    );
                  }
                }
            ),
          ),
          Visibility(
            maintainSize: false,
            maintainAnimation: false,
            maintainState: false,
            visible: flag,
            child: _bottomStationListCard(),
          ),
        ],
      ),
    );
  }

  //Work on the hiding and showing of the card, on tapping the bus number the card from the bottom show be visible and show the stations. see about how to use animations.
  Widget _bottomStationListCard(){
    double _initialPercentage = 0.05;
    //print("Here : $a");
    //var showThemStations = theList[tappedBusNo];
    return DraggableScrollableSheet(
        minChildSize: _initialPercentage,
        maxChildSize: 0.95,
        initialChildSize: _initialPercentage,
        builder: (BuildContext context, ScrollController scrollController){
          return ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(40.0),
              topLeft: Radius.circular(40.0),
            ),
            child:Container(
              color: Colors.black54,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 150.0,
                    left: 150.0,
                    child: Container(
                        color: Colors.transparent,
                        child: Icon(Icons.linear_scale)
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(
                    top: 25.0,
                  )),
                  ListView.builder(
                      controller: scrollController,
                      itemCount: indexVal,
                      itemBuilder:(BuildContext context,int index) {
                        return ListTile(
                          title: Text('${showThemStations[index]}'),
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }
}
