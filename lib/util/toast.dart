import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:universal_html/js.dart' as js;

enum ToastType { normal, success, fail }

class ShowToast {
  static normal(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.normal);
    }
  }

  static success(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.success);
    }
  }

  static error(String? message) {
    if (message != null && message.isNotEmpty) {
      ShowToast.tt(message, ToastType.fail);
    }
  }

  static tt(String message, ToastType toastType) {
    Color toastColor;
    switch (toastType) {
      case ToastType.normal:
        toastColor = AppColor.textBlack;
        break;
      case ToastType.success:
        toastColor = const Color(0xff404351);
        break;
      case ToastType.fail:
        toastColor = const Color(0xff404351);
        break;
    }
    if (kIsWeb) {
      js.context.callMethod(
        "showToast",
        [
          message,
          "#333333",
          "center",
          "center",
          ScreenUtil().screenHeight / 2 - 50
        ],
      );
    } else {
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: toastColor,
          textColor: Colors.white,
          fontSize: 12.sp);
    }
  }
}
