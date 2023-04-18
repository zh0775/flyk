import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_add.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_info.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_alipay.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_check.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_upload.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class DebitCardManagerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DebitCardManagerController>(DebitCardManagerController());
  }
}

class DebitCardManagerController extends GetxController {
  final _haveCard = false.obs;
  set haveCard(value) => _haveCard.value = value;
  get haveCard => _haveCard.value;

  final _authAlipay = false.obs;
  set authAlipay(value) => _authAlipay.value = value;
  get authAlipay => _authAlipay.value;

  final _authCertified = false.obs;
  set authCertified(value) => _authCertified.value = value;
  get authCertified => _authCertified.value;

  final _havePwd = false.obs;
  set havePwd(value) => _havePwd.value = value;
  get havePwd => _havePwd.value;

  final _name = "".obs;
  set name(value) => _name.value = value;
  get name => _name.value;

  final _bankAccountName = "".obs;
  set bankAccountName(value) => _bankAccountName.value = value;
  get bankAccountName => _bankAccountName.value;

  final _bankAccountNumber = "".obs;
  set bankAccountNumber(value) => _bankAccountNumber.value = value;
  get bankAccountNumber => _bankAccountNumber.value;

  final _showCardId = false.obs;
  get showCardId => _showCardId.value;
  set showCardId(v) => _showCardId.value = v;

  bool openAlipay = false;
  bool openBankCard = false;

  Map homeData = {};
  Map publicHomeData = {};
  Map bank = {};
  List payTypes = [];
  checkStatus() {
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;
    if (homeData.isNotEmpty) {
      bank = homeData["authentication"] ?? {};
      authAlipay = bank["isAliPay"] ?? false;
      authCertified = bank["isCertified"];
      haveCard = bank["isBank"] ?? false;
      havePwd = homeData["userHasU3rdPwd"] ?? false;
      Map drawInfo = publicHomeData["drawInfo"] ?? {};
      payTypes = drawInfo["draw_Account_PayType"] ?? [];
      for (var e in payTypes) {
        if (e["id"] == 2) {
          openAlipay = true;
        } else if (e["id"] == 1) {
          openBankCard = true;
        }
      }

      if (haveCard) {
        name = bank["bank_Name"];
        bankAccountName = bank["bank_AccountName"];
        bankAccountNumber = bank["bank_AccountNumber"];
      }
    }
    update();
  }

  @override
  void onInit() {
    checkStatus();
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeData);
    super.onInit();
  }

  getHomeData(arg) {
    checkStatus();
  }

  @override
  void onReady() {
    if (!AppDefault().loginStatus) {
      popToLogin();
    }
    if (!havePwd) {
      payAlert();
    }
    super.onReady();
  }

  payAlert() {
    showPayPwdWarn(
      closePress: () {
        popToUntil();
      },
      haveClose: true,
      popToRoot: false,
      untilToRoot: false,
      noSetBack: () {
        homeData = AppDefault().homeData;
        havePwd = homeData["userHasU3rdPwd"] ?? false;
        if (!havePwd) {
          Future.delayed(const Duration(milliseconds: 300), () => payAlert());
        }
      },
    );
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeData);
    super.onClose();
  }
}

