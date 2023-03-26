class NotyModel {
  String textField;
  String commentNoty;
  String userName;

  String get getTitle => textField;
  String get getUserName => userName;
  String get getComment => commentNoty;

  NotyModel(this.textField, this.userName, this.commentNoty);
}

