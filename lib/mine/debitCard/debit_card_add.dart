import 'dart:async';

import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/debitCard/debit_card_info.dart';
import 'package:cxhighversion2/mine/identityAuthentication/identity_authentication_success.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/bank_list.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DebitCardAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DebitCardAddController>(DebitCardAddController());
  }
}

class DebitCardAddController extends GetxController {
  final cardNoInputCtrl = TextEditingController();
  final bankNameInputCtrl = TextEditingController();
  final phoneInputCtrl = TextEditingController();

  final _bankName = "建设银行".obs;
  get bankName => _bankName.value;
  set bankName(v) => _bankName.value = v;

  String payPwd = "";

  BottomPayPassword? bottomPayPassword;
  Map authData = {};
  Map homeData = {};
  @override
  void onInit() {
    homeData = AppDefault().homeData;
    authData = homeData["authentication"] ?? {};
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataRefreshNotify);
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (pwd) {
        payPwd = pwd;
        addCardAction();
      },
    );
    cardNoInputCtrl.addListener(checkCardNoListener);
    super.onInit();
  }

  homeDataRefreshNotify(arg) {
    homeData = AppDefault().homeData;
    authData = homeData["authentication"] ?? {};
  }

  checkCardNoListener() {
    if (cardNoInputCtrl.text.isNotEmpty) {
      debounce(timeout: 1000, target: checkCardNoRequest);
    }
  }

  // userBankEditRequest(Map<String, dynamic> params,
  //     Function(bool success, dynamic json) success) {
  //   Http().doPost(
  //     Urls.userBankEdit,
  //     params,
  //     success: (json) {
  //       if (success != null) {
  //         success(true, json);
  //       } else {
  //         success(false, json);
  //       }
  //     },
  //     fail: (reason, code, json) {
  //       if (success != null) {
  //         success(false, json);
  //       }
  //     },
  //   );
  // }

  submitAction() {
    if (cardNoInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入银行卡号");
      return;
    }

    if (cardNoInputCtrl.text.length < 16 || cardNoInputCtrl.text.length > 20) {
      ShowToast.normal("银行卡号应为16到20位");
      return;
    }

    if (bankNameInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入开卡银行名称");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入预留手机号");
      return;
    }
    if (!isMobilePhoneNumber(phoneInputCtrl.text)) {
      ShowToast.normal("请输入正确的预留手机号");
      return;
    }
    if ((homeData["u_3rd_password"] == null ||
        homeData["u_3rd_password"].isEmpty)) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    bottomPayPassword?.show();
  }

  final Map<String, Timer> _funcDebounce = {};
  // 防抖
  void debounce({
    int timeout = 500,
    Function? target,
  }) {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }

  checkCardNoRequest() {
    // if (bankNameInputCtrl.text.isNotEmpty) return;
    otherRequest(
      path: Urls.cardNoCheck(cardNoInputCtrl.text),
      success: (success, json) {
        if (success) {
          Map data = json ?? "";
          if (data["validated"] != null &&
              data["validated"] &&
              data["bank"] != null &&
              data["bank"].isNotEmpty) {
            String bankName = BankList.bankList[data["bank"]] ?? "";
            if (bankName.isNotEmpty) {
              bankNameInputCtrl.text = bankName;
            }
          }
        }
      },
      after: () {},
    );
  }

  addCardAction() {
    if (cardNoInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入银行卡号");
      return;
    }

    if (cardNoInputCtrl.text.length < 16 || cardNoInputCtrl.text.length > 20) {
      ShowToast.normal("银行卡号应为16到20位");
      return;
    }

    if (bankNameInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入开卡银行名称");
      return;
    }
    if (phoneInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入预留手机号");
      return;
    }
    if (!isMobilePhoneNumber(phoneInputCtrl.text)) {
      ShowToast.normal("请输入正确的预留手机号");
      return;
    }

    if (payPwd.isEmpty) {
      ShowToast.normal("请输入支付密码");
      return;
    }
    if (payPwd.length < 6) {
      ShowToast.normal("请输入6位支付密码");
      return;
    }

    simpleRequest(
      url: Urls.bankAdd,
      params: {
        "bankAccountName": authData["u_Name"] ?? "",
        "bankAccountNumber": cardNoInputCtrl.text,
        "bankName": bankNameInputCtrl.text,
        "u_3nd_Pad": payPwd,
      },
      success: (success, json) {
        if (success) {
          // ShowToast.normal("绑定成功");
          Get.find<HomeController>().refreshHomeData();
          Future.delayed(const Duration(seconds: 1), () {
            Get.offUntil(
                GetPageRoute(
                    page: () => const DebitCardInfo(),
                    binding: DebitCardInfoBinding()),
                (route) => route is GetPageRoute
                    ? route.binding is ReceiptSettingBinding
                        ? true
                        : false
                    : false);

            // Get.to(
            //     IdentityAuthenticationSuccess(
            //       alipayNoAuth: false,
            //       title: "${isAdd ? "提交" : "修改"}成功",
            //       subTitle: "您的银行卡已${isAdd ? "提交" : "修改"}成功，平台已审批通过",
            //     ),
            //     binding: IdentityAuthenticationSuccessBinding());
          });
        }
      },
      after: () {},
    );

    // userBankEditRequest({
    //   "bankAccountName": nameInputCtrl.text,
    //   "bankAccountNumber": cardNoInputCtrl.text,
    //   "bankName": bankNameInputCtrl.text,
    //   "u_3nd_Pad": payPwd,
    //   // "bankMobile": "15300088668"
    // }, (success, json) {
    //   if (success) {
    //     ShowToast.normal("绑定成功");
    //     HomeController? homeController = Get.find<HomeController>();
    //     if (homeController != null) {
    //       homeController.homeOnRefresh();
    //     }
    //     Future.delayed(const Duration(seconds: 1), () {
    //       Get.to(
    //           const IdentityAuthenticationSuccess(
    //             alipayNoAuth: false,
    //             title: "提交成功",
    //             subTitle: "您的银行卡已提交成功，平台已审批通过",
    //           ),
    //           binding: IdentityAuthenticationSuccessBinding());
    //     });
    //     // Get.to(

    //     //     AppSuccessPage(
    //     //       contentText: "提交成功",
    //     //       subContentText: "您添加的银行卡信息已提交成功，平台已审批通过",
    //     //       buttons: [
    //     //         getSubmitBtn("返回个人中心", () {
    //     //           Get.until((route) {
    //     //             if (route is GetPageRoute) {
    //     //               if (route.binding is AppBinding) {
    //     //                 return true;
    //     //               } else {
    //     //                 return false;
    //     //               }
    //     //             } else {
    //     //               return false;
    //     //             }
    //     //           });
    //     //         }),
    //     //       ],
    //     //     ),
    //     //     binding: AppSuccessPageBinding());
    //   } else {}
    // });
  }

  // @override
  // void dispose() {
  //   cardNoInputCtrl.removeListener(checkCardNoListener);
  //   nameInputCtrl.dispose();
  //   cardNoInputCtrl.dispose();
  //   bankNameInputCtrl.dispose();
  //   phoneInputCtrl.dispose();
  //   super.dispose();
  // }
  bool isFirst = true;
  bool isAdd = false;
  dataInit(bool add) {
    if (!isFirst) return;
    isFirst = false;
    isAdd = add;
  }

  @override
  void onClose() {
    cardNoInputCtrl.removeListener(checkCardNoListener);
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataRefreshNotify);
    cardNoInputCtrl.dispose();
    bankNameInputCtrl.dispose();
    phoneInputCtrl.dispose();
    super.onClose();
  }
}