class DebitCardManager extends GetView<DebitCardManagerController> {
  const DebitCardManager({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "提现认证",
            white: true, blueBackground: true),
        body: GetBuilder<DebitCardManagerController>(
            init: controller,
            builder: (_) {
              return getInputBodyNoBtn(
                context,
                buttonHeight: 0,
                build: (boxHeight, context) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        gwb(375),
                        ghb(16),
                        controller.openBankCard ? authCell(0, context) : ghb(0),
                        ghb(controller.openBankCard ? 24 : 0),
                        controller.openAlipay ? authCell(1, context) : ghb(0),
                      ],
                    ),
                  );
                },
              );
              // children: controller.haveCard
              //     ? [
              //         ghb(40),
              //         getSimpleText("已添加结算卡", 18, AppColor.textBlack,
              //             isBold: true),
              //         ghb(15),
              //         getSimpleText(
              //             "如想修改已绑定结算卡，请先删除结算卡重新添加", 14, AppColor.textGrey),
              //         ghb(40),
              //         SizedBox(
              //           width: 345.w,
              //           height: 256.w,
              //           child: Column(
              //             children: [
              //               Container(
              //                   width: 315.w,
              //                   height: 100,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.vertical(
              //                         top: Radius.circular(5.w)),
              //                     gradient: const LinearGradient(
              //                         begin: Alignment.centerLeft,
              //                         end: Alignment.bottomRight,
              //                         colors: [
              //                           Color(0xFF5BA3F7),
              //                           Color(0xFF4282EB),
              //                         ]),
              //                   ),
              //                   child: Center(
              //                     child: centClm([
              //                       sbRow([
              //                         getSimpleText(controller.name ?? "",
              //                             22, Colors.white,
              //                             isBold: true),
              //                       ], width: 315 - 28.5 * 2),
              //                       // ghb(8),
              //                       // sbRow([
              //                       //   getSimpleText("创建时间:", 13, Colors.white),
              //                       // ], width: 315 - 28.5 * 2),
              //                     ],
              //                         crossAxisAlignment:
              //                             CrossAxisAlignment.start),
              //                   )),
              //               Container(
              //                 width: 345.w,
              //                 height: 145.w,
              //                 decoration: getDefaultWhiteDec(),
              //                 child: Center(
              //                   child: centClm([
              //                     sbRow([
              //                       Container(
              //                         width: 30.5.w,
              //                         height: 24.5.w,
              //                         decoration: BoxDecoration(
              //                           color: Colors.yellow[700],
              //                           borderRadius:
              //                               BorderRadius.circular(8.w),
              //                         ),
              //                         child: Stack(
              //                           children: [
              //                             cardLine(
              //                                 left: true,
              //                                 horizontal: false,
              //                                 index: 0),
              //                             cardLine(
              //                                 left: true,
              //                                 horizontal: true,
              //                                 index: 1),
              //                             cardLine(
              //                                 left: true,
              //                                 horizontal: true,
              //                                 index: 2),
              //                             cardLine(
              //                                 left: true,
              //                                 horizontal: true,
              //                                 index: 3),
              //                             cardLine(
              //                                 left: false,
              //                                 horizontal: false,
              //                                 index: 0),
              //                             cardLine(
              //                                 left: false,
              //                                 horizontal: true,
              //                                 index: 1),
              //                             cardLine(
              //                                 left: false,
              //                                 horizontal: true,
              //                                 index: 2),
              //                             cardLine(
              //                                 left: false,
              //                                 horizontal: true,
              //                                 index: 3),
              //                           ],
              //                         ),
              //                       )
              //                     ], width: 345 - 18.5 * 2),
              //                     ghb(10),
              //                     sbRow([
              //                       getSimpleText(
              //                           "银行卡号", 17, AppColor.textBlack,
              //                           isBold: true),
              //                     ], width: 345 - 18.5 * 2),
              //                     ghb(10),
              //                     sbRow([
              //                       GetX<DebitCardManagerController>(
              //                           builder: (_) {
              //                         return getSimpleText(
              //                             controller.showCardId
              //                                 ? bankCardFormat(
              //                                     controller.bank[
              //                                         "bank_AccountNumber"])
              //                                 : "****  ****  ****  ****  ***",
              //                             21,
              //                             AppColor.textBlack,
              //                             isBold: true);
              //                       }),
              //                       GetX<DebitCardManagerController>(
              //                           init: controller,
              //                           builder: (_) {
              //                             return CustomButton(
              //                               onPressed: () {
              //                                 controller.showCardId =
              //                                     !controller.showCardId;
              //                               },
              //                               child: SizedBox(
              //                                 width: 30.w,
              //                                 height: 30.w,
              //                                 child: Center(
              //                                   child: Image.asset(
              //                                     assetsName(
              //                                         "login/icon_${controller.showCardId ? "showpwd" : "hidepwd"}"),
              //                                     height: 12.w,
              //                                     fit: BoxFit.fitHeight,
              //                                   ),
              //                                 ),
              //                               ),
              //                             );
              //                           })
              //                     ], width: 345 - 18.5 * 2),
              //                   ],
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.start),
              //                 ),
              //               )
              //             ],
              //           ),
              //         ),
              //       ]
              //     : [
              //         ghb(80),
              //         getSimpleText("当前还未添加结算卡", 18, AppColor.textBlack,
              //             isBold: true),
              //         ghb(20),
              //         controller.homeData.isNotEmpty &&
              //                 controller.homeData["authentication"]
              //                     ["isCertified"]
              //             ? const SizedBox()
              //             : getSimpleText(
              //                 "请先完成实名认证，再添加结算卡",
              //                 14,
              //                 AppColor.textGrey,
              //               ),
              //       ],
              // buttonHeight: 80.w + paddingSizeBottom(context),
              // submitBtn: getBottomBlueSubmitBtn(
              //   context,
              //   controller.haveCard ? "修改结算卡" : "添加结算卡",
              //   onPressed: () {
              //     if (controller.haveCard) {
              //       Get.to(
              //           const DebitCardAdd(
              //             isAdd: false,
              //           ),
              //           binding: DebitCardAddBinding());
              //     } else {
              //       Get.to(const DebitCardAdd(),
              //           binding: DebitCardAddBinding());
              //     }
              //   },
              // ));
            }));
  }

  // 0: 银行卡 1: 支付宝
  Widget authCell(int type, BuildContext context) {
    bool isAuth = (type == 0 ? controller.haveCard : controller.authAlipay);
    String title = type == 0 ? "银行卡" : "支付宝";
    // isAuth = false;
    return CustomButton(
      onPressed: () {
        if (type == 0) {
          if (isAuth) {
            push(const DebitCardInfo(), context,
                binding: DebitCardInfoBinding());
          } else {
            push(
                const DebitCardAdd(
                  isAdd: true,
                ),
                context,
                binding: DebitCardAddBinding());
          }
        } else {
          if (!controller.authCertified) {
            showAlert(
              context,
              "请先进行实名认证",
              confirmText: "去实名",
              confirmOnPressed: () {
                Get.back();
                Get.to(const IdentityAuthenticationUpload(),
                    binding: IdentityAuthenticationUploadBinding());
              },
            );
            return;
          }
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

  Positioned cardLine(
      {required bool left, required bool horizontal, required int index}) {
    double width = 30.5.w;
    double height = 24.5.w;
    double indexTop = (24.5 / 4).w - 0.3.w;
    double veX = 10.5.w;

    return Positioned(
        top: horizontal ? index * indexTop : 0,
        left: left ? (horizontal ? 0 : veX) : width - veX,
        height: horizontal ? 0.5 : height,
        width: horizontal ? veX : 0.5,
        child: gline(horizontal ? veX : 0.5, horizontal ? 0.5 : veX,
            color: Colors.white));
  }
}
