import 'package:admin/ui/1.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

void main() => runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: MyApp(),
));

class MyApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp>{
  String _adminKey;
  bool flag = false;
  String _busNo;
  @override
  Widget build(BuildContext context) {

    _lookUpAdminKey(String val) async {
      DataSnapshot snapshot = await FirebaseDatabase.instance.reference().child('AdminKey').once();
      Map<dynamic, dynamic> list = snapshot.value;
      if(list.containsKey(val)) {
        setState(() {
          flag = true;
        });
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Home(adminKey: val,busNo: _busNo,)));
      }
    }

    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: Wrap(
            children: <Widget>[
              Container(
                //height: MediaQuery.of(context).size.height/3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.start,
                              decoration: new InputDecoration(
                                fillColor: Colors.purpleAccent,
                                hoverColor: Colors.purpleAccent,
                                focusColor: Colors.purpleAccent,
                                hintText: 'Enter Admin key',
                                labelText: 'AdminKey',
                                labelStyle: TextStyle(color: Colors.purpleAccent),
                                hintStyle: TextStyle(color: Colors.purpleAccent),
                                prefixIcon: Icon(Icons.perm_identity,color: Colors.purpleAccent,),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
                              ),
                              style: TextStyle(color: Colors.purpleAccent),
                              cursorColor: Colors.purpleAccent,
                              onChanged: (input){
                                _adminKey = input;
                              },
                              onFieldSubmitted: (input){
                                //_adminKey = input;
                              },
                              enableInteractiveSelection: true,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              textDirection: TextDirection.ltr,
                              textAlign: TextAlign.start,
                              decoration: new InputDecoration(
                                fillColor: Colors.purpleAccent,
                                hoverColor: Colors.purpleAccent,
                                focusColor: Colors.purpleAccent,
                                hintText: 'Enter Bus Number',
                                labelText: 'Bus Number',
                                labelStyle: TextStyle(color: Colors.purpleAccent),
                                hintStyle: TextStyle(color: Colors.purpleAccent),
                                prefixIcon: Icon(Icons.directions_bus,color: Colors.purpleAccent,),
                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.purpleAccent)),
                              ),
                              style: TextStyle(color: Colors.purpleAccent),
                              cursorColor: Colors.purpleAccent,
                              onChanged: (input) {
                                _busNo = input;
                              },
                              onFieldSubmitted: (input){
                                _busNo = input;
                              },
                              enableInteractiveSelection: true,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(5)),
                          Container(
                            width: MediaQuery.of(context).size.width/1.4,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              color: Colors.blue,
                              onPressed: (_adminKey == null || _busNo == null)?null:(){
                                _lookUpAdminKey(_adminKey);
                              },
                              child: Text('Continue'),
                            ),
                          ),
                        ],
                      )
                  ),
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}