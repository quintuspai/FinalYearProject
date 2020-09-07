
import 'package:connection/pages/1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './GetHelpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginState();
  }
}

class _LoginState extends State<Login>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String value = "";
  String _email, _password;
  bool _isButtonDisabled = true;
  bool _autoValidate = false;
  bool _flag1 = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _passwordTextFieldController = TextEditingController();
  TextEditingController _emailTextFieldController = TextEditingController();

  /* Showing the error message */

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }

  void signIn() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      try {
        AuthResult user = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        var mes = "Logged in successfully!";
        showError(mes, 1);
      } catch (e) {
        showError("Failed to log in. Please check your credentials and try again.",0);
      }
    }
  }

  checker(int f){
    var status;
    if (f == 1) {
      status = Colors.lightGreen;
    } else {
      status = Colors.red;
    }
    return status;
  }

  showError(String message,int f) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 3), (){
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            elevation: 1.0,
            backgroundColor: checker(f),
            title: Text("$message"),
          );
        });
  }

  void _validateInputs() {
    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState.save();
      setState(() {
       _flag1 = true;
      });
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
    }
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
        centerTitle: true,
        title: Text("Login"),
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: WillPopScope(
        child:Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(
            top: 50,
            right: 10.0,
            left: 10.0,
            bottom: 50.0),
        child: Center(
          child: ListView(
            children: <Widget>[
              Card(
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
                            // E-mail TextField
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
                              padding: EdgeInsets.only(top: 60),
                            ),
                            //  Sign In button
                            RaisedButton(
                                padding: EdgeInsets.fromLTRB(80, 15, 80, 15),
                                color: Colors.lightGreen,
                                disabledElevation: 10.0,
                                disabledColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadiusDirectional.circular(30),
                                ),
                                onPressed: !(_emailTextFieldController.text.isNotEmpty && _passwordTextFieldController.text.isNotEmpty) ? null : (){
                                  _validateInputs();
                                  signIn();
                                },
                                child: Text(
                                    'Log In',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20),
                            ),
                            // Text Button to Sign Up page
                            GestureDetector(
                              onTap: (){  Navigator.push(context, MaterialPageRoute(builder: (context) => GetHelpPage() ));
                              },
                              child: RichText(
                                  text: TextSpan(
                                      text: 'Having trouble login in?',style: TextStyle(color: Colors.white,fontSize: 18),
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: ' Click here.',style: TextStyle(color: Colors.green,fontSize: 18)
                                        )
                                      ]
                                  ))
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                            ),
                          ],
                        ),
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