import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';

class UserConfirmView extends StatefulWidget {
  final bool? isStart;
  final bool? defaultCheck;
  final Function(bool value)? valueChange;
  const UserConfirmView({
    Key? key,
    this.isStart = true,
    this.defaultCheck = false,
    this.valueChange,
  }) : super(key: key);

  @override
  State<UserConfirmView> createState() => _UserConfirmViewState();
}

class _UserConfirmViewState extends State<UserConfirmView> {
  bool? check;
  @override
  void initState() {
    super.initState();
    check = widget.defaultCheck ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          widget.isStart! ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              check = !check!;
            });
            if (widget.valueChange != null) {
              widget.valueChange!(check!);
            }
          },
          child: Image.asset(check!
              ? "assets/images/login/btn_checkbox_active.png"
              : "assets/images/login/btn_checkbox_normal.png"),
        ),
        gwb(8),
        getSimpleText("我已阅读同意", 13, const Color(0xFFBBBBBB)),
        CustomButton(
          onPressed: () {},
          child: getSimpleText("《用户协议》", 13, const Color(0xFFDA5059)),
        ),
        getSimpleText("和", 13, const Color(0xFFBBBBBB)),
        CustomButton(
          onPressed: () {},
          child: getSimpleText("《隐私协议》", 13, const Color(0xFFDA5059)),
        ),
      ],
    );
  }
}
