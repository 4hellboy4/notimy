import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:provider_ex1/providers/provider_notimy.dart';
import 'package:provider_ex1/screens/generation_page.dart';
import 'package:provider_ex1/screens/notimy_creation.dart';
import 'package:provider_ex1/screens/screen_of_notimies.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.uidUser}) : super(key: key);
  String? uidUser;
  @override
  _MyHomePage createState() => _MyHomePage(userIdnone: uidUser);
}

class _MyHomePage extends State<MyHomePage> {
  _MyHomePage({required this.userIdnone});
  String? userIdnone;
  String? userId;
  bool hasInternet = false;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  final db = FirebaseFirestore.instance;
  var currentUser = FirebaseAuth.instance.currentUser;
  var userIdDoc;
  @override
  void initState() {
    super.initState();
    // getSnapshot();
    getSharePrefs();
  }

  void getSharePrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? currentUser?.uid;
    });
  }

  void findUser(String name, String? createrUser, int countPr) {
    db.collection('users').where('Name', isEqualTo: name).get().then((value) {
      value.docs.forEach((result) {
        String secondUserId = result.data()['docId'];
        db
            .collection('users')
            .doc(secondUserId)
            .update({'creatingProcess': countPr, 'whocreate': createrUser});
      });
    });
    db.collection('users').doc(userId).update({'whocreate': name});
  }

  Future simpleDialog(BuildContext context, String text) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(text),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1D1D1D),
        centerTitle: true,
        title: const Text(
          'Поиск',
          style: TextStyle(
            color: Color(0xFF00D26E),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil<dynamic>(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => generationPage(),
                ),
                (route) =>
                    false, //if you want to disable back feature set to false
              );
            },
            iconSize: 30,
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            color: const Color(0xFF00D26E),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF3B3B3B),
      body: StreamBuilder<DocumentSnapshot<Map<String?, dynamic>>>(
          stream: db.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var userItems = snapshot.data?.data();
              var secUserId = userItems?['secUserId'];
              var _textUs = userItems?['whocreate'];
              var _tittleName = userItems?['Name'];
              if (userItems?['creatingProcess'] == 1) {
                return AlertDialog(
                  title: Text("$_tittleName"),
                  content: const Text('Вам пришло приглашение'),
                  actions: [
                    TextButton(
                      child: const Text("Отменить"),
                      onPressed: () async {
                        hasInternet =
                            await InternetConnectionChecker().hasConnection;
                        if (hasInternet == false) {
                          showSimpleNotification(
                            const Text(
                              'Интернет отсутсвтует',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            background: Colors.red,
                          );
                        } else if (hasInternet == true) {
                          db
                              .collection('users')
                              .doc(secUserId)
                              .update({'creatingProcess': -1});
                          db
                              .collection('users')
                              .doc(userId)
                              .update({'creatingProcess': 0, 'whocreate': ''});
                          //Navigator.pop(context);
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => MyHomePage(
                                uidUser: '',
                              ),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        }
                        ;
                      },
                    ),
                    TextButton(
                      child: const Text("Принять"),
                      onPressed: () async {
                        hasInternet =
                            await InternetConnectionChecker().hasConnection;
                        if (hasInternet == false) {
                          showSimpleNotification(
                            const Text(
                              'Интернет отсутсвтует',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            background: Colors.red,
                          );
                        } else if (hasInternet == true) {
                          db
                              .collection('users')
                              .doc(secUserId)
                              .update({'creatingProcess': 2});
                          //db.collection('users').doc(currentUser!.uid).update({'creatingProcess': 0, 'whocreate': '', 'Name' : ''}); Важно
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => SecondScreenwq(
                                  NotName: _tittleName,
                                  chis: 0,
                                  userId: secUserId),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        }
                        ;
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => SecondScreenwq(NotName: _textUs, chis: 0)));
                      },
                    )
                  ],
                );
              }
              if (userItems?['creatingProcess'] == -1) {
                return AlertDialog(
                  title: Text("$_textUs"),
                  content: const Text('Приглашение не приняли'),
                  actions: [
                    TextButton(
                      child: const Text("Ok"),
                      onPressed: () async {
                        hasInternet =
                            await InternetConnectionChecker().hasConnection;
                        if (hasInternet == false) {
                          showSimpleNotification(
                            const Text(
                              'Интернет отсутсвтует',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            background: Colors.red,
                          );
                        } else if (hasInternet == true) {
                          db
                              .collection('users')
                              .doc(userId)
                              .update({'creatingProcess': 0, 'whocreate': ''});
                          Navigator.pushAndRemoveUntil<dynamic>(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  MyHomePage(uidUser: ''),
                            ),
                            (route) =>
                                false, //if you want to disable back feature set to false
                          );
                        }
                        ;
                      },
                    )
                  ],
                );
              }
              if (userItems?['creatingProcess'] == 2) {
                return AlertDialog(
                  title: Text("$_textUs"),
                  content: const Text('Приглашение принято'),
                  actions: [
                    TextButton(
                      child: const Text("Ok"),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil<dynamic>(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => SecondScreenwq(
                                NotName: _textUs, chis: 1, userId: secUserId),
                          ),
                          (route) =>
                              false, //if you want to disable back feature set to false
                        );
                      },
                    )
                  ],
                );
              }
            } else if (snapshot.hasError) {
              return Center(
                child: Container(
                  alignment: Alignment.center,
                  child: const Text('Возникла ошибка...',
                      style: TextStyle(fontSize: 24, color: Color(0xFF00D26E))),
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                child: Container(
                    alignment: Alignment.center,
                    height: 100,
                    width: 100,
                    child: const CircularProgressIndicator(
                      color: Color(0xFF00D26E),
                    )),
              ); //const CircularProgressIndicator()
            }
            return Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 180,
                      color: Color(0xFF1D1D1D),
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Container(
                        height: 50,
                        width: 260,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D1D1D),
                          borderRadius: BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: TextFormField(
                            controller: nameController,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration.collapsed(
                                hintText: 'Введите код',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                    color: Color(0xB6FFFFFF), fontSize: 20)),
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                                color: Color(0xB6FFFFFF), fontSize: 20),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Заполните поле';
                              } else if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Неверный код';
                              }
                              /*else if (db.collection('users').where('Name', isEqualTo: nameController.text)?.get().then((docs) => docs.size!>0)){
                                return 'Пользователь уже суще';
                              }*/
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 180.0,
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: const Color(0xFF00D26E)),
                        child: const Text(
                          'Найти',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          hasInternet =
                              await InternetConnectionChecker().hasConnection;
                          if (hasInternet == false) {
                            showSimpleNotification(
                              const Text(
                                'Интернет отсутсвтует',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              background: Colors.red,
                            );
                          } else if (_formKey.currentState!.validate() &&
                              hasInternet == true) {
                            db
                                .collection('users')
                                .where('Name', isEqualTo: nameController.text)
                                .get()
                                .then((value) {
                              if (value.size > 0) {
                                value.docs.forEach((result) {
                                  var secUser = result.data()['docId'];
                                  if (result.data()['whocreate'] == '') {
                                    db.collection('users').doc(secUser).set(
                                        {'secUserId': userId},
                                        SetOptions(merge: true));
                                    db.collection('users').doc(userId).set(
                                        {'secUserId': secUser},
                                        SetOptions(merge: true));
                                    findUser(nameController.text,
                                        snapshot.data?.data()?['Name'], 1);
                                    simpleDialog(context, 'Успешно отправлено');
                                    /*db.collection('users').doc(secUser).set({'secUserId' : model.getNickName}, SetOptions(merge:true));
                                    db.collection('users').doc(model.getNickName).set({'secUserId' : secUser}, SetOptions(merge: true));
                                    findUser(nameController.text, snapshot.data?.data()?['Name'], 1);
                                    simpleDialog(context, 'Успешно отправленно');*/
                                  } else if (result.data()['whocreate'] != '') {
                                    simpleDialog(context,
                                        'Пользователь в данный момент занят');
                                  }
                                });
                                /*findUser(nameController.text, snapshot.data?.data()?['Name'], 1);
                                simpleDialog(context, 'Успешно отправленно' );*/
                              } else {
                                simpleDialog(context, 'Пользователь не найден');
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.chat, size: 30, color: Color(0xFF1D1D1D)),
        backgroundColor: const Color(0xFF00D26E),
        onPressed: () {
          Navigator.pushAndRemoveUntil<dynamic>(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => ScreenPageThree(),
            ),
            (route) => false, //if you want to disable back feature set to false
          );
          //Navigator.push(context, MaterialPageRoute(builder: (context) => ScreenPageThree()));
        },
        elevation: 5,
        tooltip: 'Watch your Notimies',
      ),
    );
  }
}
