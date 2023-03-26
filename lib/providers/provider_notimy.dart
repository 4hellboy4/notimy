import 'package:flutter/material.dart';
import 'package:provider_ex1/providers/contModel.dart';

class ListNotimies extends ChangeNotifier{
  List<NotyModel> notimiesList = [];

  addNotyInList(FilTex, UsName, ComentNotimy){
    NotyModel notyModel = NotyModel(FilTex, UsName, ComentNotimy);
    notimiesList.add(notyModel);

    notifyListeners();
  }

  void remove(index) {
    notimiesList.remove(index);
    notifyListeners();
  }
}