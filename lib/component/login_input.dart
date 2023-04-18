import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/authcode_button.dart';
import 'package:cxhighversion2/util/size_config.dart';

enum LoginInputType { phone, password, authcode, normal }

class LoginInput extends StatefulWidget {
  final LoginInputType? inputType;
  final Function(String str)? onEditingComplete;
  final String? placeholder;
  final bool? needBottomLine;
  final double? marginWithScreen;
  const LoginInput(
      {Key? key,
      this.inputType,
      this.onEditingComplete,
      this.placeholder = "",
      this.needBottomLine = true,
      this.marginWithScreen = 25})
      : super(key: key);

  @override
  State<LoginInput> createState() => _LoginInputState();
}

class _LoginInputState extends State<LoginInput> {
  double? widthScale;
  double? screenWidth;
  String? inputString;
  double buttonWidth = 10;
  bool showValue = false;

  @override
  void initState() {
    super.initState();
    if (widget.inputType == LoginInputType.authcode) {
      buttonWidth += 95;
    } else if (widget.inputType == LoginInputType.password) {
      buttonWidth += 25;
    } else {
      buttonWidth = 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    screenWidth = SizeConfig.screenWidth ?? 0;
    widthScale = SizeConfig.blockSizeHorizontal ?? 0;
    return Container(
        width: screenWidth! - widget.marginWithScreen! * 2,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  // color: Colors.red,
                  width:
                      screenWidth! - widget.marginWithScreen! * 2 - buttonWidth,
                  // padding: EdgeInsets.only(right: widthScale! * 1.5),
                  // decoration: BoxDecoration(
                  //   color: Color.fromRGBO(0, 0, 0, 0.1),
                  //   borderRadius: BorderRadius.circular(5),
                  // ),

                  alignment: Alignment.centerLeft,
                  constraints: BoxConstraints(
                      minHeight: 60,
                      maxWidth: screenWidth! -
                          widget.marginWithScreen! * 2 -
                          buttonWidth,
                      minWidth: 0),
                  child: CupertinoTextField(
                    keyboardType: widget.inputType == LoginInputType.phone ||
                            widget.inputType == LoginInputType.authcode
                        ? TextInputType.number
                        : TextInputType.text,
                    placeholderStyle:
                        const TextStyle(color: Color(0xFFBBBBBB), fontSize: 16),
                    obscureText: !showValue,
                    controller:
                        TextEditingController.fromValue(TextEditingValue(
                      text: inputString ?? '',
                      selection: TextSelection.fromPosition(TextPosition(
                          affinity: TextAffinity.downstream,
                          offset:
                              inputString != null ? inputString!.length : 0)),
                    )),
                    decoration: const BoxDecoration(color: Colors.transparent),
                    // padding: const EdgeInsets.symmetric(horizontal: 20),
                    // obscureText: true,
                    placeholder: widget.placeholder,
                    // clearButtonMode: OverlayVisibilityMode.always,
                    onChanged: (value) {
                      inputString = value;
                      // checkLogin();
                    },
                    onEditingComplete: () {
                      if (widget.onEditingComplete != null) {
                        widget.onEditingComplete!(inputString!);
                      }
                    },
                  ),
                ),
                widget.inputType == LoginInputType.password
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            showValue = !showValue;
                          });
                        },
                        child: Image.asset(showValue
                            ? "assets/images/login/icon_showpwd.png"
                            : "assets/images/login/icon_hidepwd.png"),
                      )
                    : const SizedBox(),
                widget.inputType == LoginInputType.authcode
                    ? Image.asset("assets/images/login/bg_splitline.png")
                    : const SizedBox(),
                widget.inputType == LoginInputType.authcode
                    ? AuthCodeButton()
                    : const SizedBox(),
              ],
            ),
            SizedBox(
              width: screenWidth! - widget.marginWithScreen! * 2,
              child: Image.asset(
                "assets/images/login/bg_bottomline.png",
                fit: BoxFit.fitWidth,
              ),
            ),
          ],
        ));
  }
}
