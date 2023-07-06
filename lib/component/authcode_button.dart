import 'dart:async';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum AuthCodeButtonState { countDown, again, first, sendAndWait }

class AuthCodeButton extends StatefulWidget {
  final Function()? sendCodeAction;
  final AuthCodeButtonState? buttonState;
  final Function()? countDownFinish;
  final double? width;
  final double? height;
  final int customStyle;

  final int? count;
  const AuthCodeButton(
      {Key? key, this.sendCodeAction, this.count = 60, this.buttonState, this.width, this.height, this.countDownFinish, this.customStyle = 0})
      : super(key: key);

  @override
  State<AuthCodeButton> createState() => _AuthCodeButtonState();
}

class _AuthCodeButtonState extends State<AuthCodeButton> {
  String buttonText = "";
  Timer? _timer;
  int count = 10;
  @override
  void initState() {
    count = widget.count ?? 10;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buttonState == AuthCodeButtonState.countDown && _timer == null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          count--;
          if (count == 0) {
            count = (widget.count ?? 10);
            _timer!.cancel();
            _timer = null;
            if (widget.countDownFinish != null) {
              widget.countDownFinish!();
            }
          }
        });
      });
    }

    return CustomButton(
      onPressed: widget.buttonState == AuthCodeButtonState.countDown || widget.buttonState == AuthCodeButtonState.sendAndWait
          ? null
          : () {
              if (widget.sendCodeAction != null) {
                widget.sendCodeAction!();
              }
              // if (buttonState != AuthCodeButtonState.countDown) {
              //   setState(() {
              //     buttonState = AuthCodeButtonState.countDown;
              //   });}
            },
      child: SizedBox(
        width: widget.width != null ? widget.width!.w : 108.w,
        height: widget.height != null ? widget.height!.w : 50.w,
        child: Center(
          child: Text(
            getButtonText(),
            style: getButtonTextStyle(),
          ),
        ),
      ),
    );
  }

  String getButtonText() {
    if (widget.buttonState != null) {
      switch (widget.buttonState!) {
        case AuthCodeButtonState.countDown:
          return "$count秒后再试";
        case AuthCodeButtonState.again:
          return "再次获取";
        case AuthCodeButtonState.first:
          return "获取验证码";
        case AuthCodeButtonState.sendAndWait:
          return "发送中";
      }
    } else {
      return "";
    }
  }

  TextStyle getButtonTextStyle() {
    if (widget.buttonState != null) {
      switch (widget.buttonState!) {
        case AuthCodeButtonState.sendAndWait:
        case AuthCodeButtonState.countDown:
          return TextStyle(color: widget.customStyle == 0 ? const Color(0xFFBBBBBB) : AppColor.theme, fontSize: 16.sp);
        case AuthCodeButtonState.again:
          return TextStyle(color: widget.customStyle == 0 ? const Color(0xFF4A4A4A) : AppColor.theme, fontSize: 16.sp, fontWeight: FontWeight.w500);
        case AuthCodeButtonState.first:
          return TextStyle(color: widget.customStyle == 0 ? const Color(0xFF4A4A4A) : AppColor.theme, fontSize: 16.sp, fontWeight: FontWeight.w500);
      }
    } else {
      return TextStyle(color: widget.customStyle == 0 ? const Color(0xFF4A4A4A) : AppColor.theme, fontSize: 16.sp);
    }
  }

  @override
  void dispose() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      _timer = null;
    }

    super.dispose();
  }
}
