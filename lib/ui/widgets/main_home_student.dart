import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:unilesson_admin/business/auth.dart';
import 'package:unilesson_admin/business/validator.dart';
import 'package:unilesson_admin/models/user.dart';
import 'package:unilesson_admin/ui/screens/search_screen.dart';
import 'package:unilesson_admin/ui/widgets/customHotCard.dart';
import 'package:unilesson_admin/ui/widgets/custom_alert_dialog.dart';

import 'custom_text_field.dart';

class MainHomeStudent extends StatefulWidget {
  final FirebaseUser user;

  MainHomeStudent(this.user);

  @override
  _MainHome createState() => new _MainHome();
}

class _MainHome extends State<MainHomeStudent> {
  final TextEditingController _search = new TextEditingController();
  CustomTextField _searchField;
  Stream<User> _userStream;
  Widget _home;


  @override
  void initState() {
    super.initState();
    _userStream = Auth.getUser(widget.user.uid);
    _searchField = new CustomTextField(
      baseColor: Colors.grey,
      borderColor: Colors.grey[400],
      errorColor: Colors.redAccent[700],
      controller: _search,
      hint: "Scrivi qualcosa",
      validator: Validator.validateName,
    );
  }

  // @override
  // void dispose() {
  //   //_search.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
     if (_home == null) {
      _home = _createHome(context);
    }
    return _home;
  }

  Widget _createHome(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;

    return StreamBuilder(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(212, 20, 15, 1.0),
                ),
              ),
            );
          } else {
            return new Container(
                padding: EdgeInsets.only(
                    top: _height / 20, left: _height / 20, right: _height / 20),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new CircleAvatar(
                      backgroundImage: (snapshot.data.profilePictureURL != '')
                          ? NetworkImage(snapshot.data.profilePictureURL)
                          : AssetImage("assets/img/face.png"),
                      radius: _height / 30,
                    ),
                    new SizedBox(
                      height: 30,
                    ),
                    new Text(
                      "Ciao " + snapshot.data.name + '.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    new SizedBox(
                      height: 20,
                    ),
                    new Text(
                      "Sembra che oggi sia la giornata giusta per studiare.",
                      style: TextStyle(fontSize: 15, color: Colors.black87),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 30.0, right: 0),
                        child: _searchField),
                    Padding(
                      padding: EdgeInsets.only(left: 5, top: 10.0),
                      child: buildSearchButton(_search, widget.user),
                    ),
                    CustomHotCard(snapshot.data.cdl),
                    new SizedBox(
                      height: 20,
                    ),
                  ],
                ));
          }
        });
  }

  Widget buildSearchButton(keyword, FirebaseUser user) => new FlatButton(
        onPressed: () {
          Validator.validateName(keyword.text)
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SearchScreen(keyword.text, user)))
              : _showDialog();
        },
        colorBrightness: Brightness.dark,
        color: Colors.redAccent[700],
        child: Text("Cerca"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      );

  Widget textField() => Padding(
      padding: EdgeInsets.only(top: 30.0, right: 0), child: _searchField);

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Attenzione!',
          content: 'Inserisci qualcosa prima di premere il tasto cerca.',
        );
      },
    );
  }
}
