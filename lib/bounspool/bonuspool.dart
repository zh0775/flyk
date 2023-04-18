import 'dart:async';

import 'package:cxhighversion2/bounspool/bonuspool_history_list.dart'
    deferred as bonuspool_history_list;
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class BounsPoolController extends GetxController {
  bool already = false;
  final _rankIdx = 0.obs;
  int get rankIdx => _rankIdx.value;
  set rankIdx(v) {
    if (_rankIdx.value != v) {
      _rankIdx.value = v;
      // loadData();
      update();
    }
  }

  Map mainData = {};
  List dataList = [];

  Timer? myTimer;
  double persent = 0.0;

  // bool drawBoundEnable = false;
  String drawBoundStr = "";

  drawBoundAction() {
    simpleRequest(
      url: Urls.userVirtualCoinOrderOnSell,
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("恭喜您，领取成功！");
          loadData();
        }
      },
      after: () {},
    );
  }

  loadData() {
    simpleRequest(
      url: Urls.userPrizePoolData,
      params: {},
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          mainData = data;
          Get.find<HomeController>().bonusPoolMoney =
              mainData["tolTranAmount"] ?? 0;
          persent = (mainData["thisAmt"] ?? 0) / (mainData["targetAmt"] ?? 1);

          if (persent < 1) {
            drawBoundStr = "您还未达到领奖条件，请继续加油哦~";
          } else if ((mainData["revNum"] ?? 0) >= 2) {
            drawBoundStr = "您本月已领完，请下月再来哦~";
          } else {
            drawBoundStr = "";
          }
          Get.find<HomeController>().drawBoundStr = drawBoundStr;
          update();
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    loadData();
    // myTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
    //   if (AppDefault().token.isNotEmpty) {
    //     loadData();
    //   }
    // });
    super.onInit();
  }

  @override
  void onClose() {
    if (myTimer != null) {
      myTimer!.cancel();
      myTimer = null;
    }
    super.onClose();
  }
}

