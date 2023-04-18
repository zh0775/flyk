import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentDataButton extends StatefulWidget {
  final bool? active;
  final String? title;
  final int? index;
  final Function(int idx)? onPressed;
  const RecentDataButton(
      {Key? key, this.index, this.active = false, this.onPressed, this.title})
      : super(key: key);

  @override
  State<RecentDataButton> createState() => _RecentDataButtonState();
}

class _RecentDataButtonState extends State<RecentDataButton> {
  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onPressed: () {
        if (widget.onPressed != null) {
          widget.onPressed!(widget.index ?? -1);
        }
      },
      child: Container(
        width: 75.w,
        height: 30.w,
        decoration: BoxDecoration(
            color: widget.active!
                ? const Color(0xFF3782FF)
                : const Color(0xFFF1F6FF),
            borderRadius: BorderRadius.circular(10.w)),
        child: Center(
            child: getSimpleText(widget.title ?? "", 14,
                widget.active! ? Colors.white : AppColor.textBlack)),
      ),
    );
  }
}
