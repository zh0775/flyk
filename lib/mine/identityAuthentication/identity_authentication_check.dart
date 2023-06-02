import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IdentityAuthenticationCheckBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IdentityAuthenticationCheckController>(
        IdentityAuthenticationCheckController());
  }
}

class IdentityAuthenticationCheckController extends GetxController {
  bool isAlipay = false;
  bool isFirst = true;
  Map homeData = {};
  Map cardData = {};

  unBindAction() {
    // Get.offUntil(
    //     GetPageRoute(
    //       page: () => const WalletThirdBd(),
    //     ),
    //     (route) => route is GetPageRoute
    //         ? route.binding is ReceiptSettingBinding
    //             ? true
    //             : false
    //         : false);
  }

  dataInit(bool isAli) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    isAlipay = isAli;
    homeData = AppDefault().homeData;
    if (homeData == null ||
        homeData.isEmpty ||
        homeData["authentication"] == null ||
        homeData["authentication"].isEmpty) {
      return;
    }
    Map authData = homeData["authentication"];
    if (isAlipay) {
      cardData = {
        "name": authData["user_OnlinePay_Name"] ?? "",
        "number": authData["user_OnlinePay_Account"] ?? ""
      };
    } else {
      cardData = {
        "name": authData["u_Name"] ?? "",
        "number": authData["u_IdCard"] ?? ""
      };
    }
    update();
  }

  // 是否实名认证
  bool isAuth = false;
  // 是否支付宝提现认证
  bool isAlipayCert = false;
  // 是否银行卡提现认证
  bool isBankCert = false;

  homeDataNotify(arg) {
    dataFormat();
    update();
  }

  dataFormat() {
    Map authData = AppDefault().homeData["authentication"] ?? {};
    isAuth = authData["isCertified"] ?? false;
    isAlipayCert = authData["isAliPay"] ?? false;
    isBankCert = authData["isBank"] ?? false;
  }

  @override
  void onInit() {
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class IdentityAuthenticationCheck
    extends GetView<IdentityAuthenticationCheckController> {
  final bool isAlipay;
  const IdentityAuthenticationCheck({Key? key, this.isAlipay = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(isAlipay);

    return Scaffold(
        backgroundColor: (isAlipay && !controller.isAlipayCert) ||
                (!isAlipay && !controller.isAuth)
            ? Colors.white
            : AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(
            context,
            isAlipay
                ? controller.isAlipayCert
                    ? "支付宝认证信息"
                    : "提现认证"
                : controller.isAuth
                    ? "认证详情"
                    : "实名认证"),
        body: GetBuilder<IdentityAuthenticationCheckController>(
          builder: (_) {
            return (isAlipay && !controller.isAlipayCert) ||
                    (!isAlipay && !controller.isAuth)
                ? waitApplyView()
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: isAlipay
                          ? [
                              ghb(1),
                              UnconstrainedBox(
                                child: Container(
                                  color: Colors.white,
                                  width: 375.w,
                                  child: Column(
                                    children: [
                                      gwb(375),
                                      ghb(45),
                                      Image.asset(
                                        assetsName("mine/wallet/icon_alipay"),
                                        width: 82.5.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      ghb(19),
                                      getSimpleText(
                                          controller.cardData["number"] ?? "",
                                          14,
                                          AppColor.textGrey),
                                      ghb(9),
                                      getSimpleText(
                                          "已绑定支付宝账号", 15, AppColor.textBlack),
                                      ghb(40),
                                      getSubmitBtn("更换绑定", () {
                                        push(
                                            const IdentityAuthenticationAlipay(
                                              isAdd: false,
                                            ),
                                            null,
                                            binding:
                                                IdentityAuthenticationAlipayBinding());
                                      },
                                          height: 40,
                                          color: AppColor.theme,
                                          fontSize: 15),
                                      ghb(31.5)
                                    ],
                                  ),
                                ),
                              )
                            ]
                          : idCardAuthView(),
                    ),
                  );
          },
        ));
  }

  List<Widget> idCardAuthView() {
    return [
      ghb(1),
      Container(
        color: Colors.white,
        width: 375.w,
        child: Column(
          children: [
            gwb(375),
            ghb(35),
            Image.asset(assetsName("common/bg_auth_success"),
                width: 143.w, fit: BoxFit.fitWidth),
            ghb(35),
            ...List.generate(4, (index) {
              String t1 = "";
              String t2 = "";
              switch (index) {
                case 0:
                  t1 = "认证状态";
                  t2 = "已认证";
                  break;
                case 1:
                  t1 = "真实姓名";
                  t2 = controller.cardData["name"] ?? "";
                  if (t2.length >= 2) {
                    t2 = t2.replaceRange(1, 2, "*");
                  }
                  break;
                case 2:
                  t1 = "证件类型";
                  t2 = "身份证";
                  break;
                case 3:
                  t1 = "证件号码";
                  t2 = controller.cardData["number"] ?? "";
                  break;
              }

              return sbhRow([
                Padding(
                  padding: EdgeInsets.only(left: 5.w),
                  child: getSimpleText(t1, 14, AppColor.textGrey),
                ),
                index == 0
                    ? Container(
                        height: 20.w,
                        padding: EdgeInsets.symmetric(horizontal: 6.5.w),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color(0xFFE0F9E3),
                            borderRadius: BorderRadius.circular(3.w)),
                        child: getSimpleText(t2, 14, const Color(0xFF66AE5A)),
                      )
                    : Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: getSimpleText(t2, 14, AppColor.textBlack),
                      ),
              ], width: 375 - 15 * 2, height: 38);
            }),
            ghb(35),
          ],
        ),
      )
    ];
  }

  Widget waitApplyView() {
    return Stack(
      children: [
        Positioned.fill(
            bottom:
                85.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  gline(375, 0.5),
                  ghb(56),
                  Image.asset(
                    assetsName("mine/authentication/bg_needauth_alert"),
                    width: 180.w,
                    height: 180.w,
                    fit: BoxFit.fill,
                  ),
                  ghb(50),
                  getSimpleText(isAlipay ? "请绑定本人支付宝账号" : "请认证您的真实身份", 21,
                      AppColor.textBlack,
                      isBold: true),
                  ghb(15),
                  getWidthText(
                      isAlipay
                          ? "为保障您的账户安全，避免身份信息被盗用，提现前 请先完成实名认证，我们承诺保护您的信息安全"
                          : "为保障您的账户安全，避免身份信息被盗用，请认真 完成实名认证，我们承诺保护您的信息安全",
                      12,
                      AppColor.textGrey,
                      280,
                      5,
                      textHeight: 1.5)
                ],
              ),
            )),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height:
                85.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
            child: Column(
              children: [
                getSubmitBtn("马上认证", () {
                  if (isAlipay) {
                    push(const IdentityAuthenticationAlipay(), null,
                        binding: IdentityAuthenticationAlipayBinding());
                  } else {
                    push(const IdentityAuthenticationUpload(), null,
                        binding: IdentityAuthenticationUploadBinding());
                  }
                }, height: 45, color: AppColor.theme),
                SizedBox(
                  height: 40.w,
                  child: Center(
                    child: getSimpleText(isAlipay ? "需先完成实名认证后方可绑定" : "仅需要2分钟",
                        12, AppColor.textGrey),
                  ),
                )
              ],
            ))
      ],
    );
  }
}
