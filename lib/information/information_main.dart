import 'dart:convert' as convert;

import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/information/data_standard_detail.dart';
import 'package:cxhighversion2/information/information_detail.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/storage_default.dart';
import 'package:cxhighversion2/util/user_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class InformationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InformationMainController>(() => InformationMainController());
  }
}

class InformationMainController extends GetxController {
  final _cardOpen = false.obs;
  bool get cardOpen => _cardOpen.value;
  set cardOpen(v) => _cardOpen.value = v;

  final _topIndex = 1.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      currentInfoData = infoData[topIndex];
      update();
    }
  }

  final _showCardValue = true.obs;
  bool get showCardValue => _showCardValue.value;
  set showCardValue(v) => _showCardValue.value = v;

  final _mainInformationIndex = 0.obs;
  set mainInformationIndex(value) {
    _mainInformationIndex.value = value;
    update([performanceTotalId]);
  }

  get mainInformationIndex => _mainInformationIndex.value;

  final _informationType = 0.obs;
  set informationType(value) => _informationType.value = value;
  get informationType => _informationType.value;

  Map homeData = {};
  Map publicHomeData = {};
  String imageUrl = "";

  Map infoData = {0: {}, 1: {}, 2: {}};
  Map currentInfoData = {};

  String performanceTotalId = "performanceTotalId";

  @override
  void onInit() async {
    needUpdate();
    bus.on(USER_LOGIN_NOTIFY, getNotify);
    bus.on(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.on(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onInit();
  }

  getNotify(arg) {
    needUpdate();
  }

  Map homeTeamTanNo = {};
  needUpdate() async {
    String homeDataStr = await UserDefault.get(HOME_DATA) ?? "";
    homeData = homeDataStr.isNotEmpty ? convert.jsonDecode(homeDataStr) : {};
    homeTeamTanNo = homeData["homeTeamTanNo"] ?? {};
    String publicHomeDataStr = await UserDefault.get(PUBLIC_HOME_DATA) ?? "";
    publicHomeData = publicHomeDataStr.isNotEmpty
        ? convert.jsonDecode(publicHomeDataStr)
        : {};
    Map bData = (homeData["homeBouns"] ?? {})["bounsData"] ?? {};
    Map tData = homeData["homeTeamTanNo"] ?? {};
    infoData = {
      0: {
        "allSy": bData["totalChanBouns"] ?? 0,
        "todaySy": bData["thisDChanBouns"] ?? 0,
        "lastDaySy": bData["lastDChanBouns"] ?? 0,
        "monSy": bData["thisMChanBouns"] ?? 0,
        "lastMonSy": bData["lastMChanBouns"] ?? 0,
        "cData": [
          tData["teamTotalBindChanTerminal"] ?? 0,
          tData["totalAddChanUser"] ?? 0,
          tData["teamTotalChanAmount"] ?? 0,
          tData["totalActChanTerminal"] ?? 0,
          tData["totalAddChanMerchant"] ?? 0,
          tData["TotalNobindChanTerminal"] ?? 0,
        ]
      },
      1: {
        "allSy": bData["totalBouns"] ?? 0,
        "todaySy": bData["thisDBouns"] ?? 0,
        "lastDaySy": bData["lastDBouns"] ?? 0,
        "monSy": bData["thisMBouns"] ?? 0,
        "lastMonSy": bData["lastMBouns"] ?? 0,
        "cData": [
          tData["teamTotalBindTerminal"] ?? 0,
          tData["teamTotalAddUser"] ?? 0,
          tData["teamTotalAmount"] ?? 0,
          tData["teamTotalActTerminal"] ?? 0,
          tData["teamTotalAddMerchant"] ?? 0,
          tData["teamTotalNobindTerminal"] ?? 0,
        ]
      },
      2: {
        "allSy": bData["totalSelfBouns"] ?? 0,
        "todaySy": bData["thisDSelfBouns"] ?? 0,
        "lastDaySy": bData["lastDSelfBouns"] ?? 0,
        "monSy": bData["thisMSelfBouns"] ?? 0,
        "lastMonSy": bData["lastMSelfBouns"] ?? 0,
        "cData": [
          tData["teamTotalBindSelfTerminal"] ?? 0,
          tData["soleTotalAddUser"] ?? 0,
          tData["soleTotalAmount"] ?? 0,
          tData["soleTotalActTerminal"] ?? 0,
          tData["soleTotalAddMerchant"] ?? 0,
          tData["soleTotalNobindTerminal"] ?? 0,
        ]
      },
    };
    currentInfoData = infoData[topIndex];
    dataFormat();
  }

  // @override
  // void onReady() {
  //   homeRequest({}, (success) {});
  //   super.onReady();
  // }
  dataFormat() {
    imageUrl = AppDefault().imageUrl;
    update();
  }

  @override
  void onClose() {
    bus.off(USER_LOGIN_NOTIFY, getNotify);
    bus.off(HOME_DATA_UPDATE_NOTIFY, getNotify);
    bus.off(HOME_PUBLIC_DATA_UPDATE_NOTIFY, getNotify);
    super.onClose();
  }
}

class InformationMain extends StatefulWidget {
  const InformationMain({Key? key}) : super(key: key);

  @override
  State<InformationMain> createState() => _InformationMainState();
}

class _InformationMainState extends State<InformationMain>
    with AutomaticKeepAliveClientMixin {
  // InformationMainController controller = Get.find<InformationMainController>();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        // appBar: getMainAppBar(1),
        body: CustomBackground(
          child: Stack(
            children: [
              // Positioned(
              //     top: 0,
              //     left: 0,
              //     child: Container(
              //       width: 375.w,
              //       height: 250.w,
              //       color: AppColor.theme,
              //     )),
              Positioned.fill(
                  top: paddingSizeTop(context) + 10.w,
                  child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: GetBuilder<InformationMainController>(
                        init: InformationMainController(),
                        // init: controller,
                        builder: (controller) {
                          return Column(
                            children: [
                              // ghb(22),
                              sbRow([
                                getSimpleText(
                                    "数据",
                                    20,
                                    AppDefault().getThemeColor() ??
                                        AppColor.theme),
                                GetX<InformationMainController>(
                                  builder: (_) {
                                    List indexs = [
                                      controller.topIndex - 1 >= 0
                                          ? controller.topIndex - 1
                                          : 2,
                                      controller.topIndex,
                                      controller.topIndex + 1 > 2
                                          ? 0
                                          : controller.topIndex + 1
                                    ];
                                    return centRow(List.generate(
                                      3,
                                      (index) => Padding(
                                        padding: EdgeInsets.only(
                                            left: index != 0 ? 7.w : 0),
                                        child: topBtn(indexs[index]),
                                      ),
                                    ));
                                  },
                                )
                              ],
                                  width: 345,
                                  crossAxisAlignment: CrossAxisAlignment.start),
                              ghb(23),
                              getDefaultTilte("收益统计"),
                              ghb(15),
                              GetBuilder<InformationMainController>(
                                builder: (_) {
                                  return GetX<InformationMainController>(
                                    builder: (_) {
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        width: 345.w,
                                        height:
                                            controller.cardOpen ? 253.w : 168.w,
                                        // decoration: BoxDecoration(
                                        //     image: DecorationImage(
                                        //         colorFilter: ColorFilter.mode(
                                        //             AppDefault().getThemeColor() ??
                                        //                 Colors.white,
                                        //             BlendMode.modulate),
                                        //         image: AssetImage(
                                        //             assetsName("pay/bg_earn_card")),
                                        //         fit: BoxFit.fill)),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                                child: Container(
                                              decoration: BoxDecoration(
                                                  color: AppDefault()
                                                          .getThemeColor() ??
                                                      AppColor.theme,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.w)),
                                            )),
                                            Positioned.fill(
                                                child: Image.asset(
                                              assetsName("pay/bg_earn_card"),
                                              fit: BoxFit.fill,
                                            )),
                                            Positioned.fill(
                                              child: SingleChildScrollView(
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    centClm([
                                                      ghb(20),
                                                      sbRow([
                                                        centClm([
                                                          centRow([
                                                            getSimpleText(
                                                                "总收益（元）",
                                                                12,
                                                                Colors.white),
                                                            CustomButton(
                                                              onPressed: () {
                                                                controller
                                                                        .showCardValue =
                                                                    !controller
                                                                        .showCardValue;
                                                              },
                                                            )
                                                          ]),
                                                          ghb(5),
                                                          getSimpleText(
                                                              priceFormat(controller
                                                                          .currentInfoData[
                                                                      "allSy"] ??
                                                                  0),
                                                              28,
                                                              Colors.white,
                                                              fw: FontWeight
                                                                  .w500),
                                                        ],
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start),
                                                        CustomButton(
                                                          onPressed: () {
                                                            push(
                                                                DataStandardDetail(
                                                                  index: controller
                                                                      .topIndex,
                                                                  type:
                                                                      DataStandardDetailType
                                                                          .earn,
                                                                  performData:
                                                                      controller
                                                                          .infoData,
                                                                ),
                                                                context,
                                                                binding:
                                                                    DataStandardDetailBinding());
                                                          },
                                                          child: Container(
                                                            width: 82.w,
                                                            height: 28.w,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0x7FFFFFFF),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          14.w),
                                                              border: Border.all(
                                                                  width: 0.5.w,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                            child: Center(
                                                              child:
                                                                  getSimpleText(
                                                                      "查看详情",
                                                                      13,
                                                                      Colors
                                                                          .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                          width: 345 - 18 * 2,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start),
                                                      ghb(21),
                                                      centRow([
                                                        SizedBox(
                                                          width: (345 / 2 -
                                                                  0.1 -
                                                                  0.35)
                                                              .w,
                                                          child: Row(
                                                            children: [
                                                              gwb(20),
                                                              centClm([
                                                                getSimpleText(
                                                                    "今日收益（元）",
                                                                    12,
                                                                    Colors
                                                                        .white),
                                                                ghb(3),
                                                                getSimpleText(
                                                                    "+${priceFormat(controller.currentInfoData["todaySy"] ?? 0)}",
                                                                    18,
                                                                    Colors
                                                                        .white,
                                                                    fw: FontWeight
                                                                        .w500)
                                                              ],
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start)
                                                            ],
                                                          ),
                                                        ),
                                                        gline(0.70, 20,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(
                                                          width: (345 / 2 -
                                                                  0.1 -
                                                                  0.35)
                                                              .w,
                                                          child: Row(
                                                            children: [
                                                              gwb(20),
                                                              centClm([
                                                                getSimpleText(
                                                                    "昨日收益（元）",
                                                                    12,
                                                                    Colors
                                                                        .white),
                                                                ghb(3),
                                                                getSimpleText(
                                                                    "+${priceFormat(controller.currentInfoData["lastDaySy"] ?? 0)}",
                                                                    18,
                                                                    Colors
                                                                        .white,
                                                                    fw: FontWeight
                                                                        .w500)
                                                              ],
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start)
                                                            ],
                                                          ),
                                                        ),
                                                      ]),
                                                      controller.cardOpen
                                                          ? Column(
                                                              children: [
                                                                ghb(16),
                                                                gline(294, 1,
                                                                    color: Colors
                                                                        .white),
                                                                ghb(21),
                                                                centRow([
                                                                  SizedBox(
                                                                    width: (345 /
                                                                                2 -
                                                                            0.1 -
                                                                            0.35)
                                                                        .w,
                                                                    child: Row(
                                                                      children: [
                                                                        gwb(20),
                                                                        centClm([
                                                                          getSimpleText(
                                                                              "本月收益（元）",
                                                                              12,
                                                                              Colors.white),
                                                                          ghb(3),
                                                                          getSimpleText(
                                                                              "+${priceFormat(controller.currentInfoData["monSy"] ?? 0)}",
                                                                              18,
                                                                              Colors.white,
                                                                              fw: FontWeight.w500)
                                                                        ], crossAxisAlignment: CrossAxisAlignment.start)
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  gline(
                                                                      0.70, 20,
                                                                      color: Colors
                                                                          .white),
                                                                  SizedBox(
                                                                    width: (345 /
                                                                                2 -
                                                                            0.1 -
                                                                            0.35)
                                                                        .w,
                                                                    child: Row(
                                                                      children: [
                                                                        gwb(20),
                                                                        centClm([
                                                                          getSimpleText(
                                                                              "上月收益（元）",
                                                                              12,
                                                                              Colors.white),
                                                                          ghb(3),
                                                                          getSimpleText(
                                                                              "+${priceFormat(controller.currentInfoData["lastMonSy"] ?? 0)}",
                                                                              18,
                                                                              Colors.white,
                                                                              fw: FontWeight.w500)
                                                                        ], crossAxisAlignment: CrossAxisAlignment.start)
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ]),
                                                              ],
                                                            )
                                                          : ghb(0)
                                                    ]),
                                                    ghb(7),
                                                    CustomButton(
                                                      onPressed: () {
                                                        controller.cardOpen =
                                                            !controller
                                                                .cardOpen;
                                                      },
                                                      child: SizedBox(
                                                        width: 345.w,
                                                        height: 23.w,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: Image.asset(
                                                            assetsName(
                                                                "pay/icon_${controller.cardOpen ? "up" : "down"}_arrow_white"),
                                                            width: 16.w,
                                                            height: 16.w,
                                                            // height: 14.w,
                                                            fit: BoxFit.fill,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),

                              ghb(20),
                              getDefaultTilte("业绩统计",
                                  rightWidget: CustomButton(
                                    onPressed: () {
                                      push(
                                          DataStandardDetail(
                                            index: controller.topIndex,
                                            type: DataStandardDetailType
                                                .performance,
                                            performData: controller.infoData,
                                          ),
                                          context,
                                          binding: DataStandardDetailBinding());
                                    },
                                    child: centRow([
                                      getSimpleText(
                                          "查看详情", 14, const Color(0xFF606366)),
                                      gwb(8),
                                      Image.asset(
                                        assetsName("pay/icon_arrow_right_gray"),
                                        height: 8.5.w,
                                        fit: BoxFit.fitHeight,
                                      )
                                    ]),
                                  )),
                              ghb(15),
                              ...tjWidgetList(
                                  controller.currentInfoData["cData"] ?? [],
                                  controller),
                              // GetX<InformationMainController>(
                              //   init: controller,
                              //   builder: (_) {
                              //     return Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       children: [
                              //         personOrTimeButton(0, _),
                              //         gwb(25),
                              //         personOrTimeButton(1, _),
                              //       ],
                              //     );
                              //   },
                              // ),
                              // ghb(8),
                              // GetBuilder<InformationMainController>(
                              //   id: controller.performanceTotalId,
                              //   init: controller,
                              //   builder: (_) {
                              //     return inforMationAtAll();
                              //   },
                              // ),
                              // ghb(8),
                              // Container(
                              //   padding:
                              //       EdgeInsets.symmetric(vertical: 12.w, horizontal: 25.w),
                              //   width: 345.w,
                              //   decoration: getDefaultWhiteDec(),
                              //   child: sbRow([
                              //     detailButton(0, "交易明细", context),
                              //     detailButton(1, "激活明细", context),
                              //     detailButton(2, "商户明细", context),
                              //     detailButton(3, "伙伴明细", context),
                              //   ]),
                              // ),
                              // ghb(8),
                              // GetBuilder<InformationMainController>(
                              //   init: controller,
                              //   builder: (_) {
                              //     return RecentData(
                              //       recentDataType: RecentDataType.personally,
                              //       data: controller.homeData.isNotEmpty
                              //           ? controller.homeTeamTanNo
                              //           : {},
                              //     );
                              //   },
                              // ),
                              ghb(16),
                              // const AppBottomTips(),
                            ],
                          );
                        },
                      )))
            ],
          ),
        ),
      ),
    );
  }

  Widget topBtn(int index) {
    return GetX<InformationMainController>(
      builder: (controller) {
        return CustomButton(
          onPressed: () {
            if (controller.topIndex == index) {
              controller.topIndex + 1 > 2
                  ? controller.topIndex = 0
                  : controller.topIndex++;
            } else {
              controller.topIndex = index;
            }
          },
          child: centClm([
            getSimpleText(
                index == 0
                    ? "渠道"
                    : index == 1
                        ? "总览"
                        : "自营",
                controller.topIndex == index ? 18 : 14,
                controller.topIndex == index
                    ? AppColor.textBlack3
                    : const Color(0xFF8A9199)),
            Visibility(
                visible: controller.topIndex == index,
                child: centClm([
                  ghb(2),
                  Container(
                    width: 37.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                        color: AppDefault().getThemeColor() ?? AppColor.theme),
                  )
                ]))
          ]),
        );
      },
    );
  }

  List<Widget> tjWidgetList(List datas, InformationMainController controller) {
    List<Widget> widgets = [];
    for (var i = 0; i < datas.length; i++) {
      var e = datas[i];
      String img = "pay/icon_infocell_bdsb";
      String title = "";
      String subTitle = "";
      String data = "${e ?? ""}";
      String unit = "";
      switch (i) {
        case 0:
          img = img.replaceRange(img.length - 4, img.length, "bdsb");
          title = "绑定设备";
          subTitle = "EQUIPMENT";
          // data = "123";
          unit = "台";
          break;
        case 1:
          img = img.replaceRange(img.length - 4, img.length, "hyrs");
          title = "会员人数";
          subTitle = "MEMBER";
          // data = "123";
          unit = "人";
          break;
        case 2:
          img = img.replaceRange(img.length - 4, img.length, "jyje");
          title = "交易金额";
          subTitle = "TRADE";
          // data = "123";
          unit = "元";
          break;
        case 3:
          img = img.replaceRange(img.length - 4, img.length, "jjjh");
          title = "机具激活";
          subTitle = "MACHINERY";
          // data = "123";
          unit = "台";

          break;
        case 4:
          img = img.replaceRange(img.length - 4, img.length, "sysh");
          title = "使用商户";
          subTitle = "MACHINERY";
          // data = "123";
          unit = "户";
          break;
        case 5:
          img = img.replaceRange(img.length - 4, img.length, "wbdsb");
          title = "未绑定设备";
          subTitle = "EQUIPMENT";
          // data = "123";
          unit = "台";
          break;
      }
      widgets.add(CustomButton(
        onPressed: () {
          push(
              DataStandardDetail(
                index: controller.topIndex,
                type: DataStandardDetailType.performance,
                performData: controller.infoData,
                performIndex: i + 1,
              ),
              context,
              binding: DataStandardDetailBinding());
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 8.w),
          width: 345.w,
          height: 88.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [
              Color(0xFFEBF3F7),
              Color(0xFFFAFAFA),
            ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(width: 1.w, color: Colors.white),
          ),
          child: Align(
            child: sbhRow([
              centRow([
                Padding(
                  padding:
                      EdgeInsets.only(left: img.contains("sysh") ? 9.w : 0),
                  child: Image.asset(
                    assetsName(img),
                    width: img.contains("sysh") ? 28.w : 44.w,
                    height: img.contains("sysh") ? 28.w : 44.w,
                    fit: BoxFit.fill,
                  ),
                ),
                gwb(img.contains("sysh") ? 17 : 11),
                centClm([
                  getSimpleText(title, 16, AppColor.textBlack3),
                  ghb(3),
                  getSimpleText(subTitle, 12, const Color(0xFFBCC1CC),
                      fw: FontWeight.w500)
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ]),
              getRichText("$data ", unit, 20, AppColor.textBlack3, 12,
                  const Color(0xFF606366),
                  fw: FontWeight.w500)
            ], width: 345 - 16 * 2, height: 88),
          ),
        ),
      ));
    }
    return widgets;
  }

  Widget personOrTimeButton(int idx, InformationMainController imCtrl) {
    return CustomButton(
      onPressed: () {
        if (idx != imCtrl.mainInformationIndex) {
          imCtrl.mainInformationIndex = idx;
        }
      },
      child: Container(
        width: 89.w,
        height: 34.w,
        decoration: BoxDecoration(
            color: idx == imCtrl.mainInformationIndex
                ? Colors.white
                : AppDefault().getThemeColor() ?? AppColor.theme,
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: getSimpleText(
            "${idx == 0 ? "个人" : "团队"}业绩",
            15,
            idx == imCtrl.mainInformationIndex
                ? (AppDefault().getThemeColor() ?? AppColor.theme)
                : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget inforMationAtAll(InformationMainController controller) {
    return Container(
      width: 345.w,
      height: 262.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      child: Column(
        children: [
          ghb(66),
          infoData(
              1,
              "交易总额(元)",
              controller.homeData.isNotEmpty
                  ? (controller.mainInformationIndex == 0
                      ? priceFormat(
                          controller.homeTeamTanNo["soleTotalAmount"] ?? 0)
                      : priceFormat(
                          controller.homeTeamTanNo["teamTotalAmount"] ?? 0))
                  : "0"),
          ghb(42),
          centRow([
            infoData(
                2,
                "伙伴汇总(人)",
                controller.homeData.isNotEmpty
                    ? (controller.mainInformationIndex == 0
                        ? "${controller.homeTeamTanNo["soleTotalAddUser"] ?? 0}"
                        : "${controller.homeTeamTanNo["teamTotalAddUser"] ?? 0}")
                    : "0"),
            gwb(32.5),
            infoData(
                2,
                "商户汇总(户)",
                controller.homeData.isNotEmpty
                    ? (controller.mainInformationIndex == 0
                        ? "${controller.homeTeamTanNo["soleTotalAddMerchant"] ?? 0}"
                        : "${controller.homeTeamTanNo["teamTotalAddMerchant"] ?? 0}")
                    : "0"),
            gwb(32.5),
            infoData(
                2,
                "激活汇总(台)",
                controller.homeData.isNotEmpty
                    ? (controller.mainInformationIndex == 0
                        ? "${controller.homeTeamTanNo["soleTotalActTerminal"] ?? 0}"
                        : "${controller.homeTeamTanNo["teamTotalActTerminal"] ?? 0}")
                    : "0"),
          ])
        ],
      ),
    );
  }

  Widget infoData(int level, String title, String souce) {
    return centClm([
      getSimpleText(title, level == 1 ? 15 : 12, AppColor.textBlack),
      ghb(10),
      getSimpleText(souce, level == 1 ? 29 : 20, AppColor.textBlack,
          isBold: true),
    ]);
  }

  Widget detailButton(int idx, String title, BuildContext context) {
    String img = "pay/btn_jymx";
    switch (idx) {
      case 0:
        img = "pay/btn_jymx";
        break;
      case 1:
        img = "pay/btn_jhmx";
        break;
      case 2:
        img = "pay/btn_shmx";
        break;
      case 3:
        img = "pay/btn_hbmx";
        break;
      default:
    }

    return CustomButton(
        onPressed: () {
          // if (idx == 0 || idx == 1) {
          push(
              InformationDetail(
                infoType: idx,
              ),
              context,
              binding: InformationDetailBinding());
          // }
        },
        child: centClm([
          Image.asset(
            assetsName(img),
            height: 25.w,
            fit: BoxFit.fitHeight,
          ),
          ghb(8),
          getSimpleText(title, 12, AppColor.textBlack),
        ]));
  }

  @override
  bool get wantKeepAlive => true;
}
