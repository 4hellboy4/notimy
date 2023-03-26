import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';

import 'home_page.dart';

class generationPage extends StatefulWidget {
  @override
  _generationPageState createState() => _generationPageState();
}

class _generationPageState extends State<generationPage> {
  String prefCode = '';

  bool hasInternet = false;

  final db = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  generationFunc() {
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
        generationFunc();
      } else {
        db
            .collection('users')
            .doc(currentUser!.uid)
            .set({'Name': chislCode}, SetOptions(merge: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              iconSize: 30,
              color: const Color(0xFF00D26E), //0xFF52FF8A
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
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
              },
            );
          },
        ),
        backgroundColor: const Color(0xFF1D1D1D),
        centerTitle: true,
        title: const Text(
          'Генерация кода',
          style: TextStyle(
            color: Color(0xFF00D26E),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF3B3B3B),
      body: StreamBuilder<DocumentSnapshot<Map<dynamic, dynamic>>>(
          stream: db.collection('users').doc(currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            var userItems = snapshot.data?.data();
            if (snapshot.hasError) {
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
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.casino_rounded,
                  size: 180,
                  color: Color(0xFF1D1D1D),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Ваш код:',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        )),
                    const SizedBox(width: 10),
                    Text(userItems?['Name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ))
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  width: 180.0,
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: const Color(0xFF00D26E)),
                    child: const Text('Сгенерировать',
                        style:
                            TextStyle(color: Color(0xFFFFFFFF), fontSize: 20)),
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
                        generationFunc();
                      }
                      ;
                      //generationFunc();
                      //db.collection('users').doc(currentUser!.uid).update({'Name': prefCode});
                    },
                  ),
                )
              ],
            ));
          }),
    );
  }
}
