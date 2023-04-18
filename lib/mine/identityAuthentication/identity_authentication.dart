import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/src/size_extension.dart';

import 'package:get/get.dart';

class IdentityAuthenticationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationController>(
        IdentityAuthenticationController());
  }
}

class IdentityAuthenticationController extends GetxController {
  Map homeData = {};
  final _authData = Rx<Map>({});
  get authData => _authData.value;
  set authData(v) => _authData.value = v;

  final _authCertified = false.obs;
  get authCertified => _authCertified.value;
  set authCertified(v) => _authCertified.value = v;

  final _authAlipay = false.obs;
  get authAlipay => _authAlipay.value;
  set authAlipay(v) => _authAlipay.value = v;

  @override
  void onInit() {
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    getHomeData();
    super.onInit();
  }

  getHomeDataNotify(arg) {
    getHomeData();
  }

  getHomeData() {
    homeData = AppDefault().homeData;
    if (homeData.isNotEmpty) {
      authData = homeData["authentication"];
      authCertified = authData["isCertified"];
      authAlipay = authData["isAliPay"];
      update();
    }
  }

  @override
  void onReady() {
    if (!AppDefault().loginStatus) {
      popToLogin();
    }
    super.onReady();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onClose();
  }
}

class IdentityAuthentication extends GetView<IdentityAuthenticationController> {
  const IdentityAuthentication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar:
          getDefaultAppBar(context, "身份认证", blueBackground: true, white: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            gwb(375),
            ghb(16),
            GetBuilder<IdentityAuthenticationController>(
              builder: (_) {
                return authCell(0, context);
              },
            ),
            // ghb(24),
            // authCell(1, context),
          ],
        ),
      ),
    );
  }

  // 1. 身份证 2. 支付宝
  Widget authCell(int type, BuildContext context) {
    bool isAuth =
        (type == 0 ? controller.authCertified : controller.authAlipay);
    String title = type == 0 ? "实名" : "支付宝";
    // isAuth = false;
    return CustomButton(
      onPressed: () {
        if (type == 0) {
          if (isAuth) {
            Get.to(
                const IdentityAuthenticationCheck(
                  isAlipay: false,
                ),
                binding: IdentityAuthenticationCheckBinding());
          } else {
            Get.to(const IdentityAuthenticationUpload(),
                binding: IdentityAuthenticationUploadBinding());
          }
        } else {
          checkIdentityAlert(
            toNext: () {
              if (isAuth) {
                Get.to(const IdentityAuthenticationCheck(isAlipay: true),
                    binding: IdentityAuthenticationCheckBinding());
              } else {
                Get.to(const IdentityAuthenticationAlipay(),
                    binding: IdentityAuthenticationAlipayBinding());
              }
            },
          );
        }
      },
      child: Container(
        width: 345.w,
        height: 120.w,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.w),
            boxShadow: [
              BoxShadow(
                  color: const Color(0x260059FF),
                  offset: Offset(0, 5.w),
                  blurRadius: 15.w)
            ]),
        child: Center(
            child: sbRow([
          centRow([
            gwb(16),
            centClm([
              getSimpleText("$title认证", 18,
                  AppDefault().getThemeColor() ?? const Color(0xFF0400FF),
                  fw: FontWeight.bold),
              ghb(4),
              getSimpleText("提交$title和信息进行认证", 15,
                  AppDefault().getThemeColor() ?? const Color(0xFF0400FF)),
              ghb(10),
              centRow([
                Image.asset(
                  assetsName(
                      "mine/authentication/icon_cell_${isAuth ? "auth" : "notauth"}"),
                  width: 16.w,
                  fit: BoxFit.fitWidth,
                ),
                gwb(4),
                getSimpleText("${isAuth ? "已" : "未"}认证", 16,
                    isAuth ? const Color(0xFF00BD42) : const Color(0xFFFF5500)),
                Image.asset(
                  assetsName(
                      "mine/authentication/icon_${isAuth ? "auth" : "noauth"}_arrow"),
                  height: 22.w,
                  fit: BoxFit.fitHeight,
                )
              ])
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ]),
          Image.asset(
            assetsName("mine/authentication/icon_authcell"),
            width: 135.w,
            fit: BoxFit.fitWidth,
          )
        ], width: 345)),
      ),
    );
  }

  Widget button(int isAuth, int status, {Function()? onPressed}) {
    return Container(
        width: 160.w,
        height: 250.w,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(-3.w, 3.w),
            blurRadius: 10.0.w,
            spreadRadius: 0,
          ),
        ], color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: Center(
          child: sbClm([
            centClm([
              ghb(34 - 26.5),
              getSimpleText(
                  isAuth == 0 ? "实名认证" : "支付宝认证", 20, AppColor.textBlack,
                  isBold: true),
              ghb(10),
              centRow([
                getSimpleText(
                    status == 0 ? "未认证" : "已认证",
                    18,
                    status == 0
                        ? const Color(0xFFFAC570)
                        : const Color(0xFF00C36A)),
                gwb(10),
                // Image.asset(assetsName(""))
              ])
            ], crossAxisAlignment: CrossAxisAlignment.start),
            CustomButton(
              onPressed: onPressed,
              child: Container(
                width: 120.w,
                height: 45.w,
                decoration: BoxDecoration(
                    color: AppColor.textBlack,
                    borderRadius: BorderRadius.circular(4.w)),
                child: Center(
                  child: getSimpleText(
                      status == 0 ? "去认证" : "查看信息", 18, Colors.white),
                ),
              ),
            ),
          ],
              height: 250 - 26.5 * 2,
              crossAxisAlignment: CrossAxisAlignment.start),
        ));
  }
}
