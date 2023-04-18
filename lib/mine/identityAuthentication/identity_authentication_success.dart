import 'package:cxhighversion2/main.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/app_binding.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class IdentityAuthenticationSuccessBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationSuccessController>(
        IdentityAuthenticationSuccessController());
  }
}

class IdentityAuthenticationSuccessController extends GetxController {}

class IdentityAuthenticationSuccess
    extends GetView<IdentityAuthenticationSuccessController> {
  final bool alipayNoAuth;
  final String title;
  final String subTitle;
  const IdentityAuthenticationSuccess(
      {Key? key,
      this.alipayNoAuth = true,
      this.title = "提交成功",
      required this.subTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(
        context,
        "",
        backPressed: () {
          Get.until((route) {
            if (route is GetPageRoute) {
              return (route.binding is MainPageBinding) ? true : false;
            } else {
              return false;
            }
          });
        },
      ),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 86.5.w + (alipayNoAuth ? (50 * 2 + 7.5).w : 50.w),
              child: Center(
                child: centClm([
                  Image.asset(
                    assetsName("common/bg_auth_success"),
                    width: 115.w,
                    // height: 98.5.w,
                    fit: BoxFit.fitWidth,
                  ),
                  ghb(55),
                  getSimpleText(title, 22, AppColor.textBlack, isBold: true),
                  ghb(18),
                  getSimpleText(subTitle, 14, AppColor.textGrey),
                ]),
              )),
          Positioned(
              bottom: 86.5.w,
              height: alipayNoAuth ? (50 * 2 + 7.5).w : 50.w,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  getSubmitBtn("返回首页", () {
                    Get.until((route) {
                      if (route is GetPageRoute) {
                        return (route.binding is MainPageBinding)
                            ? true
                            : false;
                      } else {
                        return false;
                      }
                    });
                  }),
                  ghb(alipayNoAuth ? 7.5 : 0),
                  alipayNoAuth
                      ? CustomButton(
                          onPressed: () {
                            Get.offUntil(
                                GetPageRoute(
                                  page: () =>
                                      const IdentityAuthenticationAlipay(),
                                  binding:
                                      IdentityAuthenticationAlipayBinding(),
                                ), (route) {
                              if (route is GetPageRoute) {
                                if (route.binding
                                    is IdentityAuthenticationBinding) {
                                  return true;
                                } else {
                                  return false;
                                }
                              } else {
                                return false;
                              }
                            });
                          },
                          child: Container(
                            width: 345.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25.w),
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x26333333),
                                      offset: Offset(0, 5.w),
                                      blurRadius: 15.w)
                                ]),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                    child: Center(
                                  child: getSimpleText(
                                      "绑定支付宝", 15, AppColor.textBlack,
                                      isBold: true),
                                )),
                                Padding(
                                  padding: EdgeInsets.only(right: 20.w),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      Icons.east_rounded,
                                      size: 25.w,
                                      color: AppColor.buttonTextBlue,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ))
        ],
      ),
    );
  }
}
