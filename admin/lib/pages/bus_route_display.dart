
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Map<String,dynamic> map;
var stationListName = [];
var stationIdList = [];
bool flag = false;


class DisplayBusRoutesPage extends StatefulWidget{
  String busNo;
  DisplayBusRoutesPage({Key key, @required this.busNo}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DisplayBusRoutesPageState();
  }
}

class _DisplayBusRoutesPageState extends State<DisplayBusRoutesPage>{


  _buildStationRoute() async {
    Firestore _instance = Firestore.instance;
    var busId;
    await _instance.collection('Routes')
        .where('routeName',isEqualTo: widget.busNo.trim())
        .getDocuments().then((QuerySnapshot snapshot){
      var li = snapshot.documents.asMap();
      li.forEach((i,j){
        busId = j.data['routeId'];
      });
    });

    await _instance.collection('RouteStations')
        .where('rId',isEqualTo: busId)
        .getDocuments().then((QuerySnapshot snapshot){
      var li = snapshot.documents.asMap();
      li.forEach((i, j){
        stationIdList.add(j.data['sId']);
      });
    });

    await _instance.collection("Stations")
        .getDocuments().then((QuerySnapshot snapshot){
      var li = snapshot.documents.asMap();
      li.forEach((i, j){
        (stationIdList.contains(j.data['stationId']))?stationListName.add(j.data['stationName']):print("");
      });
    });
    setState(() {
      flag = true;
    });
  }

  @override
  void initState() {
    _buildStationRoute();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    /*WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);*/
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.black54,
          appBar: AppBar(
            title: Text("Search Place"),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                tooltip: "Search",
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                },
                color: Colors.white,
                hoverColor: Colors.black,
              )
            ],
          ),
          //drawer: Drawer(),
          body: Container(
            color: Colors.transparent,
            padding: EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
              ],
            ),
          ),
    );
  }
}

class DataSearch extends SearchDelegate{
  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: theme.primaryColor,
      primaryIconTheme: theme.primaryIconTheme,
      primaryColorBrightness: theme.primaryColorBrightness,
      primaryTextTheme: theme.primaryTextTheme,
    );
  }


  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return [
      IconButton(
        icon: Icon(Icons.clear),
        color: Colors.white,
        hoverColor: Colors.black,
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    return IconButton(
      icon: Icon(Icons.arrow_back),
      color: Colors.white,
      hoverColor: Colors.black,
      onPressed: () {
        close(context, null);
      },
    ) ;
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement buildResults
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    final suggestionListForBusName = query.isEmpty ? stationListName : List.generate(stationListName.length, (i) => stationListName[i]).where((p) => p.startsWith(query.toUpperCase())).toList();
    return Card(
      color: Colors.black,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, index) => Card(
          color: (index % 2 == 0) ? Colors.black54 : Colors.black38,
          child: ListTile(
            onTap: (){
              showResults(context);
              _sendDataBack(context, suggestionListForBusName[index]);
            },
            leading: Icon(Icons.location_searching),
            title: Text(suggestionListForBusName[index]),
          ),
        ),
        itemCount: suggestionListForBusName.length,
      ),
    );
  }


  void _sendDataBack(BuildContext context,String busStopName) {
    var result;
    result = busStopName;
    print(result);

    /*if (stationNameList.contains("$busStopName")) {
      busStopId = stationIdList[stationNameList.indexOf("$busStopName")];
    }*/
    //stationNameList = [];
    Navigator.pop(context);
    Navigator.pop(context, result);
  }
}