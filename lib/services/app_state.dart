
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  Duration todayTotal = Duration.zero;

  void addToday(Duration d) {
    todayTotal += d;
    notifyListeners();
  }
}
