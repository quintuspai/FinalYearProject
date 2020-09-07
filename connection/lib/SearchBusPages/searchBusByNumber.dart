import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Map<String,dynamic> map;
List<String> busNameList = [];
final databaseReference = Firestore.instance;
var busIdList = [];

class SearchBusByNo extends StatefulWidget{
  SearchBusByNo({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchBusByNoState();
  }
}

class  _SearchBusByNoState extends State<SearchBusByNo>{

  void getData() {
    databaseReference.collection("Routes").getDocuments().then((QuerySnapshot snapshot) {
    var li=snapshot.documents.asMap();
    li.forEach((i,j){
      map = j.data;
      //var temp = map['routeName'];
      busNameList.add(map['routeName']);
      busIdList.add(map['routeId']);
      });
    });
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

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Place"),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: BusSearch());
            },
            color: Colors.black,)
        ],
      ),
    );
  }
}

class BusSearch extends SearchDelegate{
  var tappedBusId;
  var tempStationList = [];
  var tempStationLocList = [];
  _showRoute() async {
      var stationIdList = [];
      await databaseReference.collection("RouteStations")
          .where('rId', isEqualTo: tappedBusId)
          .orderBy('leg',descending: false)
          .getDocuments().then((QuerySnapshot snapshot) {
            var li = snapshot.documents.asMap();
            li.forEach((_, j) {
                  stationIdList.add(j.data['sId']);
            });
      });
      var x;
      for (int i = 0; i != stationIdList.length; i++) {
          x = stationIdList[i].toString();
          await databaseReference.collection("Stations")
              .document('$x').get().then((DocumentSnapshot snapshot) {
                tempStationList.add(snapshot.data['stationName']);
                tempStationLocList.add(snapshot.data['location']);
          });
      }
  }


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
        tooltip: "Clear query",
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
      tooltip: "Back",
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
    return FutureBuilder(
        future: _showRoute(),
        builder: (BuildContext context, AsyncSnapshot projectSnap) {
          if (projectSnap.connectionState == ConnectionState.done) {
              return Container(
                color: Colors.transparent,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: ListView.separated(
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0.0,
                        color: (index % 2 == 0) ? Colors.black : Colors.black12,
                        child: ListTile(
                          title: Text(tempStationList[index]),
                          subtitle: Text(tempStationLocList[index]),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider();
                    },
                    itemCount: tempStationList.length,
                ),
              );
          }  else if (projectSnap.connectionState == ConnectionState.waiting) {
            return Center(
                  child: Card(
                    elevation: 0.0,
                    child: Stack(
                      children: <Widget>[
                        Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        Center(
                          child: Text("Fetching Results..."),
                        ),
                      ],
                    ),
                  ),
            );
          } else {
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: show when someone searches for something
    //final suggestionList = query.isEmpty ? recentCities:cities.where((p)=>p.startsWith(query)).toList();
    final suggestionListForBusName = (query.isEmpty) ? [] : List.generate(busNameList.length, (i) => busNameList[i]).where((p) => p.startsWith(query)).toList();
    return Card(
      child: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          onTap: (){
            showResults(context);
            tappedBusId  = busIdList[busNameList.indexOf(suggestionListForBusName[index])];
          },
          onLongPress: (){
            print("Oyee");
          },
          leading: CircleAvatar(
            child: Text(suggestionListForBusName[index].substring(0, suggestionListForBusName[index].length)),
          ),
          title: Text(suggestionListForBusName[index]),
          trailing: Icon(Icons.keyboard_arrow_right, semanticLabel: "Book", textDirection: TextDirection.ltr,),
        ),
        itemCount: suggestionListForBusName.length,
      ),
    );
  }
}