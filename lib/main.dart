import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:provider_ex1/providers/provider_notimy.dart';
import 'package:provider_ex1/screens/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ListNotimies()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const CheckAuth(),
        ),
      ),
    );
  }
}

class CheckAuth extends StatefulWidget {
  const CheckAuth({Key? key}) : super(key: key);

  @override
  _CheckAuthState createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  bool? isLoggedIn;

  @override
  void initState() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        isLoggedIn = false;
      });
    } else {
      setState(() {
        isLoggedIn = true;
      });
    }
    super.initState();
    Future.delayed(const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn!
        ? MyHomePage(
      uidUser: '',
    )
        : annotationPage(); //REPLACE BEFORE
  }
}

class annotationPage extends StatefulWidget {
  @override
  _annotationPageState createState() => _annotationPageState();
}

class _annotationPageState extends State<annotationPage> {
  final db = FirebaseFirestore.instance;

  bool hasInternet = false;

  User? currentUser = FirebaseAuth.instance.currentUser;

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  Future<void> createUser(String IdUser) async {
    var chislCode = '';
    var random = Random();
    for (int i = 0; i < 6; i++) {
      int randomNumber = random.nextInt(10);
      chislCode = chislCode + '$randomNumber';
    }
    db
        .collection('users')
        .where('Name', isEqualTo: chislCode)
        .get()
        .then((value) {
      var resultLeng = value.docs.length;
      if (resultLeng > 0) {
        createUser(IdUser);
      } else {
        db.collection('users').doc(IdUser).set({
          'Name': chislCode,
          'docId': IdUser,
          'secUserId': '',
          "creatingProcess": 0,
          "whocreate": '',
          "usersNotimy": [],
        }, SetOptions(merge: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1D1D1D),
        centerTitle: true,
        title: const Text(
          'Notimy',
          style: TextStyle(
            color: Color(0xFF00D26E),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF3B3B3B),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('Добро пожаловать!',
                  style: TextStyle(
                    color: Color(0xFF00D26E),
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  )),
              Container(
                height: 1,
                color: const Color(0xFF00D26E),
              ),
              const SizedBox(height: 10),
              Container(
                width: 180.0,
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF00D26E)),
                  child: const Text('Начать',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      )),
                  onPressed: () async {
                    hasInternet =
                    await InternetConnectionChecker().hasConnection;
                    if (hasInternet == false) {
                      showSimpleNotification(
                        const Text(
                          'Интернет отсутсвтует',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        background: Colors.red,
                      );
                    } else if (hasInternet == true) {
                      UserCredential curUser =
                      await FirebaseAuth.instance.signInAnonymously();
                      createUser(curUser.user!.uid);
                      setSharePrefs(curUser.user!.uid);
                      Navigator.pushAndRemoveUntil<dynamic>(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              MyHomePage(uidUser: curUser.user!.uid),
                        ),
                            (route) =>
                        false, //if you want to disable back feature set to false
                      );

                      /*if (currentUser == null) {
                        UserCredential curUser = await FirebaseAuth.instance.signInAnonymously();
                        createUser(curUser.user!.uid);
                        print(currentUser);
                      }*/
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setSharePrefs(String val) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', val);
    setState(() {});
  }
}
