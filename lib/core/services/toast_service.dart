import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF1D7C59),
      textColor: Colors.white,
      fontSize: 14.0,
      webPosition: "top-center",
      webBgColor: "#1D7C59",
    );
  }

  void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFE9168B),
      textColor: Colors.white,
      fontSize: 14.0,
      webPosition: "top-center",
      webBgColor: "#E9168B",
    );
  }

  void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFF334C50),
      textColor: Colors.white,
      fontSize: 14.0,
      webPosition: "top-center",
      webBgColor: "#334C50",
    );
  }

  void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color(0xFFE65100),
      textColor: Colors.white,
      fontSize: 14.0,
      webPosition: "top-center",
      webBgColor: "#E65100",
    );
  }

  void showCustom({
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.TOP,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      timeInSecForIosWeb: 2,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14.0,
      webPosition: "top-center",
    );
  }
}
