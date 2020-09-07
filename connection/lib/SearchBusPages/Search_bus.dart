import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Map<String,dynamic> map;
var stationNameList = [];
var stationLocationList = [];
var stationIdList = [];
final databaseReference = Firestore.instance;
List temp;

class Searcher extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearcherState();
  }
}

class _SearcherState extends State<Searcher>{
  void getData() {
    databaseReference.collection("Stations").getDocuments().then((QuerySnapshot snapshot) {
      var li=snapshot.documents.asMap();
      li.forEach((i,j){
        map=j.data;
        stationNameList.add(map['stationName']);
        stationLocationList.add(map['location']);
        stationIdList.add(map['stationId']);
      });
    } );
  }

  @override
  void initState() {
    super.initState();
    this.getData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // TODO: implement build
    return Scaffold(
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
        width: width,
        height: height,
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
    // TODO: actions for app bar
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
    // TODO: leading icon on the left side of the bar
    return IconButton(
      icon: Icon(Icons.arrow_back),
      color: Colors.white,
      hoverColor: Colors.black,
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // TODO: implement build results
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: show when someone searches for something
    //final suggestionList = query.isEmpty ? recentCities:cities.where((p)=>p.startsWith(query)).toList();
    final suggest = stationNameList;
    final suggestionListForBusName = query.isEmpty ? stationNameList : List.generate(stationNameList.length, (i) => stationNameList[i]).where((p) => p.startsWith(query.toUpperCase())).toList();
    return Card(
      color: Colors.transparent,
      child: ListView.separated(
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemBuilder: (context, index) => Card(
          color: (index % 2 == 0) ? Colors.black : Colors.black12,
          child: ListTile(
            onTap: (){
              showResults(context);
              _sendDataBack(context, suggestionListForBusName[index]);
            },
            leading: Icon(Icons.location_searching),
            title: Text(suggestionListForBusName[index]),
            subtitle: Text(stationLocationList[index]),
          ),
        ),
        itemCount: suggestionListForBusName.length,
      ),
    );
  }

  void _sendDataBack(BuildContext context,String busStopName) {
    var result = [];
    var busStopId;
    result.add(busStopName);
    if (stationNameList.contains("$busStopName")) {
      busStopId = stationIdList[stationNameList.indexOf("$busStopName")];
    }
    result.add(busStopId);
    stationNameList = [];
    stationIdList = [];
    stationLocationList = [];
    Navigator.pop(context);
    Navigator.pop(context, result);
  }
}
