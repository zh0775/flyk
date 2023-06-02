import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_convert.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_deal_list.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw.dart';
import 'package:cxhighversion2/service/http_config.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MyWalletBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyWalletController>(MyWalletController(datas: Get.arguments));
  }
}

class MyWalletController extends GetxController {
  final dynamic datas;
  MyWalletController({this.datas});
  Map homeData = {};
  Map publicHomeData = {};
  final _walletList = Rx<List>([]);
  List get walletList => _walletList.value;
  set walletList(v) => _walletList.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  String walletCellId = "MyWallet_walletCellId_";
  bool cClient = false;

  final _drawList = Rx<List>([]);
  List get drawList => _drawList.value;
  set drawList(v) => _drawList.value = v;

  List walletColors = [
    [const Color(0xFFFF5D20), const Color(0xFFFFAA00)],
    [const Color(0xFFF8A535), const Color(0xFFFDCB7D)],
    [const Color(0xFFFF3A3A), const Color(0xFFFD573B)],
  ];

  final _cardCount = 0.obs;
  int get cardCount => _cardCount.value;
  set cardCount(v) => _cardCount.value = v;

  final _firstCardData = Rx<Map>({});
  Map get firstCardData => _firstCardData.value;
  set firstCardData(v) => _firstCardData.value = v;
  loadCard() {
    simpleRequest(
        url: Urls.bankList,
        params: {
          "pageNo": 1,
          "pageSize": 1,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            cardCount = data["count"] ?? 0;
            List bList = data["data"] ?? [];
            if (bList.isNotEmpty) {
              firstCardData = bList.first;
            }
          }
        },
        after: () {});
  }

  @override
  void onInit() {
    dataFormat();
    // loadDrawList();
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onInit();
  }

  loadDrawList() {
    if (drawList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userDrawList,
      params: {
        "pageNo": 1,
        "pageSize": 10,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          drawList = data["data"] ?? [];
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  getHomeDataNotify(arg) {
    dataFormat();
    update();
  }

  onRefresh() {
    Get.find<HomeController>().refreshHomeData();
  }

  bool isAuth = false;

  dataFormat() {
    // loadCard();
    final appDefault = AppDefault();
    if (appDefault.loginStatus) {
      homeData = AppDefault().homeData;
      // cClient = (homeData["u_Role"] ?? 0) == 0;
      publicHomeData = AppDefault().publicHomeData;
      Map drawInfo = publicHomeData["drawInfo"];
      List tmpWallet = [];
      List userAccounts = homeData["u_Account"] ?? [];
      userAccounts = userAccounts.where((e) => (e["a_No"] ?? 0) <= 3).toList();
      isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;

      if (HttpConfig.baseUrl.contains(AppDefault.oldSystem)) {
        List drawWallets =
            (drawInfo["System_AllowDrawAccount"] as String).split(",");
        List drawCharges =
            (drawInfo["System_TiHandlingCharge"] as String).split(",");
        List drawFees = (drawInfo["System_DrawFee"] as String).split(",");

        tmpWallet = List.generate(userAccounts.length, (index) {
          Map e = userAccounts[index];
          e["show"] = true;

          int walletIdx = -1;
          for (var i = 0; i < drawWallets.length; i++) {
            if (e["a_No"] == int.parse(drawWallets[i])) {
              walletIdx = i;
              break;
            }
          }
          e["haveDraw"] = walletIdx != -1 ? true : false;

          if (walletIdx != -1) {
            e["minCharge"] = drawInfo["System_MinHandingCharge"];
            e["charge"] = drawCharges[walletIdx];
            e["fee"] = drawFees[walletIdx];
          }

          e["lColor"] = walletColors[index % walletColors.length][0];
          e["rColor"] = walletColors[index % walletColors.length][1];

          return e;
        });
      } else {
        tmpWallet = List.generate(userAccounts.length, (index) {
          Map e = userAccounts[index];
          e["show"] = true;
          Map walletDrawInfo = {};
          if (drawInfo["draw_Account${e["a_No"] ?? -1}"] != null) {
            walletDrawInfo = drawInfo["draw_Account${e["a_No"] ?? -1}"];
          }
          e["haveDraw"] = walletDrawInfo.isNotEmpty;
          if (walletDrawInfo.isNotEmpty) {
            e["minCharge"] =
                "${walletDrawInfo["draw_Account_SingleAmountMin"] ?? 0}";
            e["charge"] =
                "${walletDrawInfo["draw_Account_ServiceCharges"] ?? 0}";
            e["fee"] = "${walletDrawInfo["draw_Account_SingleFee"] ?? 0}";
          }
          e["lColor"] = walletColors[index % walletColors.length][0];
          e["rColor"] = walletColors[index % walletColors.length][1];
          // if (index == 0) {
          //   e["lColor"] = const Color(0xFF6B96FD);
          //   e["rColor"] = const Color(0xFF366EFD);
          // } else if (index == 1) {
          //   e["lColor"] = const Color(0xFFFB993E);
          //   e["rColor"] = const Color(0xFFFD5843);
          // } else {
          //   Color c = AppDefault().getThemeColor(index: index - 2, open: true) ??
          //       const Color(0xFF366EFD);
          //   e["lColor"] = c.withOpacity(0.7);
          //   e["rColor"] = c;
          // }
          // e["icon"] = "mine/wallet/icon_wallet${index % 2 + 1}";
          e["icon"] = "mine/wallet/icon_wallet1";
          return e;
        });
      }

      if (cClient) {
        List tmpWallet2 = [];
        for (var e in tmpWallet) {
          if (e["a_No"] == AppDefault.awardWallet ||
              e["a_No"] == AppDefault.jfWallet) {
            tmpWallet2.add(e);
          }
        }
        walletList = tmpWallet2;
      } else {
        walletList = tmpWallet;
      }
    }
  }

  @override
  void onReady() {
    // if (!AppDefault().loginStatus) {
    //   popToLogin();
    // }
    super.onReady();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onClose();
  }
}

class MyWallet extends GetView<MyWalletController> {
  const MyWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "我的钱包"),
        body: EasyRefresh(
            onRefresh: () => controller.onRefresh(),
            // noMoreLoad: true,
            child: GetBuilder<MyWalletController>(builder: (_) {
              return ListView.builder(
                itemCount: controller.walletList.length,
                itemBuilder: (context, index) {
                  return walletCell(index, controller.walletList[index]);
                },
              );
            })

            // SingleChildScrollView(
            //   child: Column(
            //     children: [
            //       centClm(List.generate(
            //           controller.walletList.length,
            //           (index) =>
            //               walletCell(index, controller.walletList[index]))),

            // ghb(4.5),
            // sbhRow([
            //   Padding(
            //     padding: EdgeInsets.only(left: 15.w),
            //     child: GetX<MyWalletController>(builder: (_) {
            //       return getRichText("我的银行卡", "(${controller.cardCount}张)",
            //           16, AppColor.textBlack, 14, AppColor.textGrey5,
            //           isBold: true, isBold2: true);
            //     }),
            //   ),

            //   CustomButton(
            //     onPressed: () {
            //       checkIdentityAlert(
            //         toNext: () {
            //           push(const DebitCardInfo(), null,
            //               binding: DebitCardInfoBinding());
            //         },
            //       );
            //     },
            //     child: SizedBox(
            //       width: 91.w,
            //       height: 65.w,
            //       child: Center(
            //           child: getSimpleText("进入卡包", 14, AppColor.textBlack)),
            //     ),
            //   )
            //   // getSimpleText("我的银行卡", fontSize, color)
            // ], width: 375, height: 65),

            // // 银行卡
            // GetX<MyWalletController>(builder: (_) {
            //   return controller.cardCount == 0
            //       ? Padding(
            //           padding: EdgeInsets.symmetric(vertical: 15.w),
            //           child: getSimpleText(
            //               "您还没有绑定银行卡", 15, AppColor.textGrey5),
            //         )
            //       : SizedBox(
            //           width: 345.w,
            //           height: 168.5.w,
            //           child: Stack(
            //             children: [
            //               Align(
            //                 alignment: Alignment.topCenter,
            //                 child: Image.asset(
            //                   assetsName("mine/wallet/bg_card"),
            //                   width: 337.w,
            //                   height: 168.5.w,
            //                   fit: BoxFit.fill,
            //                 ),
            //               ),
            //               Positioned(
            //                   top: 21.w,
            //                   left: 0,
            //                   width: 345.w,
            //                   height: 135.w,
            //                   child: Container(
            //                     decoration: BoxDecoration(
            //                         borderRadius:
            //                             BorderRadius.circular(8.w),
            //                         gradient: const LinearGradient(
            //                             colors: [
            //                               Color(0xFF6395FB),
            //                               Color(0xFF3C79F7),
            //                             ],
            //                             begin: Alignment.bottomLeft,
            //                             end: Alignment.topRight)),
            //                     child: Column(
            //                       mainAxisAlignment:
            //                           MainAxisAlignment.spaceBetween,
            //                       children: [
            //                         centClm([
            //                           ghb(16),
            //                           gwb(345),
            //                           sbhRow([
            //                             getSimpleText(
            //                                 controller.firstCardData[
            //                                         "bankName"] ??
            //                                     "",
            //                                 18,
            //                                 Colors.white,
            //                                 isBold: true),
            //                             Image.asset(
            //                               assetsName(
            //                                   "mine/wallet/icon_card_ic"),
            //                               width: 31.w,
            //                               fit: BoxFit.fitWidth,
            //                             )
            //                           ], width: 345 - 16.5 * 2)
            //                         ]),
            //                         centClm([
            //                           sbRow([
            //                             getSimpleText(
            //                                 controller.firstCardData[
            //                                                 "bankAccountNumber"] !=
            //                                             null &&
            //                                         controller
            //                                                 .firstCardData[
            //                                                     "bankAccountNumber"]
            //                                                 .length >
            //                                             4
            //                                     ? "****  ****  ****  ${(controller.firstCardData["bankAccountNumber"] as String).substring(controller.firstCardData["bankAccountNumber"].length - 4, controller.firstCardData["bankAccountNumber"].length)}"
            //                                     : "",
            //                                 24,
            //                                 Colors.white,
            //                                 isBold: true,
            //                                 letterSpacing: 1.5.w)
            //                           ], width: 345 - 25 * 2),
            //                           ghb(25)
            //                         ])
            //                       ],
            //                     ),
            //                   ))
            //             ],
            //           ),
            //         );
            // }),

            // ghb(50),
            // ],
            // ),
            // ),
            ));
  }

  Widget walletCell(int index, Map data) {
    bool draw = data["haveDraw"] ?? false;

    Color lColor = data["lColor"] ?? const Color(0xFF6B96FD);
    Color rColor = data["rColor"] ?? const Color(0xFF366EFD);

    String unit = "";
    String inUnit = "";
    String outUnit = "";
    bool tenThousand = (data["amout"] ?? 0) > 100000.0;
    bool inTenThousand = (data["amout2"] ?? 0) > 100000.0;
    bool outTenThousand = (data["amout3"] ?? 0) > 100000.0;

    if ((data["a_No"] ?? 0) < 4) {
      unit = "(${(data["amout"] ?? 0) > 100000.0 ? "万" : ""}元)";
      inUnit = "(${(data["amout2"] ?? 0) > 100000.0 ? "万" : ""}元)";
      outUnit = "(${(data["amout3"] ?? 0) > 100000.0 ? "万" : ""}元)";
    } else {
      unit = (data["amout"] ?? 0) > 100000.0 ? "(万)" : "";
      inUnit = (data["amout2"] ?? 0) > 100000.0 ? "(万)" : "";
      outUnit = (data["amout3"] ?? 0) > 100000.0 ? "(万)" : "";
    }
    return Align(
      child: Column(
        children: [
          sbhRow([
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: getSimpleText(
                  "${data["name"] ?? ""}钱包", 16, AppColor.textBlack,
                  isBold: true),
            ),
            CustomButton(
              onPressed: () {
                push(
                    MyWalletDealList(
                      walletData: data,
                      fromHome: true,
                    ),
                    null,
                    binding: MyWalletDealListBinding());
              },
              child: SizedBox(
                  width: 60.w,
                  height: 45.w,
                  child: Center(
                      child: getSimpleText("明细", 14, AppColor.textBlack))),
            )
          ], width: 375, height: 45),
          Container(
              // margin: EdgeInsets.only(top: 15.w),
              width: 345.w,
              height: 180.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [lColor, rColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.w),
                    child: sbRow([
                      centClm([
                        centRow([
                          getSimpleText("可用余额$unit", 14, Colors.white),
                          // gwb(2),
                          // Image.asset(
                          //   assetsName("mine/wallet/icon_right_arrow_white"),
                          //   width: 16.w,
                          //   fit: BoxFit.fitWidth,
                          // )
                        ]),
                        ghb(10),
                        getSimpleText(
                            priceFormat(data["amout"] ?? 0,
                                tenThousand: tenThousand),
                            30,
                            Colors.white,
                            fw: FontWeight.w700,
                            textHeight: 1),
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                      Visibility(
                          // visible: draw || data["a_No"] == 4,
                          visible: draw,
                          child: CustomButton(
                            onPressed: () {
                              if (data["a_No"] == 4) {
                                push(
                                    MyWalletConvert(
                                        walletNo: data["a_No"] ?? 0),
                                    null,
                                    binding: MyWalletConvertBinding());
                              } else {
                                checkIdentityAlert(toNext: () {
                                  push(
                                      MyWalletDraw(
                                        walletData: data,
                                      ),
                                      null,
                                      binding: MyWalletDrawBinding());
                                });
                              }
                            },
                            child: Container(
                              width: 90.w,
                              height: 30.w,
                              margin: EdgeInsets.only(right: 3.w),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.w),
                                  color: Colors.white),
                              child: Center(
                                child: getSimpleText(
                                    data["a_No"] == 4 ? "去兑换" : "去提现",
                                    15,
                                    lColor),
                              ),
                            ),
                          )),
                    ],
                        width: 345 - 21 * 2,
                        crossAxisAlignment: CrossAxisAlignment.end),
                  ),
                  sbRow([
                    centRow([
                      gwb(21),
                      centClm([
                        getWidthText(
                            priceFormat(data["amout2"] ?? 0,
                                tenThousand: inTenThousand),
                            14,
                            Colors.white.withOpacity(0.7),
                            116,
                            1),
                        ghb(3),
                        getWidthText("总收入$inUnit", 12,
                            Colors.white.withOpacity(0.7), 116, 1),
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                      centClm([
                        getWidthText(
                            priceFormat(data["amout3"] ?? 0,
                                tenThousand: outTenThousand),
                            14,
                            Colors.white.withOpacity(0.7),
                            116,
                            1),
                        ghb(3),
                        getWidthText("总支出$outUnit", 12,
                            Colors.white.withOpacity(0.7), 116, 1),
                      ], crossAxisAlignment: CrossAxisAlignment.start)
                    ]),
                    Image.asset(
                      assetsName(data["icon"] ?? ""),
                      width: 70.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ], width: 345)
                ],
              )),
        ],
      ),
    );
  }
}
