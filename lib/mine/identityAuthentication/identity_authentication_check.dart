import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
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
    Get.offUntil(
        GetPageRoute(
          page: () => const WalletThirdBd(),
        ),
        (route) => route is GetPageRoute
            ? route.binding is ReceiptSettingBinding
                ? true
                : false
            : false);
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
        appBar: getDefaultAppBar(context, isAlipay ? "支付宝认证信息" : "认证详情",
            action: !isAlipay
                ? null
                : [
                    CustomButton(
                      onPressed: () {
                        showAlert(
                          context,
                          "确定要解绑支付宝账户吗",
                          confirmOnPressed: () {
                            Navigator.pop(context);
                            controller.unBindAction();
                          },
                        );
                      },
                      child: SizedBox(
                        width: 60.w,
                        height: kToolbarHeight,
                        child: Align(
                          alignment: Alignment.center,
                          child: getSimpleText("解绑", 14, AppColor.text2),
                        ),
                      ),
                    )
                  ]),
        body: SingleChildScrollView(
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
                            getSimpleText(controller.cardData["number"] ?? "",
                                14, AppColor.text3),
                            ghb(9),
                            getSimpleText("已绑定支付宝账号", 15, AppColor.text2),
                            ghb(40),
                            getSubmitBtn("更换绑定", () {
                              push(
                                  const IdentityAuthenticationAlipay(
                                    isAdd: false,
                                  ),
                                  null,
                                  binding:
                                      IdentityAuthenticationAlipayBinding());
                            }, height: 40, color: AppColor.theme, fontSize: 15),
                            ghb(31.5)
                          ],
                        ),
                      ),
                    )
                  ]
                : idCardAuthView(),
          ),
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
            Image.asset(
              assetsName("common/bg_result_success"),
              width: 143.w,
              fit: BoxFit.fitWidth,
            ),
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
                  child: getSimpleText(t1, 14, AppColor.text3),
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
                        child: getSimpleText(t2, 14, AppColor.text2),
                      ),
              ], width: 375 - 15 * 2, height: 38);
            }),
            ghb(35),
          ],
        ),
      )
    ];
  }
}
