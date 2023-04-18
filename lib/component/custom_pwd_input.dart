import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CustomPwdInputType {
  userName,
  password,
  sendCode,
  recommend,
}

class CustomPwdInput extends StatefulWidget {
  final String? arg;
  final bool sendCode;
  final Map? source;
  final String placeholder;
  final int? maxLength;
  final TextInputType? textInputType;
  final CustomPwdInputController controller;
  final CustomPwdInputType type;
  final Widget? rightWidget;
  final double? rightWidgetWidth;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final bool enable;
  final String text;

  const CustomPwdInput({
    super.key,
    this.arg,
    this.source,
    this.textInputType,
    this.maxLength,
    required this.controller,
    this.sendCode = false,
    this.placeholder = "",
    this.rightWidget,
    this.rightWidgetWidth,
    this.style,
    this.placeholderStyle,
    this.type = CustomPwdInputType.userName,
    this.enable = true,
    this.text = "",
  });

  @override
  State<CustomPwdInput> createState() => _CustomPwdInputState();
}

class _CustomPwdInputState extends State<CustomPwdInput> {
  TextEditingController textCtrl = TextEditingController();
  FocusNode node = FocusNode();
  bool hasFocus = false;

  bool hasClean = false;

  bool showValue = true;

  double width = 335;
  double inputWidth = 0;
  double imageWidth = 24 + 15 + 11;
  double sendButtonWidth = 119;
  double cleanOrPwdWidth = 44;

  String errorText = "";

  String img = "";

  @override
  void initState() {
    dataFormat();
    // node.addListener(() {
    //   setState(() {
    //     hasFocus = node.hasFocus;
    //   });
    // });
    widget.controller.addListener(() {
      setState(() {
        errorText = widget.controller.value;
      });
    });

    textCtrl.addListener(() {
      if (widget.type == CustomPwdInputType.userName) {
        if (textCtrl.text.isEmpty && hasClean) {
          hasClean = false;
          setState(() {
            dataFormat();
          });
        } else if (textCtrl.text.isNotEmpty && !hasClean) {
          hasClean = true;
          setState(() {
            dataFormat();
          });
        }
      }

      if (widget.arg != null && widget.source != null) {
        widget.source![widget.arg] = textCtrl.text;
      }
    });
    if (widget.enable && widget.text.isNotEmpty) {
      textCtrl.text = widget.text;
    }
    super.initState();
  }

  dataFormat() {
    switch (widget.type) {
      case CustomPwdInputType.userName:
        img = "mine/userinfo/icon_phone";
        inputWidth =
            width - 2 - imageWidth - (hasClean ? cleanOrPwdWidth : 0) - 0.1;
        break;
      case CustomPwdInputType.sendCode:
        img = "mine/userinfo/icon_sendcode";
        inputWidth = width - 2 - imageWidth - sendButtonWidth - 0.1;
        break;
      case CustomPwdInputType.password:
        showValue = false;
        inputWidth = width - 2 - imageWidth - cleanOrPwdWidth - 0.1;
        img = "mine/userinfo/icon_pwd";
        break;
      case CustomPwdInputType.recommend:
        inputWidth =
            width - 2 - imageWidth - (hasClean ? cleanOrPwdWidth : 0) - 0.1;
        img = "mine/userinfo/icon_userid";
        break;
      default:
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    textCtrl.removeListener(() {});
    textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: width.w,
            height: 52.w,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.w),
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x19C8C8C8),
                      offset: Offset(0, 4.w),
                      blurRadius: 8.w)
                ],
                border: Border.all(
                    width: 1.w,
                    color: hasFocus ? AppColor.theme : Colors.white)),
            child: Row(
              children: [
                gwb(24),
                Image.asset(
                  assetsName(img),
                  width: 15.w,
                  // height: 38.w,
                  fit: BoxFit.fitWidth,
                ),
                gwb(11),
                widget.enable
                    ? CustomInput(
                        textEditCtrl: textCtrl,
                        keyboardType: widget.textInputType,
                        maxLength: widget.maxLength,
                        placeholder: widget.placeholder,
                        showValue: showValue,
                        cursorHeight: 18.w,
                        placeholderStyle: widget.placeholderStyle ??
                            TextStyle(
                                color: const Color(0xFF919599), fontSize: 15.w),
                        style: widget.style ??
                            TextStyle(
                                color: AppColor.textBlack3,
                                fontSize: 18.w,
                                fontWeight: FontWeight.w500),
                        focusNode: node,
                        width: inputWidth.w,
                        heigth: 50.w,
                      )
                    : getSimpleText(widget.text, 15, const Color(0xFF919599)),

                widget.type == CustomPwdInputType.password
                    ? CustomButton(
                        onPressed: () {
                          setState(() {
                            showValue = !showValue;
                          });
                        },
                        child: SizedBox(
                          height: 50.w,
                          width: cleanOrPwdWidth.w,
                          child: Center(
                            child: Image.asset(
                              assetsName(
                                  "login/btn_input_pwd_${showValue ? "show" : "hide"}"),
                              width: 16.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      )
                    : gwb(0),

                hasClean && widget.enable
                    ? CustomButton(
                        onPressed: () {
                          textCtrl.text = "";
                        },
                        child: SizedBox(
                          height: 50.w,
                          width: cleanOrPwdWidth.w,
                          child: Center(
                            child: Image.asset(
                              assetsName("login/input_clean"),
                              width: 16.w,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      )
                    : gwb(0),

                widget.type == CustomPwdInputType.sendCode &&
                        widget.rightWidget != null
                    ? centRow([gwb(10), widget.rightWidget!])
                    : gwb(0)
                // Visibility(
                //     visible:
                //     child: widget.rightWidget!)
              ],
            )),
        ghb(errorText.isEmpty ? 0 : 4),
        errorText.isEmpty
            ? ghb(0)
            : getSimpleText(errorText, 12, const Color(0xFF7BA4F7))
      ],
    );
  }
}

class CustomPwdInputController<String> extends ChangeNotifier
    implements ValueListenable<String> {
  String _errorValue = "" as String;

  @override
  String get value => _errorValue;

  set errorValue(String newValue) {
    if (_errorValue == newValue) return;
    _errorValue = newValue;
    notifyListeners();
  }

  void setErrorValueWithNoNotify(String newValue) {
    if (value == newValue) return;
    errorValue = newValue;
  }
}
