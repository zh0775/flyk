import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppSuccessResult extends StatelessWidget {
  final String title;
  final bool success;
  final String contentTitle;
  final String content;
  final List buttonTitles;
  final Function(int index)? onPressed;
  final Function()? backPressed;
  final bool orangeThame;
  const AppSuccessResult({
    super.key,
    this.title = "",
    this.success = true,
    this.contentTitle = "",
    this.content = "",
    this.onPressed,
    this.backPressed,
    this.orangeThame = false,
    this.buttonTitles = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, title,
          leading: defaultBackButton(
            context,
            backPressed: () {
              if (backPressed != null) {
                backPressed!();
              }
            },
          )),
      body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: EdgeInsets.only(top: 15.w),
            width: 345.w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ghb(35),
                gwb(345),
                Image.asset(
                  assetsName(
                      "machine/icon_result_${success ? "success" : "fail"}"),
                  width: 57.w,
                  fit: BoxFit.fitWidth,
                ),
                ghb(22),
                getSimpleText(contentTitle, 18, AppColor.text, isBold: true),
                ghb(50),
                sbRow(
                    List.generate(
                        buttonTitles.length,
                        (index) => CustomButton(
                              onPressed: () {
                                if (onPressed != null) {
                                  onPressed!(index);
                                }
                              },
                              child: Container(
                                width: 150.w,
                                height: 45.w,
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        width: 0.7.w,
                                        color: orangeThame
                                            ? AppColor.themeOrange
                                            : AppColor.theme),
                                    borderRadius:
                                        BorderRadius.circular(22.5.w)),
                                child: Center(
                                  child: getSimpleText(
                                      buttonTitles[index],
                                      15,
                                      orangeThame
                                          ? AppColor.themeOrange
                                          : AppColor.theme,
                                      textHeight: 1.3),
                                ),
                              ),
                            )),
                    width: 345 - 15 * 2),
                ghb(60)
              ],
            ),
          )),
    );
  }
}
