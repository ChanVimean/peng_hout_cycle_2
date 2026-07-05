import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _navIndex = 0;
  int get navIndex => _navIndex;

  void setNavIndex(int index) {
    if (_navIndex == index) return;
    _navIndex = index;
    notifyListeners();
  }
}
