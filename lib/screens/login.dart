import 'package:flutter/material.dart';
import 'package:spmconnectapp/API_Keys/keys.dart';
import 'package:spmconnectapp/aad_auth/aad_oauth.dart';
import 'package:spmconnectapp/aad_auth/model/config.dart';
import 'package:spmconnectapp/screens/home.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:async';

import 'package:spmconnectapp/utils/top_bar.dart';

class MyLoginPage extends StatefulWidget {
  MyLoginPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyLoginPageState createState() => new _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  String loggedin;
  initState() {
    super.initState();
  }

  static final Config config = new Config(
    Apikeys.tenantid,
    Apikeys.clientid,
    "openid profile offline_access",
    Apikeys.redirectUrl,
  );

  final AadOAuth oauth = AadOAuth(config);

  bool _saving = false;
  String accessToken;

  @override
  Widget build(BuildContext context) {
    // adjust window size for browser login
    var screenSize = MediaQuery.of(context).size;
    var rectSize =
        Rect.fromLTWH(0.0, 50.0, screenSize.width, screenSize.height - 25);
    oauth.setWebViewScreenSize(rectSize);
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: ModalProgressHUD(
        child: _loginitemsWidget(),
        inAsyncCall: _saving,
        color: Colors.orangeAccent,
      ),
    );
  }

  Widget _loginitemsWidget() {
    TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            const Color.fromRGBO(100, 145, 200, 0.6),
            const Color.fromRGBO(61, 80, 150, 1),
          ],
          stops: [0.2, 1.9],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.0, 1.5),
        ),
      ),
      child: Column(
        children: <Widget>[
          TopBar(),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                  child: Text('Hello',
                      style: TextStyle(
                          fontSize: 80.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54)),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                  child: Row(
                    children: <Widget>[
                      Text('There',
                          style: TextStyle(
                              fontSize: 80.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54)),
                      Text('.',
                          style: TextStyle(
                              fontSize: 80.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
              padding: EdgeInsets.fromLTRB(0, 30.0, 0, 0),
              width: 300.0,
              child: Column(
                children: <Widget>[
                  Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    color: Color(0xFF192A85),
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(0, 15.0, 0, 15.0),
                      onPressed: () async {
                        _saving = true;
                        await login();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: ImageIcon(
                              AssetImage('assets/officelogo.png'),
                              size: 35,
                              color: Colors.deepOrange,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text("Sign in with Office 365",
                              textAlign: TextAlign.center,
                              style: style.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  void showMessage(String text, bool login) {
    var alert = new AlertDialog(
        content: new Text(text),
        elevation: 10.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        actions: <Widget>[
          new FlatButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
                if (login) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Myhome(accessToken);
                  }));
                }
              })
        ]);
    showDialog(context: context, builder: (BuildContext context) => alert);
  }

  Future<void> login() async {
    try {
      setState(() {
        _saving = true;
      });
      await oauth.login();
      accessToken = await oauth.getAccessToken();
      //showMessage("Logged in successfully, your access token: $accessToken",true);
      //print("Logged in successfully, your access token: $accessToken");
      if (accessToken.length > 0) {
        new Future.delayed(new Duration(seconds: 1), () {
          setState(() {
            _saving = false;
            navigateToDetail();
          });
        });
      }

      //showMessage('Logged in successfully', true);
    } catch (e) {
      setState(() {
        _saving = false;
      });
      print(e);
    }
  }

  Future<void> logout() async {
    try {
      setState(() {
        _saving = true;
      });
      await oauth.logout();
      new Future.delayed(new Duration(seconds: 1), () {
        setState(() {
          _saving = false;
        });
      });
      //showMessage("Logged out", false);
    } catch (e) {
      print(e);
    }
  }

  void navigateToDetail() async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Myhome(accessToken);
    }));
  }
}
