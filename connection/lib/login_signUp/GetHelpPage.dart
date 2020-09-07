import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class GetHelpPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _GetHelpPageState();
  }
}



class _GetHelpPageState extends State<GetHelpPage>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email;
  bool _autoValidate = false;


  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Future<void> resetPassword(String email) async{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: WillPopScope(
        child: Container(
          padding: EdgeInsets.fromLTRB(30, 80, 30, 40),
          child: Center(
            child: ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  child: Form(
                      key: _formKey,
                      autovalidate: _autoValidate,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                          Container(
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              cursorColor: Colors.white,
                              style: TextStyle(color: Colors.white),
                              validator: validateEmail,
                              decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.transparent,width: 5.0),
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                  contentPadding: EdgeInsets.all(15),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.white,
                                  ),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.lightGreen,width: 5.0),
                                      borderRadius: BorderRadius.circular(30)),
                                  hintStyle: TextStyle(color: Colors.white),
                                  hintText: 'Enter E-mail'),
                              onTap: (){},
                              onSaved: (input) => _email = input,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(20),
                          ),
//                    button
                          RaisedButton(
                              padding: EdgeInsets.fromLTRB(80, 15, 80, 15),
                              color: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadiusDirectional.circular(30),
                              ),
                              onPressed:(){
                                _validateInputs();
                                resetPassword(_email);
                              },
                              child: Text(
                                'Send E-mail',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              )),
//                      redirect to signup page
                          Padding(
                            padding: EdgeInsets.all(10),
                          ),
                        ],
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
}