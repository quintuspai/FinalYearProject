import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentWorker extends StatefulWidget{
  var ticketCost;
  PaymentWorker({Key key,@required this.ticketCost}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PaymentWorkerState();
  }
}

class _PaymentWorkerState extends State<PaymentWorker>{
  GlobalKey globalKey = new GlobalKey();
  var now = new DateTime.now();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  FirebaseDatabase _firebaseDb = new FirebaseDatabase();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> map;
  FirebaseUser user;
  int _ticketCounter;
  bool isSignedIn = true;
  Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay =  Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() async {
    var options = {
      'key' : 'rzp_test_88LKxUYy2h5Dly',
      'amount' : '${widget.ticketCost*100}',
      'name' : 'Connection',
      'description' : 'Payment',
      'prefill' : {'contact' : '', 'email' : ''},
      'external' : {'wallets' : ['paytm']},
    };
    try{
      razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "Success "+ response.paymentId,backgroundColor: Colors.lightGreenAccent);
    razorpay.clear();
    var a = '1';
    Navigator.pop(context,a);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "ERROR "+ response.code.toString() + " - " + response.message,backgroundColor: Colors.red);
    razorpay.clear();
    var a = '0';
    Navigator.pop(context,a);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External wallet" + response.walletName);
    razorpay.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: globalKey,
      body: !isSignedIn
          ? Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.black,
          ),
        ),
      )
          : Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            color: Colors.black12,
            child: Container(
              height: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom,
              //height: MediaQuery.of(context).size.height/1.111,
              color: Colors.black12,
              child: Container(
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Card(
                        color: Colors.transparent,
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.all(2),
                              child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                      ),
                                      ListTile(
                                        title: Card(
                                          color: Colors.black12,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            child: Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceEvenly,
                                              children: <Widget>[
                                                Text(
                                                  "Amount :",
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.grey),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: <Widget>[
                                                    Text(
                                                      "Rs. ${widget.ticketCost}",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          color:
                                                          Colors.white),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(20),
                                      ),
                                      Container(
                                        child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(40),
                                          ),
                                          child: Text("Payment"),
                                          color: Colors.blueAccent,
                                          onPressed: (){
                                            openCheckout();
                                          }
                                      ),
                                      )
                                    ],
                                  )),
                            )
                          ],
                        ),
                        elevation: 30,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(60),
                                topRight: Radius.circular(60),
                                bottomRight: Radius.circular(60),
                                bottomLeft: Radius.circular(60))),
                      ),
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
}