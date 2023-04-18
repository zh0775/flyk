import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class AppSuccessPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<AppSuccessPageController>(AppSuccessPageController());
  }
}

class AppSuccessPageController extends GetxController {}

class AppSuccessPage extends GetView<AppSuccessPageController> {
  final List<Widget> buttons;
  final String? title;
  final String? contentText;
  final String? subContentText;
  const AppSuccessPage(
      {Key? key,
      this.buttons = const [],
      this.title = "",
      this.contentText,
      this.subContentText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double buttonHeight = 0;
    if (buttons.isNotEmpty) {
      buttonHeight += (50.w * buttons.length);
      if (buttons.length > 1) {
        buttonHeight += (7.w * (buttons.length - 1));
      }
    }

    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, title ?? ""),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 86.5.w + paddingSizeBottom(context) + buttonHeight,
              child: Align(
                alignment: const Alignment(0, -0.6),
                child: centClm([
                  Image.asset(
                    assetsName("common/bg_auth_success"),
                    width: 150.w,
                    // height: 98.5.w,
                    fit: BoxFit.fitWidth,
                  ),
                  ghb(20),
                  getSimpleText(contentText ?? "", 22, AppColor.textBlack,
                      isBold: true),
                  ghb(18),
                  getSimpleText(subContentText ?? "", 14, AppColor.textGrey),
                ]),
              )),
          Positioned(
              bottom: 86.5.w + paddingSizeBottom(context),
              height: buttonHeight,
              left: 0,
              right: 0,
              child: sbClm(
                  [if (buttons != null) ...buttons else const SizedBox()],
                  mainAxisAlignment: buttons != null && buttons.length > 1
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end))
        ],
      ),
    );
  }
}