class BounsPool extends GetView<BounsPoolController> {
  const BounsPool({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEEDDE),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              width: 375.w,
              height: 533.w + 480.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      top: 0,
                      right: 0,
                      left: 0,
                      height: 553.w,
                      child: Image.asset(
                        assetsName("bonuspool/bg_top"),
                        width: 375.w,
                        alignment: Alignment.topCenter,
                        fit: BoxFit.fitWidth,
                      )),
                  Positioned(
                      top: 533.w,
                      left: 0,
                      right: 0,
                      height: 480.w,
                      child: Image.asset(assetsName("bonuspool/bg_center"),
                          width: 375.w,
                          height: 480.w,
                          alignment: Alignment.topCenter,
                          fit: BoxFit.fill)),
                  Positioned(
                      top: 90.w,
                      right: 0,
                      width: 24.w,
                      height: 65.w,
                      child: CustomButton(
                        onPressed: () {
                          showTips(context);
                        },
                        child: Container(
                          width: 24.w,
                          height: 65.w,
                          padding: EdgeInsets.only(left: 7.w),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEE3931),
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(12.w))),
                          child: Center(
                            child: getSimpleText("奖励规则", 12, Colors.white,
                                maxLines: 4, textHeight: 1.2),
                          ),
                        ),
                      )),
                  Positioned(
                      top: 265.w,
                      left: 15.w,
                      right: 15.w,
                      // height: 245.w,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage(
                                    assetsName("bonuspool/bg_bouns")))),
                        child: GetBuilder<BounsPoolController>(builder: (_) {
                          return Column(
                            children: [
                              gwb(345),
                              ghb(18),
                              getSimpleText(
                                  "今日实时奖金", 12, const Color(0xFF5A2F0F)),
                              ghb(9),
                              getRichText(
                                  "￥",
                                  priceFormat(
                                      controller.mainData["tolTranAmount"] ??
                                          0),
                                  24,
                                  const Color(0xFFF93635),
                                  45,
                                  const Color(0xFFF93635),
                                  isBold: true,
                                  isBold2: true),
                              ghb(30),
                              sbRow([
                                getSimpleText(
                                    "本月达标次数：${priceFormat(controller.mainData["dbNum"] ?? 0, savePoint: 0)}次",
                                    10,
                                    AppColor.textBlack),
                                getSimpleText(
                                    "${priceFormat(controller.persent * 100, savePoint: 0)}%",
                                    10,
                                    AppColor.textBlack)
                              ], width: 345 - 45 * 2),
                              ghb(5),
                              Container(
                                width: 255.w,
                                height: 5.w,
                                decoration: BoxDecoration(
                                    color: const Color(0xFFEE3931)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2.5.w)),
                                child: Stack(
                                  children: [
                                    AnimatedPositioned(
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        width: (255 * controller.persent).w,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: const Color(0xFFEE3931),
                                              borderRadius:
                                                  BorderRadius.circular(2.5.w)),
                                        )),
                                  ],
                                ),
                              ),
                              ghb(5),
                              sbRow([
                                getSimpleText("0", 10, const Color(0xFFEE3931)),
                                getSimpleText(
                                    "${priceFormat(controller.mainData["targetAmt"] ?? 0)}元",
                                    10,
                                    const Color(0xFFEE3931))
                              ], width: 345 - 45 * 2),
                              ghb(10),
                              CustomButton(
                                onPressed: () {
                                  if (controller.drawBoundStr.isNotEmpty) {
                                    ShowToast.normal(controller.drawBoundStr);
                                    return;
                                  }
                                  controller.drawBoundAction();
                                },
                                child: Container(
                                  width: 255.w,
                                  height: 45.w,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: AssetImage(assetsName(
                                              "bonuspool/btn_bouns")))),
                                  child: Center(
                                    child: getSimpleText(
                                        !controller.already ? "立即领奖" : "本月已领",
                                        18,
                                        const Color(0xFFFFE9B7),
                                        isBold: true,
                                        textHeight: 1.3),
                                  ),
                                ),
                              ),
                              ghb(5),
                              getSimpleText("* 奖金数据1分钟更新一次", 10,
                                  AppColor.textBlack.withOpacity(0.5)),
                              ghb(10.5)
                            ],
                          );
                        }),
                      )),
                  Positioned(
                      left: 15.w,
                      right: 15.w,
                      top: 533.w,
                      height: 200.w,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            color: Colors.white),
                        child: Column(
                          children: [
                            gwb(345),
                            ghb(20),
                            getSimpleText("累计奖金(元)", 12, AppColor.textGrey5),
                            ghb(10),
                            getSimpleText(
                                priceFormat(controller.mainData["tolAmt"] ?? 0),
                                45,
                                const Color(0xFFEE3931),
                                isBold: true),
                            ghb(5),
                            getSimpleButton(
                              () async {
                                await bonuspool_history_list.loadLibrary();
                                push(
                                    bonuspool_history_list
                                        .BonuspoolHistoryList(),
                                    null,
                                    binding: bonuspool_history_list
                                        .BonuspoolHistoryListBinding());
                              },
                              getSimpleText(
                                  "查看详情", 12, const Color(0xFF5A2F0F)),
                              width: 105,
                              height: 40,
                              colors: [
                                const Color(0xFFFFE09E),
                                const Color(0xFFFFE9B8),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            ghb(15),
                            getRichText(
                                "到账/次数 ",
                                "￥${priceFormat(controller.mainData["moThisAmt"] ?? 0)}/${controller.mainData["revNum"] ?? 0}次",
                                10,
                                AppColor.textBlack,
                                12,
                                const Color(0xFFEE3931),
                                isBold2: true),
                          ],
                        ),
                      )),
                ],
              ),
            ),
            Container(
              width: 375.w,
              height: 260.w,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage(assetsName("bonuspool/bg_bottom")))),
              child: Column(
                children: [
                  ghb(3),
                  Container(
                    width: 180.w,
                    height: 33.w,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16.5.w)),
                    child: Stack(children: [
                      Positioned(
                          left: 2.5.w,
                          top: 2.5.w,
                          width: 90.w,
                          height: 28.w,
                          child: CustomButton(
                            onPressed: () {
                              if (controller.rankIdx != 0) {
                                controller.rankIdx = 0;
                              }
                            },
                            child: SizedBox(
                              child: Center(
                                child: getSimpleText("奖金榜", 15, AppColor.red,
                                    isBold: true),
                              ),
                            ),
                          )),
                      Positioned(
                          top: 2.5.w,
                          right: 2.5.w,
                          width: 90.w,
                          height: 28.w,
                          child: CustomButton(
                            onPressed: () {
                              if (controller.rankIdx != 1) {
                                controller.rankIdx = 1;
                              }
                            },
                            child: SizedBox(
                              child: Center(
                                child: getSimpleText("幸运榜", 15, AppColor.red,
                                    isBold: true),
                              ),
                            ),
                          )),
                      GetX<BounsPoolController>(
                        builder: (_) {
                          return AnimatedPositioned(
                            top: 2.5.w,
                            left: controller.rankIdx == 0
                                ? 2.5.w
                                : 180.w - 90.w - 2.5.w,
                            duration: const Duration(milliseconds: 200),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 90.w,
                              height: 28.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: AppColor.red,
                                  borderRadius: BorderRadius.circular(14.w)),
                              child: getSimpleText(
                                  controller.rankIdx == 0 ? "奖金榜" : "幸运榜",
                                  15,
                                  Colors.white,
                                  isBold: true),
                            ),
                          );
                        },
                      ),
                    ]),
                  ),
                  ghb(24),
                  GetBuilder<BounsPoolController>(
                    builder: (_) {
                      return SizedBox(
                        width: 375.w,
                        height: 200.w,
                        child: Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Image.asset(
                                assetsName("bonuspool/bg_ljt"),
                                width: 354.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            getHeadView(1),
                            getHeadView(0),
                            getHeadView(2),
                            getTopData(1),
                            getTopData(0),
                            getTopData(2),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            Container(
              width: 375.w,
              decoration: BoxDecoration(
                gradient: simpleGradient(
                  [
                    const Color(0xFFFFFFFF),
                    const Color(0xFFFEEDDE),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: GetBuilder<BounsPoolController>(
                builder: (_) {
                  List datas = controller.mainData[
                          controller.rankIdx == 0 ? "top10" : "luckyTop10"] ??
                      [];
                  return datas.length < 3
                      ? ghb(0)
                      : Column(
                          children: [
                            ...List.generate(datas.length - 3, (index) {
                              Map data = datas[index + 3];

                              return SizedBox(
                                height: 52.5.w,
                                width: 375.w,
                                child: Center(
                                  child: sbRow([
                                    centRow([
                                      getSimpleText("${index + 4}", 14,
                                          const Color(0xFF5A2F0F),
                                          isBold: true),
                                      gwb(15),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(17.5.w),
                                        child: CustomNetworkImage(
                                          src: AppDefault().imageUrl +
                                              (data["u_Avatar"] ?? ""),
                                          width: 35.w,
                                          height: 35.w,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      gwb(15),
                                      getSimpleText(
                                        data["u_Name"],
                                        14,
                                        const Color(0xFF5A2F0F),
                                      ),
                                    ]),
                                    getSimpleText(
                                        "￥${priceFormat(data["num"] ?? 0)}",
                                        12,
                                        const Color(0xFFF93635))
                                  ], width: 375 - 20 * 2),
                                ),
                              );
                            }),
                            ghb(20)
                          ],
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getTopData(int index) {
    List datas =
        controller.mainData[controller.rankIdx == 0 ? "top10" : "luckyTop10"] ??
            [];

    Widget widget = centClm([
      getSimpleText(index <= datas.length - 1 ? datas[index]["u_Name"] : "", 14,
          const Color(0xFF5A2F0F),
          isBold: true),
      ghb(5),
      index <= datas.length - 1
          ? getSimpleText("￥${priceFormat(datas[index]["num"])}", 12,
              const Color(0xFFF93635))
          : ghb(0),
    ]);

    return Positioned(
        bottom: index == 1
            ? 20.5.w
            : index == 0
                ? 40.5.w
                : 20.5.w,
        left: index == 1 ? 43.w : null,
        right: index == 2 ? 43.w : null,
        width: index == 0 ? 375.w : null,
        child: Center(
          child: widget,
        ));
  }

  Positioned getHeadView(int index) {
    List datas =
        controller.mainData[controller.rankIdx == 0 ? "top10" : "luckyTop10"] ??
            [];
    // int dataIdx = index == 0 ?

    String avatar =
        index <= datas.length - 1 ? (datas[index]["u_Avatar"] ?? "") : "";
    return Positioned(
        width: index == 0 ? 76.w : 67.w,
        height: index == 0 ? 102.w : 89.w,
        top: index == 1
            ? 35.w
            : index == 0
                ? 0
                : 35.w,
        left: index == 1
            ? 34.5.w
            : index == 0
                ? ((375 - 76) / 2).w
                : null,
        right: index == 2 ? 34.w : null,
        child: Stack(
          children: [
            Positioned.fill(
                child: Image.asset(
              assetsName("bonuspool/tophead${index + 1}"),
              width: 76.w,
              height: 102.w,
              fit: BoxFit.fill,
            )),
            Positioned(
                bottom: 3.w,
                left: 3.w,
                right: 3.w,
                height: index == 0 ? 70.w : 61.w,
                child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(index == 1 ? 35.w : 30.5.w),
                    child: CustomNetworkImage(
                      src: AppDefault().imageUrl + avatar,
                      width: index == 0 ? 70.w : 61.w,
                      height: index == 0 ? 70.w : 61.w,
                      fit: BoxFit.cover,
                    )))
          ],
        ));
  }

  showTips(BuildContext context) {
    showGeneralDialog(
      barrierLabel: "",
      barrierDismissible: true,
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return UnconstrainedBox(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 330.w,
              height: 450.w,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.w)),
              child: Column(
                children: [
                  gwb(330),
                  SizedBox(
                    height: 69.5.w,
                    child: Center(
                      child: getSimpleText("奖励规则", 18, AppColor.text,
                          isBold: true),
                    ),
                  ),
                  SizedBox(
                    width: 298.w,
                    height: 450.w - 69.5.w - 73.w - 0.1.w,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 278.w,
                              child: HtmlWidget(
                                  controller.mainData["vcDesc"] ?? ""),
                            ),

//                             getWidthText(
//                                 ''' 1、每个用户自然月内累计有效交易够7万系统自动帮您获取1次奖金（比如累计交易够7万，系统自动帮您获取1次奖金；累计交易够14万，系统自动帮您再获取1次奖金），以此类推。

// 2、奖金池金额实时变动，每次领取奖金为实时奖金池金额的1%。（比如实时奖金池里有10000元，张某在09点0分累计有效交易够7万，李某在09点01分累计有效交易够7万；那么张某可以获取10000元的1%，也就是100元；李某获得剩下9900元的1%，也就是99元）。

// 3、当月签到一次后开启当月自动领取奖金功能，如果您当月没有签到，视为默认放弃当月交易达标对应获得的奖金。

// 4、每个用户每月最高领取2次奖金''', 15, AppColor.text2, 298, 1000)
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 73.w,
                    child: Center(
                      child: getSimpleButton(() {
                        Navigator.pop(context);
                      },
                          getSimpleText(
                            "我知道了",
                            15,
                            Colors.white,
                          ),
                          width: 300,
                          height: 40,
                          color: const Color(0xFFEE3931)),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
