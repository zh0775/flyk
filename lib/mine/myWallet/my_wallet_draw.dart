import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw_result.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyWalletDrawBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletDrawController>(MyWalletDrawController());
  }
}

enum DrawAccountType { alipay, card, balance, none }

class MyWalletDrawController extends GetxController {
  bool isFirst = true;
  final drawInputCtrl = TextEditingController();

  Map walletData = {};
  dataInit(Map wData) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    walletData = wData;
  }

  List cardList = [];

  final _accountList = Rx<List>([]);
  List get accountList => _accountList.value;
  set accountList(v) => _accountList.value = v;

  loadCardData() {
    simpleRequest(
        url: Urls.bankList,
        params: {
          "pageNo": 1,
          "pageSize": 30,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};

            List bList = data["data"] ?? [];

            cardList = List.generate(bList.length, (index) {
              Map e = bList[index];
              String no = e["bankAccountNumber"] ?? "";
              String title = no.length > 4
                  ? "${e["bankName"] ?? ""}(${no.substring(no.length - 4, no.length)})"
                  : e["bankName"] ?? "";
              return {
                ...e,
                "name": e["bankName"] ?? "",
                "no": no,
                "type": 1,
                "title": title
              };
            });
            accountList = [
              ...accountList,
              ...cardList,
            ];
            update();

            // isLoad ? pullCtrl.finishLoad() : pullCtrl.finishRefresh();
            // isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          }
        },
        after: () {},
        useCache: true);
  }

  BottomPayPassword? bottomPayPassword;

  Map alipayData = {};
  Map cardData = {};

  bool haveAlipay = false;
  bool haveCard = false;
  bool haveWX = false;

  bool openAlipay = false;
  bool openCard = false;
  bool openWX = false;

  bool isAuth = false;

  Map homeData = {};
  Map publicHomeData = {};
  Map authentication = {};

  loadDrawRequest(String pwd) {
    //  1.银行卡 2.支付宝 3.微信
    simpleRequest(
      url: Urls.userDrawMoneyApply,
      params: {
        "drawMoney": double.parse(drawInputCtrl.text),
        "drawAccount": walletData["a_No"],
        "drawReleaseType": accountList[defaultAccountIdx]["type"],
        "u_3nd_Pad": pwd,
      },
      success: (success, json) {
        if (success) {
          Get.find<HomeController>().refreshHomeData();
          // Get.to(
          //     AppSuccessPage(
          //       title: "提交完成",
          //       contentText: "提现申请已提交",
          //       subContentText: "预计1-3个工作日到账",
          //       buttons: [
          //         getSubmitBtn("返回首页", () {
          //           Get.until((route) {
          //             if (route is GetPageRoute) {
          //               return (route.binding is MainPageBinding)
          //                   ? true
          //                   : false;
          //             } else {
          //               return false;
          //             }
          //           });
          //         })
          //       ],
          //     ),
          //     binding: AppSuccessPageBinding());
        }

        push(
            MyWalletDrawResult(
              success: success,
              describe:
                  success ? "提现后7个工作日内到账，若有疑问请联系客服" : json["messages"] ?? "",
              accountName: accountList[defaultAccountIdx]["title"] ?? "",
              money: double.tryParse(drawInputCtrl.text) ?? 0,
              contentTitle: success ? "提现申请提交成功" : "提现申请提交失败",
            ),
            Global.navigatorKey.currentContext!);
      },
      after: () {},
    );
  }

  alipayAlert(Function() close) {
    showAuthAlert(
        context: Global.navigatorKey.currentContext!,
        isAuth: false,
        alipay: true,
        close: close,
        haveClose: false);
  }

  authAlert(Function() close) {
    showAuthAlert(
        context: Global.navigatorKey.currentContext!,
        isAuth: true,
        close: close,
        haveClose: false);
  }

  bindAlert(Function() close) {
    showAuthAlert(
        context: Global.navigatorKey.currentContext!,
        isAuth: false,
        close: close,
        haveClose: false);
  }

  pwdAlert(Function() close) {
    showPayPwdWarn(close: close, haveClose: false);
  }

  drawAction() {
    if (drawInputCtrl.text.isEmpty) {
      ShowToast.normal("请输入金额");
      return;
    }
    if (double.parse(drawInputCtrl.text) == 0) {
      ShowToast.normal("请输入金额必须大于0");
      return;
    }
    if (double.parse(drawInputCtrl.text) <
        double.parse((walletData["minCharge"] ?? 0.0))) {
      ShowToast.normal("最小提现金额${walletData["minCharge"] ?? 0.0}元");
      return;
    }
    // if (currentSelectIdx == -1) {
    //   ShowToast.normal("请选择提现方式");
    //   return;
    // }
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
    bottomPayPassword?.show();
  }

  bool newDraw = false;
  @override
  void onInit() {
    // update();
    newDraw = true;
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadDrawRequest(payPwd);
      },
    );
    dataFormat();
    super.onInit();
  }

  final _defaultAccountIdx = 0.obs;
  int get defaultAccountIdx => _defaultAccountIdx.value;
  set defaultAccountIdx(v) => _defaultAccountIdx.value = v;

  final _bottomAccountIdx = 0.obs;
  int get bottomAccountIdx => _bottomAccountIdx.value;
  set bottomAccountIdx(v) => _bottomAccountIdx.value = v;

  dataFormat() {
    homeData = AppDefault().homeData;
    publicHomeData = AppDefault().publicHomeData;
    authentication = homeData["authentication"];
    haveCard = authentication["isBank"];
    haveAlipay = authentication["isAliPay"];
    isAuth = authentication["isCertified"];
    Map drawInfo = publicHomeData["drawInfo"] ?? {};
    //1支付宝；2银行；3微信；

    List payTypes = [];

    payTypes = drawInfo["draw_Account_PayType"] ?? [];
    for (var e in payTypes) {
      if (e["id"] == 2) {
        openAlipay = true;
      } else if (e["id"] == 1) {
        openCard = true;
      }
    }
    accountList = [];
    if (openAlipay) {
      accountList = [
        {
          "id": 0,
          "name": "支付宝账户",
          "no": authentication["user_OnlinePay_Account"] ?? "",
          "title": "支付宝账户(${authentication["user_OnlinePay_Account"] ?? ""})",
          "type": 2
        }
      ];
    }
    if (openCard) {
      loadCardData();
    }

    // List payTypes =
    //     ((drawInfo["System_PayType"] ?? "") as String).split(",");

    if (haveAlipay && openAlipay) {
      alipayData = {
        "name": authentication["user_OnlinePay_Name"],
        "accound": authentication["user_OnlinePay_Account"]
      };
    }
    if (haveCard && openCard) {
      cardData = {
        "name": authentication["bank_AccountName"],
        "accound": authentication["bank_AccountNumber"]
      };
    }
    update();
  }

  @override
  void onReady() {
    // if (!isAuth) {
    //   authAlert(() {});
    // } else if ((openCard ? !haveCard : true) &&
    //     (openAlipay ? !haveAlipay : true)) {
    //   if (!haveCard && openCard) {
    //     bindAlert(() {});
    //   } else if (!haveAlipay && openAlipay) {
    //     alipayAlert(() {});
    //   }
    // } else

    if (!(homeData["userHasU3rdPwd"] ?? false)) {
      pwdAlert(() {});
    }
    super.onReady();
  }

  @override
  void onClose() {
    drawInputCtrl.dispose();
    super.onClose();
  }
}

