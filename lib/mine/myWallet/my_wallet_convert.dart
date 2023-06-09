import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_convert_history.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class MyWalletConvertBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletConvertController>(MyWalletConvertController());
  }
}

class MyWalletConvertController extends GetxController {
  TextEditingController inputCtrl = TextEditingController();
  final _submitBtnEnable = true.obs;
  bool get submitBtnEnable => _submitBtnEnable.value;
  set submitBtnEnable(v) => _submitBtnEnable.value = v;

  bool isFirst = true;

  late BottomPayPassword bottomPayPassword;

  // loadData() {
  //   simpleRequest(
  //     url: Urls.getInvestList,
  //     params: {},
  //     success: (success, json) {
  //       if (success) {
  //       } else {
  //         // Future.delayed(const Duration(milliseconds: 500), () {
  //         //   Get.back();
  //         // });
  //       }
  //     },
  //     after: () {},
  //   );
  // }

  convertRequest(String pwd) {
    submitBtnEnable = false;
    simpleRequest(
      url: Urls.investOrder,
      params: {
        "investConfigId": AppDefault().homeData["investConfigId"],
        "customAmount": double.tryParse(inputCtrl.text),
        "u_3nd_Pad": pwd,
      },
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().refreshHomeData();
          showAlert(Global.navigatorKey.currentContext!, "兑换金额已到账，可在“我的钱包”中查看",
              title: "兑换成功", singleButton: true);
          // Get.to(
          //     AppSuccessPage(
          //       title: "转换成功",
          //       subContentText: "恭喜转换红包成功",
          //       buttons: [
          //         getSubmitBtn("返回我的钱包", () {
          //           Get.until((route) {
          //             if (route is GetPageRoute) {
          //               if (fromEarn) {
          //                 return (route.binding is MainPageBinding)
          //                     ? true
          //                     : false;
          //               } else {
          //                 return (route.binding is MyWalletBinding)
          //                     ? true
          //                     : false;
          //               }
          //             } else {
          //               return false;
          //             }
          //           });
          //         })
          //       ],
          //     ),
          //     binding: AppSuccessPageBinding());
        } else {}
      },
      after: () {
        submitBtnEnable = true;
      },
    );
  }

  convertAction() {
    if (inputCtrl.text.isEmpty) {
      ShowToast.normal("请输入要转换的${walletData["name"] ?? ""}数量");
      return;
    }
    if (double.tryParse(inputCtrl.text) == null) {
      ShowToast.normal("请输入正确的金额");
      return;
    }
    if (AppDefault().homeData["investConfigId"] == null) {
      ShowToast.normal("请重新登录后重试");
      return;
    }
    if (AppDefault().homeData["u_3rd_password"] == null ||
        AppDefault().homeData["u_3rd_password"].isEmpty) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    bottomPayPassword.show();
  }

  int walletNo = 4;
  bool isRedPack = false;
  final _walletData = Rx<Map>({});
  Map get walletData => _walletData.value;
  set walletData(v) => _walletData.value = v;
  dataInit(int wNo, bool redPack) {
    if (!isFirst) return;
    isFirst = false;
    walletNo = wNo;
    isRedPack = redPack;
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
  }

  homeDataNotify(arg) {
    dataFormat();
  }

  dataFormat() {
    for (var e in (AppDefault().homeData["u_Account"] ?? [])) {
      if ((e["a_No"] ?? 0) == walletNo) {
        walletData = e;
        break;
      }
    }
  }

  @override
  void onInit() {
    // loadData();
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        convertRequest(payPwd);
      },
    );
    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    bottomPayPassword.dispos();
    inputCtrl.dispose();
    super.onClose();
  }
}

class MyWalletConvert extends GetView<MyWalletConvertController> {
  final int walletNo;
  final bool isRedPack;
  const MyWalletConvert({super.key, this.walletNo = 4, this.isRedPack = true});

  @override
  Widget build(BuildContext context) {
    controller.dataInit(walletNo, isRedPack);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar:
            getDefaultAppBar(context, isRedPack ? "兑换成红包" : "兑换奖励金", action: [
          CustomButton(
            onPressed: () {
              push(const MyWalletConvertHistory(), context,
                  binding: MyWalletConvertHistoryBinding(),
                  arguments: {"isRedPack": isRedPack});
            },
            child: SizedBox(
              width: 80.w,
              height: kToolbarHeight,
              child: Center(
                child: getSimpleText("兑换记录", 15, AppColor.textBlack),
              ),
            ),
          )
        ]),
        body: getInputBodyNoBtn(
          context,
          buttonHeight: 60.w + paddingSizeBottom(context),
          submitBtn: GetX<MyWalletConvertController>(
            builder: (_) {
              return Container(
                width: 375.w,
                height: 60.w + paddingSizeBottom(context),
                color: Colors.white,
                child: Column(
                  children: [
                    ghb(7.5),
                    getSubmitBtn("确认兑换", () {
                      controller.convertAction();
                    },
                        enable: controller.submitBtnEnable,
                        height: 45,
                        fontSize: 16,
                        color: AppColor.theme)
                  ],
                ),
              );
            },
          ),
          build: (boxHeight, context) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ghb(15),
                  Container(
                    width: 345.w,
                    height: 129.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          8.w,
                        ),
                        gradient: LinearGradient(
                            colors: [
                              isRedPack
                                  ? const Color(0xFFFF8B6A)
                                  : const Color(0xFFF7C94F),
                              isRedPack
                                  ? const Color(0xFFFD5222)
                                  : const Color(0xFFFDB82D)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)),
                    child: Column(
                      children: [
                        ghb(28),
                        sbRow([
                          centClm([
                            getSimpleText("可用积分", 14, Colors.white),
                            ghb(2),
                            GetX<MyWalletConvertController>(builder: (_) {
                              return getSimpleText(
                                  priceFormat(
                                      controller.walletData["amout"] ?? 0,
                                      savePoint: 0),
                                  30,
                                  Colors.white,
                                  isBold: true);
                            })
                          ], crossAxisAlignment: CrossAxisAlignment.start)
                        ], width: 345 - 22 * 2)
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15.w),
                    width: 345.w,
                    height: 60.w,
                    alignment: Alignment.center,
                    decoration: getDefaultWhiteDec(radius: 4),
                    child: sbRow([
                      getSimpleText("兑换积分", 15, AppColor.textBlack),
                      Container(
                        width: 120.w,
                        height: 45.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(8.w)),
                        child: CustomInput(
                          width: 90.w,
                          heigth: 45.w,
                          textEditCtrl: controller.inputCtrl,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 15.sp, color: AppColor.textBlack),
                          placeholderStyle: TextStyle(
                              fontSize: 15.sp, color: AppColor.assisText),
                          placeholder: "请输入",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ], width: 315),
                  ),
                  ghb(20),
                  sbRow([getSimpleText("兑换说明", 12, AppColor.textGrey5)],
                      width: 345),
                  ghb(10),
                  SizedBox(
                    width: 345.w,
                    child: HtmlWidget(
                      AppDefault().homeData["investConfigDesc"] ?? "",
                      textStyle:
                          TextStyle(fontSize: 12.sp, color: AppColor.textGrey5),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
