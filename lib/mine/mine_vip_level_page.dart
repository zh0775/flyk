import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/information/information_detail.dart';
import 'package:cxhighversion2/mine/mine_vip_leval_explain.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MineVipLevelPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineVipLevelPageController>(MineVipLevelPageController());
  }
}

class MineVipLevelPageController extends GetxController {
  final _btnIndex = 0.obs;
  int get btnIndex => _btnIndex.value;
  set btnIndex(v) {
    _btnIndex.value = v;
    update([dataBuildId]);
  }

  DateFormat dateFormat = DateFormat("yyyy/MM");
  String year = "";
  String lastMonth = "";
  Map homeData = {};
  Map dealData = {};
  Map publicHomeData = {};
  Map levelInfo = {};

  final _myLevel = 7.obs;
  int get myLevel => _myLevel.value;
  set myLevel(v) => _myLevel.value = v;
  // Map data = {};
  // Map tData = {};
  String dataBuildId = "MineVipLevelPage_dataBuildId";
  loadEnum() {
    simpleRequest(
      url: Urls.teamColEnum,
      params: {},
      success: (success, json) {
        if (success) {
          loadData();
        }
      },
      after: () {},
    );
  }

  List helpConfigList = [];

  Map currentLevalData = {};

  loadData() {
    simpleRequest(
      url: Urls.userShareProfitLevelInfoData,
      params: {
        // "timeType": 1,
        // "pageNo": 1,
        // "pageSize": 2,
        // "soleTeamType": btnIndex + 1
      },
      success: (success, json) {
        levelInfo = json["data"] ?? {};
        if (success) {
          dealData = levelInfo["statistics"] ?? {};
          myLevel = levelInfo["userLevel"] ?? 1;
          helpConfigList = levelInfo["ulc_helpConfigList"] ?? [];
          currentLevalData = helpConfigList.length >= myLevel - 1
              ? helpConfigList[myLevel - 1]
              : {};
          // if (e["data"] != null && e["data"].isNotEmpty) {
          //   for (var item in e["data"]) {
          //     if (item["month"] == int.parse(lastMonth)) {
          //       btnIndex == 0 ? data = item : tData = item;
          //       break;
          //     }
          //   }
          // }
          update([dataBuildId]);
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    // dealData = homeData["homeTeamTanNo"];
    publicHomeData = AppDefault().publicHomeData;
    DateTime date = DateTime.now();
    late DateTime lastMonthDate;
    if (date.month == 1) {
      lastMonthDate = DateTime(date.year - 1, 12);
    } else {
      lastMonthDate = DateTime(date.year, date.month - 1);
    }
    year = lastMonthDate.year.toString();
    lastMonth = lastMonthDate.month.toString();
    if (int.parse(lastMonth) < 10) {
      lastMonth = "0$lastMonth";
    }

    // loadEnum();
    loadData();

    super.onInit();
  }
}

class MineVipLevelPage extends GetView<MineVipLevelPageController> {
  const MineVipLevelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "会员等级", action: [
        CustomButton(
          onPressed: () {
            if (controller.levelInfo.isEmpty) {
              ShowToast.normal("请等待数据请求完毕");
              return;
            }
            push(
                MineVipLevalExplain(
                  level: controller.myLevel,
                  currentLevelData: controller.currentLevalData,
                  levelInfo: controller.levelInfo,
                ),
                context,
                binding: MineVipLevalExplainBinding());
          },
          child: SizedBox(
            width: 65.w,
            height: kToolbarHeight,
            child: Center(
              child: getSimpleText("说明", 14, AppColor.textBlack),
            ),
          ),
        )
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            ghb(19.5),
            GetBuilder<MineVipLevelPageController>(
              id: controller.dataBuildId,
              init: controller,
              builder: (_) {
                return Container(
                  width: 345.w,
                  height: 150.5.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                        colors: [Color(0xFF1F2022), Color(0xFF59595D)]),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: centClm(
                    [
                      sbRow([
                        centClm([
                          getSimpleText(
                              "${controller.levelInfo["userLevelName"] ?? "等级"}会员",
                              23,
                              Colors.white,
                              isBold: true),
                          ghb(8),
                        ]),
                        controller.currentLevalData.isNotEmpty
                            ? CustomNetworkImage(
                                src: AppDefault().imageUrl +
                                    (controller.currentLevalData["logo"] ?? ""),
                                height: 78.5.w,
                                fit: BoxFit.fitHeight,
                              )
                            : gwb(0),
                      ], width: 345 - 20.5 * 2),
                    ],
                  ),
                );
                // Image.asset(
                //   assetsName("mine/vip/bg_vip${controller.myLevel}"),
                //   width: 345.w,
                //   fit: BoxFit.fitWidth,
                // );
              },
            ),
            ghb(20),
            Container(
                width: 345.w,
                decoration: getDefaultWhiteDec(),
                child: Column(
                  children: [
                    SizedBox(
                        height: 60.w,
                        child: Center(
                          child: getSimpleText("上月交易数据", 17, AppColor.textBlack,
                              isBold: true),
                        )),
                    // sbhRow([
                    //   getSimpleText("上月交易数据", 17, AppColor.textBlack,
                    //       isBold: true)
                    // ], width: 345, height: 60),
                    gline(315, 0.5),
                    GetX<MineVipLevelPageController>(
                      init: controller,
                      builder: (_) {
                        return centRow(
                            [personOrTeam(0), gline(0.5, 15), personOrTeam(1)]);
                      },
                    ),
                    Container(
                      width: 315.w,
                      color: const Color(0xFFEDEDED),
                      child: GetBuilder<MineVipLevelPageController>(
                        init: controller,
                        id: controller.dataBuildId,
                        initState: (_) {},
                        builder: (_) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ghb(2),
                              sbhRow([
                                getRichText(
                                    "${controller.year}/",
                                    controller.lastMonth,
                                    12,
                                    AppColor.textBlack,
                                    17,
                                    AppColor.textBlack,
                                    fw2: AppDefault.fontBold)
                              ], height: 14 + 16 * 2, width: 315 - 11.5 * 2),
                              infoCell("交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["soleLastMAmount"] ?? 0) : priceFormat(controller.dealData["teamLastMAmount"] ?? 0)}元"),
                              infoCell("交易笔数",
                                  "${controller.btnIndex == 0 ? controller.dealData["soleLastMCount"] ?? 0 : controller.dealData["teamLastMCount"] ?? 0}笔"),
                              infoCell("贷记卡交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["sole_LastM_TradeType1_Amount"] ?? 0) : priceFormat(controller.dealData["team_LastM_TradeType1_Amount"] ?? 0)}元"),
                              infoCell("借记卡交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["sole_LastM_TradeType2_Amount"] ?? 0) : priceFormat(controller.dealData["team_LastM_TradeType2_Amount"] ?? 0)}元"),
                              infoCell("微信交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["sole_LastM_TradeType5_Amount"] ?? 0) : priceFormat(controller.dealData["team_LastM_TradeType5_Amount"] ?? 0)}元"),
                              infoCell("支付宝交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["sole_LastM_TradeType4_Amount"] ?? 0) : priceFormat(controller.dealData["team_LastM_TradeType4_Amount"] ?? 0)}元"),
                              infoCell("其他类交易额",
                                  "${controller.btnIndex == 0 ? priceFormat(controller.dealData["sole_LastM_TradeType7_Amount"] ?? 0) : priceFormat(controller.dealData["team_LastM_TradeType7_Amount"] ?? 0)}元"),
                              infoCell("新增盟友数",
                                  "${controller.btnIndex == 0 ? controller.dealData["soleLastMAddUser"] ?? 0 : controller.dealData["teamLastMAddUser"] ?? 0}人"),
                              infoCell("新增商户数",
                                  "${controller.btnIndex == 0 ? controller.dealData["soleLastMAddMerchant"] ?? 0 : controller.dealData["teamLastMAddMerchant"] ?? 0}户"),
                              ghb(7),
                            ],
                          );
                        },
                      ),
                    ),

                    CustomButton(
                      onPressed: () {
                        push(
                            const InformationDetail(
                              infoType: 0,
                            ),
                            context,
                            binding: InformationDetailBinding());
                      },
                      child: SizedBox(
                        width: 345.w,
                        height: 40.5.w,
                        child: Center(
                          child: getSimpleText(
                              "查看更多数据", 14, const Color(0xFF808080)),
                        ),
                      ),
                    ),
                  ],
                )),
            ghb(83)
          ],
        ),
      ),
    );
  }

  Widget infoCell(String title, String content) {
    return sbhRow([
      getSimpleText(title, 13, AppColor.textGrey2),
      getSimpleText(content, 13, AppColor.textBlack),
    ], width: 315 - 11.5 * 2, height: 28.5);
  }

  Widget personOrTeam(int index) {
    return CustomButton(
      onPressed: () {
        controller.btnIndex = index;
      },
      child: SizedBox(
        width: 315.w / 2,
        height: 49.w,
        child: Center(
          child: getSimpleText(
              "${index == 0 ? "个人" : "团队"}数据",
              15,
              controller.btnIndex == index
                  ? AppColor.textBlack
                  : AppColor.textGrey),
        ),
      ),
    );
  }
}
