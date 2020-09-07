import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
final Firestore _firestore = Firestore.instance;

class Chat extends StatefulWidget{
  static const String id = "chat";
  const Chat({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatState();
  }
}

class _ChatState extends State<Chat>{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  FirebaseUser user;
  bool isSignedIn = false;

  Future<void> callback() async {
    if (_messageController.text.length>0) {
      await _firestore.collection('messages').add({
        'text': _messageController.text,
        'from': user.email,
      });
      _messageController.clear();
      _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: Duration(milliseconds: 300)
      );
    }
  }

  _getUser() async{
    FirebaseUser firebaseUser = await _auth.currentUser();
    await firebaseUser?.reload();
    firebaseUser = await _auth.currentUser();

    if(firebaseUser != null){
      setState(() {
        this.user = firebaseUser;
        this.isSignedIn = true;
      });
    }
  }
  @override
  void initState() {
    this._getUser();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Group Chat"),
        centerTitle: true,
      ),
      body: !isSignedIn? Center(
        child: CircularProgressIndicator(
        ),
      ) : Padding(
        padding: EdgeInsets.only(bottom: 60),
        child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('messages').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.black,
                            ),
                          );
                        }
                        List<DocumentSnapshot> docs = snapshot.data.documents;
                        List<Widget> messages = docs.map((doc) =>Message(
                          from: doc.data['from'],
                          text: doc.data['text'],
                          me: user.email == doc.data['from'],
                        )).toList();
                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          children: <Widget>[
                            ...messages,
                          ],
                        );
                      },
                    )
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left:8.0),
                            child: TextField(
                              scrollPhysics: const BouncingScrollPhysics(),
                              focusNode: FocusNode(),
                              enableInteractiveSelection: true,
                              onSubmitted: (value)=>callback(),
                              controller: _messageController,
                              textAlign: TextAlign.justify,
                              autocorrect: true,
                              enableSuggestions: true,
                              autofocus: false,
                              decoration: InputDecoration(
                                fillColor: Colors.black,
                                focusedBorder: OutlineInputBorder(
                                ),
                                focusColor: Colors.black,
                                hoverColor: Colors.black,
                                hintText: "Enter a Message...",
                                contentPadding: const EdgeInsets.all(10.0),
                                border: const OutlineInputBorder(
                                )
                              ),
                            ),
                          )
                      ),
                      SendButton(
                        callback: callback,
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}

class SendButton extends StatelessWidget{
  final VoidCallback callback;

  const SendButton({Key key, this.callback}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return IconButton(
      icon: Icon(Icons.send),
      color: Colors.lightGreen,
        onPressed: callback,
    );
  }
}


class Message extends StatelessWidget{
  final String from;
  final String text;
  final bool me;

  const Message({Key key, this.from, this.text, this.me}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: GestureDetector(
        onLongPress: (){
          _displayDialog(context, text);
          print("yes");
        },
        child: Column(
          crossAxisAlignment: me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              from,
            ),
            Material(
              color: me ? Colors.teal : Colors.red,
              borderRadius: BorderRadius.circular(10.0),
              elevation: 6.0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 15.0,
                ),
                child: Text(
                  text,
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 10))
          ],
        ),
      )
    );
  }

  _displayDialog(context,String text) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(top: 250),
            child: Center(
                child: RaisedButton.icon(
                    onPressed: (){
                      _perfromDelete(text);
                      Navigator.of(context).pop(true);
                    },
                    icon: Icon(Icons.delete,color: Colors.grey,),
                    label: Text('Delete')
                )
            ),
          );
        });
  }

  _perfromDelete(String text) async {
    await _firestore.collection('messages').where('text',isEqualTo: text)
        .getDocuments().then((snapshot){
          for (DocumentSnapshot ds in snapshot.documents){
            ds.reference.delete();
          }
    });
  }
}
