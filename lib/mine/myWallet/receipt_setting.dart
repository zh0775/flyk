import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_info.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../identityAuthentication/identity_authentication_alipay.dart';

class ReceiptSettingBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ReceiptSettingController>(
        ReceiptSettingController(datas: Get.arguments));
  }
}

class ReceiptSettingController extends GetxController {
  final dynamic datas;
  ReceiptSettingController({this.datas});
  Map homeData = {};
  Map publicHomeData = {};
  final _isAuth = false.obs;
  bool get isAuth => _isAuth.value;
  set isAuth(v) => _isAuth.value = v;
  bool havePwd = false;

  final _openBankCard = false.obs;
  bool get openBankCard => _openBankCard.value;
  set openBankCard(v) => _openBankCard.value = v;

  final _openAlipay = false.obs;
  bool get openAlipay => _openAlipay.value;
  set openAlipay(v) => _openAlipay.value = v;

  dataFormat() {
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;
    if (homeData.isNotEmpty) {
      isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;
      havePwd = homeData["userHasU3rdPwd"] ?? false;
      Map drawInfo = publicHomeData["drawInfo"] ?? {};
      List payTypes = drawInfo["draw_Account_PayType"] ?? [];
      for (var e in payTypes) {
        if (e["id"] == 2) {
          openAlipay = true;
        } else if (e["id"] == 1) {
          openBankCard = true;
        }
      }
    }
    openBankCard = true;
    openAlipay = true;
  }

  homeDataNotify(args) {
    dataFormat();
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

class ReceiptSetting extends GetView<ReceiptSettingController> {
  const ReceiptSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "收款设置"),
      body: Column(
        children: [
          ghb(6),
          GetX<ReceiptSettingController>(
            builder: (controller) {
              return controller.openBankCard ? cell(0) : ghb(0);
            },
          ),
          cell(1),
          GetX<ReceiptSettingController>(
            builder: (controller) {
              return controller.openAlipay ? cell(2) : ghb(0);
            },
          ),
        ],
      ),
    );
  }

  Widget cell(int type) {
    String title = "";
    switch (type) {
      case 0:
        title = "银行卡管理";
        break;
      case 1:
        title = "提现认证";
        break;
      case 2:
        title = "第三方账户绑定";
        break;
    }

    return CustomButton(
      onPressed: () {
        if (type == 0) {
          checkIdentityAlert(
            toNext: () {
              push(const DebitCardInfo(), null,
                  binding: DebitCardInfoBinding());
            },
          );

          // if (isAuth) {
          //     push(const DebitCardInfo(), context,
          //         binding: DebitCardInfoBinding());
          //   } else {
          //     push(
          //         const DebitCardAdd(
          //           isAdd: true,
          //         ),
          //         context,
          //         binding: DebitCardAddBinding());
          //   }
        } else if (type == 1) {
          if (controller.isAuth) {
            push(const IdentityAuthenticationCheck(isAlipay: false), null,
                binding: IdentityAuthenticationCheckBinding());
          } else {
            push(const IdentityAuthenticationUpload(), null,
                binding: IdentityAuthenticationUploadBinding());
          }
        } else if (type == 2) {
          checkIdentityAlert(
            toNext: () {
              push(const WalletThirdBd(), Global.navigatorKey.currentContext!,
                  setName: "WalletThirdBd");
            },
          );
        }
      },
      child: Align(
          child: Container(
        width: 375.w,
        height: 55.w,
        color: Colors.white,
        child: Center(
          child: sbhRow([
            centRow([
              gwb(6),
              getSimpleText(title, 15, AppColor.text2),
            ]),
            centRow([
              type == 1
                  ? GetX<ReceiptSettingController>(
                      builder: (_) {
                        return getSimpleText(controller.isAuth ? "已认证" : "未认证",
                            15, AppColor.text3);
                      },
                    )
                  : gwb(0),
              Image.asset(
                assetsName("statistics/icon_arrow_right_gray"),
                width: 18.w,
                fit: BoxFit.fitWidth,
              )
            ]),
          ], width: 375 - 24.5 * 2, height: 55),
        ),
      )),
    );
  }
}

class WalletThirdBd extends StatefulWidget {
  const WalletThirdBd({super.key});

  @override
  State<WalletThirdBd> createState() => _WalletThirdBdState();
}

class _WalletThirdBdState extends State<WalletThirdBd> {
  Map homeData = {};
  bool isAuth = false;

  dataFormat() {
    homeData = AppDefault().homeData;
    setState(() {
      isAuth = (homeData["authentication"] ?? {})["isAliPay"] ?? false;
    });
  }

  homeDataNotify(args) {
    dataFormat();
  }

  @override
  void initState() {
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.initState();
  }

  @override
  void dispose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "第三方账户绑定"),
      body: Column(
        children: [
          CustomButton(
            onPressed: () {
              if (isAuth) {
                Get.to(const IdentityAuthenticationCheck(isAlipay: true),
                    binding: IdentityAuthenticationCheckBinding());
              } else {
                Get.to(
                    const IdentityAuthenticationAlipay(
                      isAdd: true,
                    ),
                    binding: IdentityAuthenticationAlipayBinding());
              }
            },
            child: Align(
                child: Container(
              width: 375.w,
              height: 55.w,
              color: Colors.white,
              child: Center(
                child: sbhRow([
                  centRow([
                    gwb(6),
                    getSimpleText("支付宝", 15, AppColor.text2),
                  ]),
                  centRow([
                    getSimpleText(isAuth ? "已绑定" : "未绑定", 15, AppColor.text3),
                    Image.asset(
                      assetsName("statistics/icon_arrow_right_gray"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    )
                  ]),
                ], width: 375 - 24.5 * 2, height: 55),
              ),
            )),
          )
        ],
      ),
    );
  }
}
