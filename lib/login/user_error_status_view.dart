import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserErrorStatusView extends StatelessWidget {
  final double boxHeight;
  final int errorCode;
  final Function()? toLogin;
  const UserErrorStatusView(
      {super.key, this.boxHeight = 0, this.errorCode = 0, this.toLogin});

  @override
  Widget build(BuildContext context) {
    String errorTitle = "";
    String errorImg = "";
    switch (errorCode) {
      case 201:
        errorTitle = "身份验证失败，请重新登录";
        errorImg = "common/icon_201";
        break;
      case 202:
        errorTitle = "身份信息已经过期，请重新登录";
        errorImg = "common/icon_201";
        break;
      case 203:
        errorTitle = "您的账号已在其他设备登录";
        errorImg = "common/icon_201";
        break;
      case 404:
        errorTitle = "抱歉，您要访问的页面不存在";
        errorImg = "common/icon_404";
        break;
    }
    return SizedBox(
      height: boxHeight,
      width: 375.w,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 185.w,
              height: 156.w,
              child: Image.asset(
                assetsName(errorImg),
                width: 185.w,
                fit: BoxFit.fitWidth,
              ),
            ),
            ghb(30),
            getSimpleText(errorTitle, 15, AppColor.textGrey5),
            ghb(33),
            CustomButton(
              onPressed: () {
                if (toLogin != null) {
                  toLogin!();
                }
              },
              child: Container(
                width: 120.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: (AppDefault().getThemeColor() ?? AppColor.theme),
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: Center(
                  child: getSimpleText("重新登录", 12, Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
