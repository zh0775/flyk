import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_convert.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_deal_list.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw_detail.dart';
import 'package:cxhighversion2/mine/myWallet/my_wallet_draw_history.dart';
import 'package:cxhighversion2/mine/myWallet/receipt_setting.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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

  RefreshController pullCtrl = RefreshController();

  bool cClient = false;

  final _drawList = Rx<List>([]);
  List get drawList => _drawList.value;
  set drawList(v) => _drawList.value = v;

  @override
  void onInit() {
    dataFormat();
    loadDrawList();
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
  }

  onRefresh() {
    Get.find<HomeController>().refreshHomeData();
  }

  bool isAuth = false;

  dataFormat() {
    final appDefault = AppDefault();
    if (appDefault.loginStatus) {
      homeData = AppDefault().homeData;
      // cClient = (homeData["u_Role"] ?? 0) == 0;
      publicHomeData = AppDefault().publicHomeData;
      Map drawInfo = publicHomeData["drawInfo"];
      List tmpWallet = [];
      List userAccounts = homeData["u_Account"] ?? [];
      isAuth = (homeData["authentication"] ?? {})["isCertified"] ?? false;

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
          e["charge"] = "${walletDrawInfo["draw_Account_ServiceCharges"] ?? 0}";
          e["fee"] = "${walletDrawInfo["draw_Account_SingleFee"] ?? 0}";
        }
        if (index == 0) {
          e["lColor"] = const Color(0xFF6B96FD);
          e["rColor"] = const Color(0xFF366EFD);
        } else if (index == 1) {
          e["lColor"] = const Color(0xFFFB993E);
          e["rColor"] = const Color(0xFFFD5843);
        } else {
          Color c = AppDefault().getThemeColor(index: index - 2, open: true) ??
              const Color(0xFF366EFD);
          e["lColor"] = c.withOpacity(0.7);
          e["rColor"] = c;
        }
        e["icon"] = "mine/wallet/icon_wallet${index % 2 + 1}";
        return e;
      });

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
    pullCtrl.refreshCompleted();
    update();
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
    pullCtrl.dispose();
    super.onClose();
  }
}

class MyWallet extends GetView<MyWalletController> {
  const MyWallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "我的钱包", action: [
          CustomButton(
              onPressed: () {
                push(const ReceiptSetting(), context,
                    binding: ReceiptSettingBinding());
              },
              child: SizedBox(
                width: 80.w,
                height: kToolbarHeight,
                child: Center(child: getSimpleText("收款设置", 14, AppColor.text2)),
              )),
        ]),
        body: EasyRefresh(
          onRefresh: () => controller.onRefresh(),
          noMoreLoad: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(controller.walletList.length,
                    (index) => walletCell(index, controller.walletList[index])),
                sbhRow([
                  centRow([
                    gwb(4),
                    getSimpleText("提现记录", 16, AppColor.text, isBold: true),
                  ]),
                  CustomButton(
                    onPressed: () {
                      push(const MyWalletDrawHistory(), null,
                          binding: MyWalletDrawHistoryBinding());
                    },
                    child: SizedBox(
                      height: 52.5,
                      child: centRow([
                        getSimpleText(
                          "查看更多",
                          12,
                          AppColor.text3,
                        ),
                        // gwb(3),
                        Image.asset(
                          assetsName("mine/icon_right_arrow"),
                          width: 12.w,
                          fit: BoxFit.fitWidth,
                        )
                      ]),
                    ),
                  )
                ], width: 375 - 11.5 * 2, height: 52.5),
                GetX<MyWalletController>(
                  builder: (_) {
                    return controller.drawList.isEmpty
                        ? GetX<MyWalletController>(
                            builder: (_) {
                              return CustomEmptyView(
                                topSpace: 20,
                                centerSpace: 0,
                                bottomSpace: 30,
                                isLoading: controller.isLoading,
                                contentText: "您还没有提现数据",
                              );
                            },
                          )
                        : centClm(List.generate(
                            controller.drawList.length,
                            (index) =>
                                drawList(index, controller.drawList[index])));
                  },
                ),
                ghb(20),
              ],
            ),
          ),
        ));
  }

  Widget drawList(int index, Map data) {
    String img = data["account"] != null
        ? AppDefault().getAccountImg(data["account"])
        : "";
    String accountName = data["onlineName"] ?? data["bankName"] ?? "";
    String imgUrl = AppDefault().imageUrl + img;
    return CustomButton(
      onPressed: () {
        push(const MyWalletDrawDetail(), null,
            binding: MyWalletDrawDetailBinding(),
            arguments: {"drawData": data});
      },
      child: Container(
        width: 375.w,
        height: 75.w,
        alignment: Alignment.center,
        color: Colors.white,
        child: sbhRow([
          centRow([
            img.isNotEmpty
                ? CustomNetworkImage(
                    src: imgUrl,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.fill,
                  )
                : SizedBox(
                    width: 32.w,
                  ),
            gwb(7),
            centClm([
              getWidthText("${data["accountName"] ?? ""}提现-到$accountName", 15,
                  AppColor.text2, 214.5, 1),
              ghb(8),
              getWidthText(data["addTime"] ?? "", 12, AppColor.text3, 214.5, 1)
            ], crossAxisAlignment: CrossAxisAlignment.start)
          ]),
          centClm([
            getWidthText(priceFormat(data["amount"] ?? 0), 18, AppColor.text,
                345 - 32 - 7 - 214.5 - 0.1, 1,
                isBold: true, alignment: Alignment.centerRight),
            ghb(5),
            getWidthText(data["managedStr"] ?? "", 12, AppColor.text3,
                345 - 32 - 7 - 214.5 - 0.1, 1,
                alignment: Alignment.centerRight),
          ], crossAxisAlignment: CrossAxisAlignment.end)
        ], width: 375 - 15 * 2, height: 75),
      ),
    );
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
      child: Container(
          margin: EdgeInsets.only(top: 15.w),
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
                    child: centClm([
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
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                  ),
                  Visibility(
                      // visible: draw || data["a_No"] == 4,
                      visible: draw,
                      child: CustomButton(
                        onPressed: () {
                          if (data["a_No"] == 4) {
                            push(
                                MyWalletConvert(
                                  walletData: data,
                                ),
                                null,
                                binding: MyWalletConvertBinding());
                          } else {
                            checkIdentityAlert(
                              toNext: () {
                                push(
                                    MyWalletDraw(
                                      walletData: data,
                                    ),
                                    null,
                                    binding: MyWalletDrawBinding());
                              },
                            );
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
                                data["a_No"] == 4 ? "去兑换" : "去提现", 15, rColor),
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
    );
  }
}
