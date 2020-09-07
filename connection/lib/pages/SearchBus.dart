import 'dart:ui';

import 'package:connection/SearchBusPages/Retrieve_Bus_No.dart';
import 'package:connection/SearchBusPages/Search_bus.dart';
import 'package:connection/SearchBusPages/searchBusByNumber.dart';
import 'package:connection/pages/chat_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(SearchBusPage());

class SearchBusPage extends StatefulWidget{
  SearchBusPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SearchBusPageState();
  }
}
class _SearchBusPageState extends State<SearchBusPage> with SingleTickerProviderStateMixin{
  String _source = "Source";
  String _destination = "Destination";
  int sourceId, destinationId;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textFieldController = TextEditingController();
  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this,duration: Duration(seconds: 3));
    animation = Tween<double>(begin: 0, end: 300).animate(animationController)..addListener((){
      setState(() {});
    });
    animationController.forward();
  }

  @override
  void dispose(){
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    // TODO: implement build
    return MaterialApp (
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("assets/Ticket1.png"),
                fit: BoxFit.cover),
          ),
          child: Center(
            child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 2.50, sigmaY: 2.50),
              child: Container(
                decoration: new BoxDecoration(color: Colors.white.withOpacity(0.0)),
                height: height,
                width: width,
                padding: EdgeInsets.fromLTRB(30, 220, 30, 0),
                child: Center(
                  child: ListView(
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Card(
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(16),
                              child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      GestureDetector(
                                          onTap: (){
                                            _awaitReturnValueFromSecondScreen(context, 0);
                                          },
                                          child: Container(
                                            width: animation.value*2,
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                controller: textFieldController,
                                                enableInteractiveSelection: false,
                                                keyboardType: TextInputType.text,
                                                style: TextStyle(color: Colors.white),
                                                focusNode: AlwaysDisabledFocusNode(),
                                                decoration: InputDecoration(
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.orangeAccent,width: 5.0),
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.orangeAccent,width: 5.0),
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.black12,
                                                  focusColor: Colors.black12,
                                                  hintText: _source,
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      GestureDetector(
                                          onTap: (){
                                            _awaitReturnValueFromSecondScreen(context, 1);
                                          },
                                          child: Container(
                                            width: animation.value*2,
                                            child: AbsorbPointer(
                                              child: TextFormField(
                                                controller: textFieldController,
                                                enableInteractiveSelection: false,
                                                keyboardType: TextInputType.text,
                                                style: TextStyle(color: Colors.white),
                                                focusNode: AlwaysDisabledFocusNode(),
                                                decoration: InputDecoration(
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.orangeAccent,width: 5.0),
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.orangeAccent,width: 5.0),
                                                    borderRadius: BorderRadius.circular(30),
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.black12,
                                                  focusColor: Colors.black12,
                                                  hintText: _destination,
                                                ),
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(10),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 20.0,right: 20.0,bottom: 10.0,top: 10.0),
                                        height: height/11,
                                        width: animation.value*2,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40.0),
                                            topRight: Radius.circular(40.0),
                                            bottomRight: Radius.circular(40.0),
                                            bottomLeft: Radius.circular(40.0),
                                          ),
                                          child: RaisedButton(
                                            color: Colors.orangeAccent,
                                            textColor: Colors.white,
                                            onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => retrieveBusNoBasedOnInputs(sId: sourceId, dId: destinationId,)));
                                            },
                                            child: Text("Search Bus",style: TextStyle(inherit: true),),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(15),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(left: 20.0,right: 20.0,bottom: 10.0,top: 10.0),
                                        height: height/11,
                                        width: animation.value/2,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(40.0),
                                            topRight: Radius.circular(40.0),
                                            bottomRight: Radius.circular(40.0),
                                            bottomLeft: Radius.circular(40.0),
                                          ),
                                          child: RaisedButton(
                                            color: Colors.orangeAccent,
                                            textColor: Colors.white,
                                            onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => SearchBusByNo()));
                                            },
                                            child: Text("Select BusNo",style: TextStyle(inherit: true),),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                              ),
                            )
                          ],
                        ),
                        elevation:30,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                            bottomLeft: Radius.circular(60)
                        )
                        ),
                      )
                    ],
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
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Searcher()));
    // after the SecondScreen result comes back update the Text widget with it
    if (result != null) {
      setState(() {
        if (type == 0) {
          _source = result[0];
          sourceId = result[1];
        }  else {
          _destination = result[0];
          destinationId = result[1];
        }
      });
    }
    else{
      setState(() {
        if (type == 0) {
          _source = "Source";
        }  else {
          _destination = "Destination";
        }
      });
    }
  }
}
class AlwaysDisabledFocusNode extends FocusNode{
  @override
  bool get hasFocus => false;
}