class DebitCardAdd extends GetView<DebitCardAddController> {
  final bool isAdd;
  const DebitCardAdd({Key? key, this.isAdd = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(isAdd);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(
          context,
          isAdd ? "添加银行卡" : "修改银行卡",
        ),
        body: getInputBodyNoBtn(
          context,
          marginTop: 0.w,
          contentColor: Colors.transparent,
          children: [
            sbhRow([getSimpleText("请确认绑定的支付宝账号与实名信息一致", 12, AppColor.text3)],
                width: 375 - 15 * 2, height: 34),
            Container(
              width: 375.w,
              color: Colors.white,
              child: Column(
                children: List.generate(
                    3,
                    (index) => index == 1
                        ? gline(345, 1)
                        : SizedBox(
                            height: 54.5.w,
                            child: Center(
                              child: Row(
                                children: [
                                  gwb(15),
                                  getWidthText(index == 0 ? "姓名" : "身份证号", 15,
                                      AppColor.text3, 90, 1),
                                  getWidthText(
                                      index == 0
                                          ? controller.authData["u_Name"] ?? ""
                                          : controller.authData["u_IdCard"] ??
                                              "",
                                      15,
                                      AppColor.text2,
                                      345 - 90 - 1,
                                      1),
                                ],
                              ),
                            ),
                          )),
              ),
            ),
            ghb(10),
            Container(
              color: Colors.white,
              child: centClm([
                gwb(375),
                Container(
                  width: 375.w,
                  height: 55.w,
                  color: Colors.white,
                  child: Center(
                      child: Row(
                    children: [
                      gwb(15),
                      getWidthText("储蓄卡号", 15, AppColor.text3, 90, 1),
                      CustomInput(
                        width: 345.w - 90.w,
                        heigth: 55.w,
                        placeholder: "请输入银行卡号",
                        textEditCtrl: controller.cardNoInputCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: AppColor.text,
                          fontSize: 15.w,
                        ),
                        placeholderStyle: TextStyle(
                          color: AppColor.assisText,
                          fontSize: 15.w,
                        ),
                      ),
                    ],
                  )),
                ),
                gline(345, 1),
                Container(
                  width: 375.w,
                  height: 55.w,
                  color: Colors.white,
                  child: Center(
                      child: Row(
                    children: [
                      gwb(15),
                      getWidthText("开户银行", 15, AppColor.text3, 90, 1),
                      CustomInput(
                        width: 345.w - 90.w,
                        heigth: 55.w,
                        placeholder: "所在银行",
                        textEditCtrl: controller.bankNameInputCtrl,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: AppColor.text,
                          fontSize: 15.w,
                        ),
                        placeholderStyle: TextStyle(
                          color: AppColor.assisText,
                          fontSize: 15.w,
                        ),
                      ),
                    ],
                  )),
                ),
                gline(345, 1),
                Container(
                  width: 375.w,
                  height: 55.w,
                  color: Colors.white,
                  child: Center(
                      child: Row(
                    children: [
                      gwb(15),
                      getWidthText("预留手机号", 15, AppColor.text3, 90, 1),
                      CustomInput(
                        width: 345.w - 90.w,
                        heigth: 55.w,
                        placeholder: "请输入银行预留手机号",
                        textEditCtrl: controller.phoneInputCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 11,
                        style: TextStyle(
                          color: AppColor.text,
                          fontSize: 15.w,
                        ),
                        placeholderStyle: TextStyle(
                          color: AppColor.assisText,
                          fontSize: 15.w,
                        ),
                      ),
                    ],
                  )),
                ),
              ]),
            ),
            ghb(31),
            getSubmitBtn("提交", () {
              controller.submitAction();
            }, height: 45, color: AppColor.theme),
          ],
          buttonHeight: 0,

          // getBottomBlueSubmitBtn(
          //   context,
          //   "提交",
          //   onPressed: () {
          //     if (controller.nameInputCtrl.text.isEmpty) {
          //       ShowToast.normal("请输入姓名");
          //       return;
          //     }
          //     if (controller.nameInputCtrl.text.length < 2 ||
          //         controller.nameInputCtrl.text.length > 8) {
          //       ShowToast.normal("姓名应为2到8位");
          //       return;
          //     }
          //     if (controller.cardNoInputCtrl.text.isEmpty) {
          //       ShowToast.normal("请输入银行卡号");
          //       return;
          //     }

          //     if (controller.cardNoInputCtrl.text.length < 16 ||
          //         controller.cardNoInputCtrl.text.length > 20) {
          //       ShowToast.normal("银行卡号应为16到20位");
          //       return;
          //     }

          //     if (controller.bankNameInputCtrl.text.isEmpty) {
          //       ShowToast.normal("请输入归属银行名称");
          //       return;
          //     }
          //     controller.bottomPayPassword?.show();
          //   },
          // )
        ),
      ),
    );
  }
}
