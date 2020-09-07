import 'dart:ffi';

import 'package:connection/pages/1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class SignUp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUp>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String value = "";
  String _email, _password;
  bool _isButtonDisabled = true;
  bool _autoValidate = false;
  TextEditingController _passwordTextFieldController = TextEditingController();
  TextEditingController _emailTextFieldController = TextEditingController();

  Future<bool> _onSignUp(String Message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), (){
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            elevation: 1.0,
            backgroundColor: Colors.lightGreen,
            title: Text("$Message"),
          );
        });
  }
  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) {
      if (user != null) {
        var i = 0;
        FirebaseDatabase.instance.reference().child('${user.uid}').set({
          'email': user.email,
          'Name': (user.displayName == null)? 'NoName':user.displayName,
          'displayPicture': null,
          'setUpflag' : 'true',
          'ticketCounter' : '${i.toInt()}'
        }).then((_){
          _onSignUp('Welcome ${user.email}');
        });
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }


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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.checkAuthentication();
  }
  signUp(String email, String password) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      FirebaseUser user;
      try {
        user = (await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        )) as FirebaseUser;
        if (user != null) {
          UserUpdateInfo userUpdateInfo = UserUpdateInfo();
          user.updateProfile(userUpdateInfo);
        }
      } catch (signUpError) {
        if (signUpError is PlatformException) {
          if (signUpError.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
            showError('The email is already in use');
          }
          if (signUpError.code == "ERROR_INVALID_EMAIL") {
            showError('Invalid email');
          }
        }
      }
    }
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
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
        title: Text("SIGN UP"),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: WillPopScope(
        child:Container(
        padding: EdgeInsets.fromLTRB(30, 80, 30, 40),
        child: Center(
          child: ListView(
            children: <Widget>[
              Card(
                elevation:30,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                    bottomRight: Radius.circular(60),
                    bottomLeft: Radius.circular(60)),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(10.0, 50.0, 10.0, 50.0),
                      child: ClipOval(
                          child:Image(
                            image: AssetImage('assets/circle_bus.png'),
                            height: 100,
                            width: 100,
                          )),
                    ),
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
                            //email
                            Container(
                              child: TextFormField(
                                controller: _emailTextFieldController,
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
                                    hintText: 'E-mail'),
                                onTap: (){},
                                onSaved: (input) => _email = input,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            // Password TextField
                            Container(
                              child: TextFormField(
                                controller: _passwordTextFieldController,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: validatePasswordLength,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                        BorderSide(color: Colors.transparent,width: 5.0),
                                        borderRadius:
                                        BorderRadius.circular(30)),
                                    contentPadding: EdgeInsets.all(15),
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.lightGreen,width: 5.0),
                                        borderRadius: BorderRadius.circular(30)),
                                    hintStyle: TextStyle(color: Colors.white),
                                    hintText: 'Password'),
                                onTap: (){},
                                onSaved: (input) => _password = input,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20),
                            ),
//                    button
                            RaisedButton(
                                padding: EdgeInsets.fromLTRB(80, 15, 80, 15),
                                color: Colors.lightGreen,
                                disabledElevation: 10.0,
                                disabledColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadiusDirectional.circular(30),
                                ),
                                onPressed: (_emailTextFieldController.text.isNotEmpty && _passwordTextFieldController.text.isNotEmpty) ? null : (){
                                  _validateInputs();
                                  signUp(_email, _password);
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                            ), //redirect to signup page
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  String validatePasswordLength(String value) {
    if (value.length < 6)
      return 'Password must be more than 6 charater';
    else
      return null;
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