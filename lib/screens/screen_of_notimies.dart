import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:provider_ex1/common/text_Styles.dart';
import 'package:provider_ex1/providers/provider_notimy.dart';
import 'package:provider_ex1/screens/home_page.dart';

class ScreenPageThree extends StatelessWidget {
  ScreenPageThree({Key? key}) : super(key: key);

  final db = FirebaseFirestore.instance;
  bool hasInternet = false;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF3B3B3B),
      appBar: _appBar(),
      body: Center(
        child: StreamBuilder<DocumentSnapshot<Map<String?, dynamic>>>(
          stream: db.collection('users').doc(currentUser!.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data?['usersNotimy'].length != 0) {
              var userItems = snapshot.data?.data();
              return Consumer<ListNotimies>(builder: (context, listdo, child) {
                return ListView.builder(
                    itemCount: listdo.notimiesList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          const SizedBox(height: 10.0),
                          Container(
                            width: 300.0,
                            height: 260,
                            child: Column(
                              children: [
                                Container(
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 3, bottom: 3),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                              listdo.notimiesList[index]
                                                  .textField,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20.0)),
                                        ),
                                        if (userItems?['usersNotimy'][listdo
                                                .notimiesList[index]
                                                .userName]?["ownStatus"] ==
                                            1)
                                          (Row(children: [
                                            Center(
                                              child: MaterialButton(
                                                minWidth: 1,
                                                shape: const CircleBorder(),
                                                color: const Color(0xFF52FF8A),
                                                onPressed: () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        var meUser = listdo
                                                            .notimiesList[index]
                                                            .userName;
                                                        return AlertDialog(
                                                          content: const Text(
                                                              'Вы хотите завершить Notimy?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  "Нет"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  "Да"),
                                                              onPressed:
                                                                  () async {
                                                                hasInternet =
                                                                    await InternetConnectionChecker()
                                                                        .hasConnection;
                                                                if (hasInternet ==
                                                                    false) {
                                                                  showSimpleNotification(
                                                                    const Text(
                                                                      'Интернет отсутсвтует',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                } else if (hasInternet ==
                                                                    true) {
                                                                  if (userItems?['usersNotimy'][listdo
                                                                          .notimiesList[
                                                                              index]
                                                                          .userName]?["status"] !=
                                                                      'cancelled') {
                                                                    db
                                                                        .collection(
                                                                            'users')
                                                                        .doc(currentUser!
                                                                            .uid)
                                                                        .get()
                                                                        .then(
                                                                            (value) {
                                                                      var secUserId =
                                                                          value.data()!['usersNotimy'][meUser]
                                                                              [
                                                                              'id'];
                                                                      db
                                                                          .collection(
                                                                              'users')
                                                                          .doc(
                                                                              secUserId)
                                                                          .set({
                                                                        'usersNotimy':
                                                                            {
                                                                          meUser:
                                                                              {
                                                                            'status':
                                                                                'completed'
                                                                          }
                                                                        }
                                                                      }, SetOptions(merge: true));
                                                                    });
                                                                  }
                                                                  db
                                                                      .collection(
                                                                          "users")
                                                                      .doc(currentUser!
                                                                          .uid)
                                                                      .update({
                                                                    'usersNotimy.$meUser':
                                                                        FieldValue
                                                                            .delete()
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  Provider.of<ListNotimies>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .remove(listdo
                                                                              .notimiesList[
                                                                          index]);
                                                                }
                                                                ;
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: MaterialButton(
                                                minWidth: 1,
                                                shape: const CircleBorder(),
                                                color: Colors.red,
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        var meUser = listdo
                                                            .notimiesList[index]
                                                            .userName;
                                                        return AlertDialog(
                                                          content: const Text(
                                                              'Вы хотите отменить Notimy?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  "Нет"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  "Да"),
                                                              onPressed:
                                                                  () async {
                                                                hasInternet =
                                                                    await InternetConnectionChecker()
                                                                        .hasConnection;
                                                                if (hasInternet ==
                                                                    false) {
                                                                  showSimpleNotification(
                                                                    const Text(
                                                                      'Интернет отсутсвтует',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                } else if (hasInternet ==
                                                                    true) {
                                                                  if (userItems?['usersNotimy'][listdo
                                                                          .notimiesList[
                                                                              index]
                                                                          .userName]?["status"] ==
                                                                      'loading') {
                                                                    db
                                                                        .collection(
                                                                            'users')
                                                                        .doc(currentUser!
                                                                            .uid)
                                                                        .get()
                                                                        .then(
                                                                            (value) {
                                                                      var secUserId =
                                                                          value.data()!['usersNotimy'][meUser]
                                                                              [
                                                                              'id'];
                                                                      db
                                                                          .collection(
                                                                              'users')
                                                                          .doc(
                                                                              secUserId)
                                                                          .set({
                                                                        'usersNotimy':
                                                                            {
                                                                          meUser:
                                                                              {
                                                                            'status':
                                                                                'cancelled'
                                                                          }
                                                                        }
                                                                      }, SetOptions(merge: true));
                                                                    });
                                                                  }
                                                                  db
                                                                      .collection(
                                                                          "users")
                                                                      .doc(currentUser!
                                                                          .uid)
                                                                      .update({
                                                                    'usersNotimy.$meUser':
                                                                        FieldValue
                                                                            .delete()
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  Provider.of<ListNotimies>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .remove(listdo
                                                                              .notimiesList[
                                                                          index]);
                                                                }
                                                                ;
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      });
                                                },
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ])),
                                        if (userItems?['usersNotimy'][listdo
                                                .notimiesList[index]
                                                .userName]?["ownStatus"] ==
                                            0)
                                          (Row(children: [
                                            const Center(
                                              child: MaterialButton(
                                                minWidth: 1,
                                                shape: CircleBorder(),
                                                color: Colors.grey,
                                                onPressed: null,
                                                child: Icon(
                                                  Icons.check_rounded,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Center(
                                              child: MaterialButton(
                                                minWidth: 1,
                                                shape: const CircleBorder(),
                                                color: Colors.red,
                                                onPressed: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      var meUser = listdo
                                                          .notimiesList[index]
                                                          .userName;
                                                      if (userItems?['usersNotimy']
                                                                  [listdo
                                                                      .notimiesList[
                                                                          index]
                                                                      .userName]
                                                              ["status"] ==
                                                          'cancelled') {
                                                        return AlertDialog(
                                                          content: Text(listdo
                                                                  .notimiesList[
                                                                      index]
                                                                  .userName +
                                                              ' отменил ваше Notimy. Вы хотите его удалить?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  "Нет"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  "Да"),
                                                              onPressed:
                                                                  () async {
                                                                hasInternet =
                                                                    await InternetConnectionChecker()
                                                                        .hasConnection;
                                                                if (hasInternet ==
                                                                    false) {
                                                                  showSimpleNotification(
                                                                    const Text(
                                                                      'Интернет отсутсвтует',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                } else if (hasInternet ==
                                                                    true) {
                                                                  db
                                                                      .collection(
                                                                          'users')
                                                                      .doc(currentUser!
                                                                          .uid)
                                                                      .update({
                                                                    'usersNotimy.$meUser':
                                                                        FieldValue
                                                                            .delete()
                                                                  });
                                                                  Provider.of<ListNotimies>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .remove(listdo
                                                                              .notimiesList[
                                                                          index]);
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      }
                                                      if (userItems?['usersNotimy']
                                                                  [listdo
                                                                      .notimiesList[
                                                                          index]
                                                                      .userName]
                                                              ["status"] ==
                                                          'loading') {
                                                        return AlertDialog(
                                                          content: const Text(
                                                              'Вы хотите отменить Notimy?'),
                                                          actions: [
                                                            TextButton(
                                                              child: const Text(
                                                                  "Нет"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text(
                                                                  "Да"),
                                                              onPressed:
                                                                  () async {
                                                                hasInternet =
                                                                    await InternetConnectionChecker()
                                                                        .hasConnection;
                                                                if (hasInternet ==
                                                                    false) {
                                                                  showSimpleNotification(
                                                                    const Text(
                                                                      'Интернет отсутсвтует',
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20),
                                                                    ),
                                                                    background:
                                                                        Colors
                                                                            .red,
                                                                  );
                                                                } else if (hasInternet ==
                                                                    true) {
                                                                  db
                                                                      .collection(
                                                                          'users')
                                                                      .doc(currentUser!
                                                                          .uid)
                                                                      .get()
                                                                      .then(
                                                                    (value) {
                                                                      var secUserId =
                                                                          value.data()!['usersNotimy'][meUser]
                                                                              [
                                                                              'id'];
                                                                      db
                                                                          .collection(
                                                                              'users')
                                                                          .doc(
                                                                              secUserId)
                                                                          .set({
                                                                        'usersNotimy':
                                                                            {
                                                                          meUser:
                                                                              {
                                                                            'status':
                                                                                'cancelled'
                                                                          }
                                                                        }
                                                                      }, SetOptions(merge: true));
                                                                    },
                                                                  );
                                                                  db
                                                                      .collection(
                                                                          "users")
                                                                      .doc(currentUser!
                                                                          .uid)
                                                                      .update({
                                                                    'usersNotimy.$meUser':
                                                                        FieldValue
                                                                            .delete()
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                  Provider.of<ListNotimies>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .remove(listdo
                                                                              .notimiesList[
                                                                          index]);
                                                                }
                                                              },
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                      return AlertDialog(
                                                        content: const Text(
                                                          'Вы хотите его закрыть?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            child: const Text(
                                                                "Нет"),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            },
                                                          ),
                                                          TextButton(
                                                            child: const Text(
                                                                "Да"),
                                                            onPressed:
                                                                () async {
                                                              hasInternet =
                                                                  await InternetConnectionChecker()
                                                                      .hasConnection;
                                                              if (hasInternet ==
                                                                  false) {
                                                                showSimpleNotification(
                                                                  const Text(
                                                                    'Интернет отсутсвтует',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                  background:
                                                                      Colors
                                                                          .red,
                                                                );
                                                              } else if (hasInternet ==
                                                                  true) {
                                                                db
                                                                    .collection(
                                                                        "users")
                                                                    .doc(currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  'usersNotimy.$meUser':
                                                                      FieldValue
                                                                          .delete()
                                                                });
                                                                Navigator.pop(
                                                                    context);
                                                                Provider.of<ListNotimies>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .remove(listdo
                                                                            .notimiesList[
                                                                        index]);
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.close_rounded,
                                                  size: 25,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          ])),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5, horizontal: 5),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 120,
                                            height: 27,
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    16.0), //                 <--- border radius here
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5),
                                              child: Text(
                                                listdo.notimiesList[index]
                                                    .userName,
                                                textAlign: TextAlign.start,
                                                style: sizeTextBlack(),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              alignment: Alignment.topLeft,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(16.0),
                                                ),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 5),
                                                child: Text(
                                                  listdo.notimiesList[index]
                                                      .commentNoty,
                                                  style: sizeTextBlack(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 7),
                                          Row(children: [
                                            Text(
                                              'Status: ',
                                              style: sizeTextWhite(),
                                            ),
                                            if (userItems!['usersNotimy'][listdo
                                                    .notimiesList[index]
                                                    .userName]?["status"] ==
                                                'cancelled')
                                              (Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      child: Text(
                                                        'cancelled',
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.red,
                                                  ),
                                                ],
                                              )),
                                            if (userItems['usersNotimy'][listdo
                                                    .notimiesList[index]
                                                    .userName]?["status"] ==
                                                'loading')
                                              (Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      child: Text(
                                                        'loading',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            if (userItems['usersNotimy'][listdo
                                                    .notimiesList[index]
                                                    .userName]?["status"] ==
                                                'completed')
                                              (Row(
                                                children: [
                                                  Container(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 5),
                                                      child: Text(
                                                        'completed',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          color:
                                                              Color(0xFF52FF8A),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.check_rounded,
                                                    color: Color(0xFF52FF8A),
                                                  ),
                                                ],
                                              )),
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: Text(
                                                  '',
                                                  style: sizeTextWhite(),
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                          //Siz
                        ],
                      );
                    });
              });
            }
            return const Center(
              child: Text('No Notimyies yet',
                  style: TextStyle(fontSize: 20, color: Color(0xFF1D1D1D))),
            );
          },
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            color: const Color(0xFF52FF8A),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            uidUser: '',
                          )));
            },
          );
        },
      ),
      backgroundColor: const Color(0xFF1D1D1D),
      centerTitle: true,
      title: const Text(
        'Ваши Notimyies',
        style: TextStyle(
          color: Color(0xFF52FF8A),
        ),
      ),
    );
  }
}
