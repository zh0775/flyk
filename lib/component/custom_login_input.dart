import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CustomLoginInputType {
  userName,
  password,
  sendCode,
  recommend,
}

class CustomLoginInput extends StatefulWidget {
  final String? arg;
  final bool sendCode;
  final Map? source;
  final String placeholder;
  final int? maxLength;
  final TextInputType? textInputType;
  final CustomLoginInputController controller;
  final CustomLoginInputType type;
  final Widget? rightWidget;
  final double? rightWidgetWidth;
  final TextStyle? style;
  final TextStyle? placeholderStyle;
  final String? defalutValue;
  final int customStyle;
  const CustomLoginInput(
      {super.key,
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
      this.defalutValue,
      this.customStyle = 0,
      this.type = CustomLoginInputType.userName});

  @override
  State<CustomLoginInput> createState() => _CustomLoginInputState();
}

class _CustomLoginInputState extends State<CustomLoginInput> {
  TextEditingController textCtrl = TextEditingController();
  FocusNode node = FocusNode();
  bool hasFocus = false;

  bool hasClean = false;

  bool showValue = true;

  double width = 335;
  double height = 52;
  double inputWidth = 0;
  double imageWidth = 8 + 38 + 11;
  double sendButtonWidth = 119;
  double cleanOrPwdWidth = 44;
  String errorText = "";
  String img = "";
  @override
  void initState() {
    if (widget.customStyle == 1) {
      width = 345;
      imageWidth = 12;
      height = 55;
    }

    if (widget.defalutValue != null && widget.defalutValue!.isNotEmpty) {
      textCtrl.text = widget.defalutValue!;
    }
    dataFormat();
    node.addListener(() {
      setState(() {
        hasFocus = node.hasFocus;
      });
    });
    widget.controller.addListener(customListener);
    textCtrlListener();
    textCtrl.addListener(textCtrlListener);

    super.initState();
  }

  dataFormat() {
    switch (widget.type) {
      case CustomLoginInputType.userName:
        img = "login/icon_input_phone";
        inputWidth =
            width - 2 - imageWidth - (hasClean ? cleanOrPwdWidth : 0) - 0.1;
        break;
      case CustomLoginInputType.sendCode:
        img = "login/icon_input_sendcode";
        inputWidth = width - 2 - imageWidth - sendButtonWidth - 0.1;
        break;
      case CustomLoginInputType.password:
        showValue = false;
        inputWidth = width - 2 - imageWidth - cleanOrPwdWidth - 0.1;
        img = "login/icon_input_pwd";
        break;
      case CustomLoginInputType.recommend:
        inputWidth =
            width - 2 - imageWidth - (hasClean ? cleanOrPwdWidth : 0) - 0.1;
        img = "login/icon_input_recommend";
        break;
      default:
    }
  }

  customListener() {
    setState(() {
      errorText = widget.controller.value;
    });
  }

  textCtrlListener() {
    if (widget.type == CustomLoginInputType.userName) {
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
      // if (textCtrl.text.isEmpty && widget.source![widget.arg].isNotEmpty) {
      //   textCtrl.text = widget.source![widget.arg];
      // } else {
      //   widget.source![widget.arg] = textCtrl.text;
      // }
      widget.source![widget.arg] = textCtrl.text;
    }
  }

  @override
  void didUpdateWidget(covariant CustomLoginInput oldWidget) {
    if (textCtrl.text.isEmpty &&
        widget.defalutValue != null &&
        widget.defalutValue!.isNotEmpty) {
      textCtrl.text = widget.defalutValue!;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.controller.removeListener(customListener);
    textCtrl.removeListener(textCtrlListener);
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
            height: height.w,
            decoration: BoxDecoration(
                color:
                    widget.customStyle == 0 ? Colors.white : Colors.transparent,
                borderRadius:
                    widget.customStyle == 0 ? BorderRadius.circular(8.w) : null,
                border: widget.customStyle == 0
                    ? Border.all(
                        width: 1.w,
                        color: hasFocus ? AppColor.theme : Colors.white)
                    : Border(
                        bottom: BorderSide(
                            width: 0.5.w, color: AppColor.lineColor))),
            child: Row(
              children: [
                Visibility(
                  visible: widget.customStyle != 0,
                  child: gwb(imageWidth),
                ),
                Visibility(
                    visible: widget.customStyle == 0,
                    child: centRow([
                      gwb(8),
                      Image.asset(
                        assetsName(img),
                        width: 38.w,
                        height: 38.w,
                        fit: BoxFit.fill,
                      ),
                      gwb(11),
                    ])),
                CustomInput(
                  textEditCtrl: textCtrl,
                  keyboardType: widget.textInputType,
                  maxLength: widget.maxLength,
                  placeholder: widget.placeholder,
                  showValue: showValue,
                  cursorHeight: 20.w,
                  placeholderStyle: widget.placeholderStyle ??
                      TextStyle(color: AppColor.textGrey, fontSize: 14.w),
                  style: widget.style ??
                      TextStyle(
                          color: const Color(0xFF060220),
                          fontSize: 18.w,
                          fontWeight: FontWeight.w500),
                  focusNode: node,
                  width: inputWidth.w,
                  heigth: 50.w,
                ),

                widget.type == CustomLoginInputType.password
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

                hasClean
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

                widget.type == CustomLoginInputType.sendCode &&
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
            : getSimpleText(errorText, 12, AppColor.theme.withOpacity(0.8))
      ],
    );
  }
}

class CustomLoginInputController<String> extends ChangeNotifier
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
