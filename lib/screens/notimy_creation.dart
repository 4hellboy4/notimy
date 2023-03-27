import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:provider_ex1/common/text_Styles.dart';
import 'package:provider_ex1/providers/provider_notimy.dart';
import 'package:provider_ex1/screens/screen_of_notimies.dart';

import '../common/text_Styles.dart';

class SecondScreenwq extends StatefulWidget {
  String NotName;
  String userId;
  int chis;
  SecondScreenwq(
      {Key? key,
      required this.NotName,
      required this.chis,
      required this.userId})
      : super(key: key);
  @override
  _SecondScreenState createState() =>
      _SecondScreenState(nameNot: NotName, ownStat: chis, usersId: userId);
}

class _SecondScreenState extends State<SecondScreenwq> {
  String usersId;
  String nameNot;
  int ownStat;
  _SecondScreenState(
      {required this.nameNot, required this.ownStat, required this.usersId});

  final formKey = GlobalKey<FormState>();
  bool hasInternet = false;
  final TextEditingController commentTextEditingController =
      TextEditingController();
  final TextEditingController fieldTextEditingController =
      TextEditingController();

  final db = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser!;

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
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text(
          'Создание Notimy',
          style: TextStyle(
            color: Color(0xFF00D26E),
          ),
        ),
      ),
      backgroundColor: const Color(0xFF3B3B3B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _magnifyingGlassIcon(),
            _Container(nameNot: nameNot),
            const SizedBox(height: 5.0),
            _nameTextField(
                fieldTextEditingController: fieldTextEditingController),
            const SizedBox(height: 5.0),
            _commentTextField(
                commentTextEditingController: commentTextEditingController),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 130.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF00D26E)),
                  child: Text('Создать', style: sizeTextBlack()),
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
                      if (ownStat == 1) {
                        db.collection('users').doc(currentUser!.uid).set({
                          "usersNotimy": {
                            '$nameNot': {
                              'status': 'loading',
                              'ownStatus': 1,
                              'id': usersId
                            }
                          }
                        }, SetOptions(merge: true));
                        db.collection('users').doc(currentUser!.uid).update({
                          'creatingProcess': 0,
                          'whocreate': '',
                          'Name': ''
                        });
                      } else {
                        db.collection('users').doc(currentUser!.uid).set({
                          "usersNotimy": {
                            '$nameNot': {
                              'status': 'loading',
                              'ownStatus': 0,
                              'id': usersId
                            }
                          }
                        }, SetOptions(merge: true));
                        db.collection('users').doc(currentUser!.uid).update({
                          'creatingProcess': 0,
                          'whocreate': '',
                          'Name': ''
                        });
                      }
                      generationFunc();
                      Provider.of<ListNotimies>(context, listen: false)
                          .addNotyInList(fieldTextEditingController.text,
                              nameNot, commentTextEditingController.text);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ScreenPageThree()));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Container extends StatelessWidget {
  const _Container({
    Key? key,
    required this.nameNot,
  }) : super(key: key);

  final String nameNot;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.0,
      width: 240.0,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1D),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0),
        ),
      ),
      child: Text(
        nameNot,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xB6FFFFFF), fontSize: 20),
      ),
    );
  }
}

class _magnifyingGlassIcon extends StatelessWidget {
  const _magnifyingGlassIcon({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.connect_without_contact_rounded,
      color: Color(0xFF00D26E),
      size: 134,
    );
  }
}

class _commentTextField extends StatelessWidget {
  const _commentTextField({
    Key? key,
    required this.commentTextEditingController,
  }) : super(key: key);

  final TextEditingController commentTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: 240.0,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1D),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0), //                 <--- border radius here
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: TextFormField(
          controller: commentTextEditingController,
          textAlign: TextAlign.left,
          decoration: const InputDecoration.collapsed(
              hintText: 'Введите комментарий',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Color(0xB6FFFFFF), fontSize: 20)),
          keyboardType: TextInputType.emailAddress,
          maxLines: 7,
          style: const TextStyle(color: Color(0xB6FFFFFF), fontSize: 20),
        ),
      ),
    );
  }
}

class _nameTextField extends StatelessWidget {
  const _nameTextField({
    Key? key,
    required this.fieldTextEditingController,
  }) : super(key: key);

  final TextEditingController fieldTextEditingController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 240.0,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1D1D),
        borderRadius: BorderRadius.all(
          Radius.circular(16.0), //                 <--- border radius here
        ),
      ),
      child: TextFormField(
        controller: fieldTextEditingController,
        textAlign: TextAlign.center,
        decoration: const InputDecoration.collapsed(
            hintText: 'Введите название',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Color(0xB6FFFFFF), fontSize: 20)),
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Color(0xB6FFFFFF), fontSize: 20),
      ),
    );
  }
}
