import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart';

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

    showToast(message,
        position: ToastPosition.center,
        // context: Global.navigatorKey.currentContext!,
        textStyle: TextStyle(fontSize: 12.sp, color: Colors.white, height: 1.3),
        textPadding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 12.w),
        radius: 25.w,
        dismissOtherToast: true,
        duration: const Duration(seconds: 2),
        backgroundColor: toastColor);
    // if (kIsWeb) {
    //   js.context.callMethod(
    //     "showToast",
    //     [
    //       message,
    //       "#333333",
    //       "center",
    //       "center",
    //       ScreenUtil().screenHeight / 2 - 50
    //     ],
    //   );
    // } else {
    //   Fluttertoast.showToast(
    //       msg: message,
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 1,
    //       backgroundColor: toastColor,
    //       textColor: Colors.white,
    //       fontSize: 12.sp);
    // }
  }
}
