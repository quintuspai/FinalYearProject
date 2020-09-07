import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './login_signUp/Login.dart';
import './login_signUp/SignUp.dart';
import './pages/1.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.dark,
        home: MyHomePage(),
      ));
}

class MyHomePage extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage>{

  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('You are going to exit the application!!'),
            actions: <Widget>[
              FlatButton(
                child: Text('NO'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('YES'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        });
  }



  Future<bool> _onGoogleSignInSuccess(context,String Message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), (){
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Container(
              //height: 350,
              child: Stack(
                children: <Widget>[
                  Card(
                    color: Colors.transparent,
                    elevation: 0.0,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 150,
                          width: 150,
                          decoration: new BoxDecoration(
                            color: Colors.transparent,
                            image: new DecorationImage(
                              image: AssetImage('assets/login_success.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
                          ),
                        ),
                      ClipRRect(
                        child:   Text("$Message",style: TextStyle(color: Colors.purpleAccent,fontSize: 25),),
                      )
                      ],
                    ),
                  )
                ],
              )
            )
          );
        }
    );
  }

  Future<bool> _onGoogleSignInFailure(context,String Message) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 2), (){
            Navigator.of(context).pop(true);
          });
          return AlertDialog(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              title: Container(
                //height: 350,
                  child: Stack(
                    children: <Widget>[
                      Card(
                        color: Colors.transparent,
                        elevation: 0.0,
                        child: Column(
                          children: <Widget>[
                            Container(
                              height: 150,
                              width: 150,
                              decoration: new BoxDecoration(
                                color: Colors.transparent,
                                image: new DecorationImage(
                                  image: AssetImage('assets/login_error.png'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: new BorderRadius.all(new Radius.circular(150.0)),
                              ),
                            ),
                            ClipRRect(
                              child:   Text("$Message",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 19),),
                            )
                          ],
                        ),
                      )
                    ],
                  )
              )
          );
        }
    );
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentication();
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    SystemChrome.setEnabledSystemUIOverlays([]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    //SystemNavigator.pop();
    // TODO: implement build
    return Scaffold(
        body: WillPopScope(
            onWillPop: _onBackPressed,
            child:Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage("assets/bus.gif"),
                    fit: BoxFit.cover),
              ),
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: TextDirection.ltr,
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(60)),
                  Container(
                    padding: EdgeInsets.all(40.0),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 50.0,right: 50.0,bottom: 10.0,top: 50.0),
                      //color: Colors.red,
                      height: height/7,
                      width: width,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                          bottomRight: Radius.circular(40.0),
                          bottomLeft: Radius.circular(40.0),
                        ),
                        child: SignInButton(
                          Buttons.Google,
                          text: "Continue with Google",
                          onPressed: () {
                            _signUpWithGoogle(context)
                                .then((FirebaseUser user) => print(user))
                                .catchError((e) => print(e));
                          },
                        ),
                      )
                  ),
                  Padding(padding: EdgeInsets.all(5)),
                  Container(
                    padding: EdgeInsets.only(left: 50.0,right: 50.0,bottom: 10.0,top: 10.0),
                    height: height/11,
                    width: width,
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40.0),
                        topLeft: Radius.circular(40.0),
                        bottomLeft: Radius.circular(40.0),
                        bottomRight: Radius.circular(40.0),
                      ),
                      child: RaisedButton(
                        color: Colors.lightGreen,
                        textColor: Colors.white,
                        onPressed: (){
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => SignUp()));
                        },
                        child: Text("Sign up",style: TextStyle(inherit: true),),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(15)),
                  GestureDetector(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account?',style: TextStyle(color: Colors.white,fontSize: 18),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Sign in.',style: TextStyle(color: Colors.green,fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                    },
                  ),
                ],
              ),
            )
        )
    );
  }

  checkAuthentication() async {
    _auth.onAuthStateChanged.listen((user) async {
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    });
  }

  Future<FirebaseUser> _signUpWithGoogle(context) async {
    bool flag = true,status=false;
    FirebaseDatabase _firebaseDb = FirebaseDatabase.instance;
    try {
      final GoogleSignInAccount googleSignInAccount =
      await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
      await _auth.signInWithCredential(authCredential);
      final FirebaseUser user = authResult.user;

      assert(user.email != null);
      assert(user.displayName != null);

      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentuser = await _auth.currentUser();
      assert(user.uid == currentuser.uid);

      _onGoogleSignInSuccess(context,' Welcome ${user.displayName}');

    await _firebaseDb.reference().child('${user.uid}').once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> list = snapshot.value;
      print(list['setUpFlag']);
      if (list['setUpFlag'] == true) {
        setState(() {
          status = true;
        });
      }
    }).catchError((onError){
      print("Error");
      var i = 0;
       _firebaseDb.reference().child('${user.uid}').set({
        'email': user.email,
        'Name': user.displayName,
        'displayPicture': user.photoUrl,
        'setUpflag' : '$flag',
         'ticketCounter' : '${i.toInt()}'
      });
    });
      return user;
    } catch (e) {
      _onGoogleSignInFailure(context,"Some error occured.Please try again");
    }
  }
}