class MyWalletDraw extends GetView<MyWalletDrawController> {
  final Map walletData;
  const MyWalletDraw({Key? key, required this.walletData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(walletData);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "提现"),
        body: getInputBodyNoBtn(context,
            contentColor: AppColor.pageBackgroundColor,
            buttonHeight: 0, build: (boxHeight, context) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                walletCell(walletData),
                ghb(16),
                Container(
                  width: 345.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.w)),
                  child: Column(
                    children: [
                      sbhRow([
                        Padding(
                          padding: EdgeInsets.only(left: 3.5.w),
                          child: getSimpleText("到账账户", 14, AppColor.text2),
                        ),
                        CustomButton(
                          onPressed: () {
                            if (controller.accountList.isEmpty) {
                              Get.offUntil(
                                  GetPageRoute(
                                    page: () => const ReceiptSetting(),
                                    binding: ReceiptSettingBinding(),
                                  ),
                                  (route) => route is GetPageRoute
                                      ? route.binding is MyWalletBinding
                                          ? true
                                          : false
                                      : false);
                              return;
                            }
                            showSelectAccount(context);
                          },
                          child: SizedBox(
                              height: 66.w,
                              child: Center(
                                  child: centRow([
                                GetX<MyWalletDrawController>(
                                  builder: (_) {
                                    return getSimpleText(
                                        controller.accountList.isEmpty
                                            ? "请先添加提现账户"
                                            : controller.accountList[controller
                                                .defaultAccountIdx]["title"],
                                        15,
                                        controller.accountList.isEmpty
                                            ? AppColor.text3
                                            : AppColor.text,
                                        isBold: true);
                                  },
                                ),
                                Image.asset(
                                  assetsName(
                                      "statistics/icon_arrow_right_gray"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                )
                              ]))),
                        ),
                      ], width: 345 - 7.5 * 2, height: 66),
                      ghb(4),
                      gline(345, 1),
                      ghb(20),
                      sbRow([
                        getSimpleText("提现金额", 15, AppColor.text2),
                      ], width: 345 - 11 * 2),
                      SizedBox(
                        width: 345.w - 11.w * 2,
                        height: 88.w,
                        child: Row(
                          children: [
                            getWidthText("¥", 24, AppColor.text, 30, 1,
                                textHeight: 1.0),
                            CustomInput(
                              width: 345.w - 11.w * 2 - 30.w,
                              heigth: 88.w,
                              textEditCtrl: controller.drawInputCtrl,
                              style: TextStyle(
                                  color: AppColor.text,
                                  fontSize: 24.sp,
                                  fontWeight: AppDefault.fontBold),
                              placeholderStyle: TextStyle(
                                  color: AppColor.text3,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.normal),
                              placeholder:
                                  "最低提现金额${priceFormat(walletData["minCharge"] ?? 0)}元",
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      sbRow([
                        getSimpleText(
                            "提现时 平台代扣${integralFormat((Decimal.parse(walletData["charge"] ?? 0)) * Decimal.parse("100"))}%税费+${walletData["fee"] ?? 0}元/笔秒到费",
                            12,
                            AppColor.text3),
                      ], width: 345 - 11 * 2),
                      ghb(16),
                    ],
                  ),
                ),
                ghb(31),
                getSubmitBtn("确认提现", () {
                  controller.drawAction();
                }, color: AppColor.theme, height: 45)
              ],
            ),
          );
        }),
      ),
    );
  }

  showSelectAccount(BuildContext context) {
    controller.bottomAccountIdx = controller.defaultAccountIdx;
    double btnsHeight = controller.accountList.length * 57;
    btnsHeight += 2 * 20;
    bool overHeight = false;
    if (btnsHeight > ScreenUtil().screenHeight * 0.7) {
      btnsHeight = ScreenUtil().screenHeight * 0.7;
      overHeight = true;
    }

    Get.bottomSheet(
        Container(
          width: 375.w,
          height: 54.w + 70.w + btnsHeight.w + paddingSizeBottom(context),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
          child: Column(
            children: [
              sbhRow([
                gwb(42),
                getSimpleText("选择到账账户", 18, AppColor.text, isBold: true),
                CustomButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 42.w,
                    height: 48.w,
                    child: Center(
                      child: Image.asset(
                        assetsName("statistics/machine/btn_model_close"),
                        width: 20.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                )
              ], width: 375, height: 48),
              ghb(5),
              gline(375, 1),
              SizedBox(
                height: btnsHeight,
                child: Center(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: centClm([
                        gwb(375),
                        ghb(
                          overHeight ? 20 : 0,
                        ),
                        ...List.generate(controller.accountList.length,
                            (index) {
                          return CustomButton(
                            onPressed: () {
                              controller.bottomAccountIdx = index;
                            },
                            child: sbhRow([
                              getSimpleText(
                                  controller.accountList[index]["title"] ?? "",
                                  16,
                                  const Color(0xFF333333)),
                              GetX<MyWalletDrawController>(
                                builder: (_) {
                                  return Image.asset(
                                    assetsName(
                                        "machine/checkbox_${controller.bottomAccountIdx == index ? "selected" : "normal"}"),
                                    width: 21.w,
                                    fit: BoxFit.fitWidth,
                                  );
                                },
                              )
                            ], width: 321.5, height: 57),
                          );
                        }),
                        ghb(
                          overHeight ? 20 : 0,
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
              getSubmitBtn("确定", () {
                controller.defaultAccountIdx = controller.bottomAccountIdx;
                Navigator.pop(context);
              }, fontSize: 15, height: 45, color: AppColor.theme)
            ],
          ),
        ),
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: true);
  }

  Widget walletCell(Map data) {
    Color lColor = data["lColor"] ?? const Color(0xFF6B96FD);
    Color rColor = data["rColor"] ?? const Color(0xFF366EFD);
    bool tenThousand = (data["amout"] ?? 0) > 100000.0;
    String unit = "";
    if ((data["a_No"] ?? 0) < 4) {
      unit = "(${(data["amout"] ?? 0) > 100000.0 ? "万" : ""}元)";
    } else {
      unit = (data["amout"] ?? 0) > 100000.0 ? "(万)" : "";
    }
    return Align(
      child: Container(
          margin: EdgeInsets.only(top: 15.w),
          width: 345.w,
          height: 129.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [lColor, rColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25.w),
                    child: sbRow([
                      centClm([
                        centRow([
                          getSimpleText(
                              "${data["name"] ?? ""}$unit", 14, Colors.white),
                          gwb(2),
                          Image.asset(
                            assetsName("mine/wallet/icon_right_arrow_white"),
                            width: 16.w,
                            fit: BoxFit.fitWidth,
                          )
                        ]),
                        ghb(10),
                        getSimpleText(
                            priceFormat(data["amout"] ?? 0,
                                tenThousand: tenThousand),
                            30,
                            Colors.white,
                            fw: FontWeight.w700,
                            textHeight: 1),
                        ghb(15),
                        getSimpleText(
                            "可提现金额 ￥${priceFormat(data["amout"] ?? 0, tenThousand: tenThousand)}",
                            12,
                            Colors.white.withOpacity(0.5))
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                    ],
                        width: 345 - 21 * 2,
                        crossAxisAlignment: CrossAxisAlignment.end),
                  ),
                ],
              )),
              Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  assetsName(data["icon"] ?? ""),
                  width: 70.w,
                  fit: BoxFit.fitWidth,
                ),
              )
            ],
          )),
    );
  }
}
