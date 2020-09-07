import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;
class SettingPage extends StatefulWidget{
  var userName,userDpUrl,userEmail;
  SettingPage({Key key, @required this.userDpUrl, @required this.userEmail, @required this.userName}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _SettingPageState();
  }
}

class _SettingPageState extends State<SettingPage> {
  File _selectedFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _displayNameFlag = false,
      _emailFlag = false,
      _displayPictureFlag = false;
  FirebaseUser user;
  bool isSignedIn = false;
  String _imageUrl, _displayName, _email;
  String _iniEmailId = '...',
      _iniDisplayName = "...",
      _iniDisplayPictureUrl;
  var uid;
  var _uploadedFileURL;

  _updateDisplayName() {
    database.reference().child('${user.uid}').update({
      'Name': _displayName,
    });
  }

  _updateEmail() {
    database.reference().child('${user.uid}').update({
      'email': _email,
    });
  }

  _updateDisplayPicture() {
    database.reference().child('${user.uid}').update({
      'displayPicture': _uploadedFileURL,
    });

  }

  _getUser() async {
    this._iniDisplayPictureUrl = widget.userDpUrl;
    this._iniDisplayName = widget.userName;
    this._iniEmailId = widget.userEmail;
  }

  Future uploadFile() async {
    var name= user.uid+".jpg/";
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child("$name");
    StorageUploadTask uploadTask = storageReference.putFile(_selectedFile);
    await uploadTask.onComplete;
    print('File Uploaded');
    await storageReference.getDownloadURL().then((fileURL) {
      //print("url:$fileURL");
      setState(() {
        _uploadedFileURL = fileURL;
        _displayPictureFlag = true;
      });
    });
  }

  getImage(ImageSource source) async {
    File image = await ImagePicker.pickImage(source: source);
    if (image != null) {
      File croppped = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
        androidUiSettings: AndroidUiSettings(
          cropFrameColor: Colors.white,
          toolbarColor: Colors.grey,
          toolbarTitle: " Image Cropper",
          statusBarColor: Colors.blueAccent,
          backgroundColor: Colors.black,
        ),
      );
      this.setState((){
        _selectedFile = croppped;
      });
    }
    uploadFile();
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text("Edit Profile"),
        centerTitle: true,
        backgroundColor: Colors.black,
        actions: <Widget>[
          RaisedButton.icon(
              shape:  RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
              ),
              color: Colors.blueAccent,
              disabledColor: Colors.transparent,
              disabledTextColor: Colors.grey,
              onPressed: (){
                if (_emailFlag) {
                  _updateEmail();
                }
                if (_displayNameFlag) {
                  _updateDisplayName();
                }
                if (_displayPictureFlag) {
                  _updateDisplayPicture();
                }
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.edit,color: Colors.grey,), label: Text("Edit"))
        ],
      ),
      body: FutureBuilder(
          future: _getUser(),
          builder: (BuildContext context, AsyncSnapshot snapshot){
            if (snapshot.connectionState == ConnectionState.none) {
              return SnackBar(
                  content: Text("Check your connection!!!"));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: Center(
                  child: CircularProgressIndicator(backgroundColor: Colors.black,),
                ),);
            } else {
              return Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.height,
                color: Colors.black,
                child: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: ListView(
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          textDirection: TextDirection.ltr,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(padding: EdgeInsets.only(top: 5),),
                            Divider(thickness: 2,),
                            Container(child: Text("Profile picture"),),
                            Padding(padding: EdgeInsets.only(top: 30),),

                            GestureDetector(
                              child: Hero(tag: 'displayPicture', child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: _iniDisplayPictureUrl != null ?
                                CachedNetworkImageProvider(_iniDisplayPictureUrl):AssetImage('assets/blank_profile.png'),
                                maxRadius: 60,
                                minRadius: 50,
                              ),),
                              onTap: (){
                                displayDialog();
                              },
                            ),
                            Padding(padding: EdgeInsets.only(top: 30),),
                            Divider(
                              color: Colors.white,
                            ),
                            Container(
                              child: Text("Display name"),
                            ),
                            Padding(padding: EdgeInsets.only(top: 10),),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                initialValue: _iniDisplayName,
                                keyboardType: TextInputType.text,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                //validator: validateEmail,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.transparent,width: 5.0),
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                  contentPadding: EdgeInsets.all(15),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                      borderRadius: BorderRadius.circular(30)),
                                  hintStyle: TextStyle(color: Colors.white),
                                  hintText: 'Display name',),
                                showCursor: true,
                                enableSuggestions: true,
                                onChanged: (input){
                                  _displayNameFlag = true;
                                  _displayName = input;
                                },
                                onTap: (){},
                                onSaved: (input) {
                                  _displayNameFlag = true;
                                  _displayName = input;
                                },
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.left,

                              ),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Container(
                              child: Text("EMail"),
                            ),
                            Padding(padding: EdgeInsets.only(top: 10),),
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: TextFormField(
                                initialValue: _iniEmailId,
                                keyboardType: TextInputType.text,
                                cursorColor: Colors.white,
                                style: TextStyle(color: Colors.white),
                                //validator: validateEmail,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.transparent,width: 5.0),
                                      borderRadius:
                                      BorderRadius.circular(30)),
                                  contentPadding: EdgeInsets.all(15),
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent,width: 0.0),
                                      borderRadius: BorderRadius.circular(30)),
                                  hintStyle: TextStyle(color: Colors.white),
                                  hintText: 'EMail',),
                                showCursor: true,
                                enableSuggestions: true,
                                onTap: (){},
                                onChanged: (input){
                                  _emailFlag = true;
                                  _email = input;
                                },
                                onSaved: (input) {
                                  _emailFlag = true;
                                  _email = input;
                                },
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }

  displayDialog(){
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.only(top: 250),
            child: Center(
              child: Column(
                children: <Widget>[
                  RaisedButton.icon(
                      shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      onPressed: (){
                        getImage(ImageSource.gallery);
                      },
                      icon: Icon(Icons.photo_album),color: Colors.grey, label: Text("From your device's gallery")
                  ),
                  Padding(padding: EdgeInsets.only(top:10)),
                  RaisedButton.icon(
                      shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)
                      ),
                      onPressed: (){
                        getImage(ImageSource.camera);
                      },
                      icon: Icon(Icons.camera_alt),color: Colors.grey, label: Text("Take a new photo")),
                ],
              ),
            ),
          );
        });
  }
}