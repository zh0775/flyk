import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyBillDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyBillDetailController>(MyBillDetailController());
  }
}

class MyBillDetailController extends GetxController {
  final _persionOrTeamIdx = 0.obs;
  int get persionOrTeamIdx => _persionOrTeamIdx.value;
  set persionOrTeamIdx(v) => _persionOrTeamIdx.value = v;

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  Map billDetailData = {};

  RefreshController pullCtrl = RefreshController();

  int pageSize = 20;
  int pageNo = 1;
  int count = 0;

  loadBillDetailData() {
    simpleRequest(
      url: Urls.userSubBillingShow,
      params: {"year": firstBillData["year"], "month": firstBillData["month"]},
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          billDetailData = data;
          update();
          pullCtrl.refreshCompleted();
        } else {
          pullCtrl.refreshFailed();
        }
      },
      after: () {},
    );
  }

  Map firstBillData = {};
  bool isFirst = true;
  dataInit(Map data) {
    if (!isFirst) return;
    isFirst = false;
    firstBillData = data;
    loadBillDetailData();
  }

  @override
  void dispose() {
    pullCtrl.dispose();
    super.dispose();
  }
}

class MyBillDetail extends GetView<MyBillDetailController> {
  final Map billData;
  const MyBillDetail({Key? key, required this.billData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(billData);
    return Scaffold(
      appBar: getDefaultAppBar(context, "详情"),
      body: SmartRefresher(
        physics: const BouncingScrollPhysics(),
        controller: controller.pullCtrl,
        onRefresh: controller.loadBillDetailData,
        child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: GetBuilder<MyBillDetailController>(
              init: controller,
              builder: (_) {
                return Column(
                  children: [
                    ghb(10),
                    gwb(375),
                    Container(
                        width: 345.w,
                        height: 100.w,
                        decoration: getDefaultWhiteDec(),
                        child: Align(
                          child: sbhRow([
                            centClm([
                              Text.rich(TextSpan(
                                  text: "￥",
                                  style: TextStyle(
                                      fontSize: 17.sp,
                                      fontWeight: AppDefault.fontBold,
                                      color: AppColor.textBlack),
                                  children: [
                                    TextSpan(
                                        text:
                                            priceFormat(billData["tolAmount"]),
                                        style: TextStyle(
                                            fontSize: 25.sp,
                                            fontWeight: AppDefault.fontBold,
                                            color: AppColor.textBlack))
                                  ])),
                              ghb(10),
                              getSimpleText(
                                  "结算日期：${billData["year"]}年${billData["month"] < 10 ? "0${billData["month"]}" : "${billData["month"]}"}月",
                                  15,
                                  AppColor.textBlack)
                            ], crossAxisAlignment: CrossAxisAlignment.start),
                          ], width: 345 - 15 * 2, height: 100),
                        )),
                    ghb(10),
                    Container(
                        width: 345.w,
                        decoration: getDefaultWhiteDec(),
                        child: GetX<MyBillDetailController>(
                          builder: (controller) {
                            return Column(
                              children: [
                                sbhRow([
                                  DropdownButton2(
                                    underline: ghb(0),
                                    customButton: centRow([
                                      getSimpleText(
                                          controller.persionOrTeamIdx == 0
                                              ? "自身交易金额"
                                              : "团队交易金额",
                                          15,
                                          AppColor.textBlack,
                                          isBold: true),
                                      gwb(3),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 20.w,
                                      ),
                                    ]),
                                    items: [
                                      DropdownMenuItem<int>(
                                          value: 0,
                                          child: Center(
                                            child: getSimpleText("自身交易金额", 15,
                                                AppColor.textBlack),
                                          )),
                                      DropdownMenuItem<int>(
                                          value: 1,
                                          child: Center(
                                            child: getSimpleText("团队交易金额", 15,
                                                AppColor.textBlack),
                                          )),
                                    ],
                                    value: controller.persionOrTeamIdx,
                                    buttonWidth: 70.w,
                                    buttonHeight: 50.w,
                                    itemHeight: 30.w,
                                    onChanged: (value) {
                                      controller.persionOrTeamIdx = value;
                                    },
                                    itemPadding: EdgeInsets.zero,
                                    dropdownWidth: calculateTextSize(
                                                "自身交易金额",
                                                15,
                                                FontWeight.normal,
                                                double.infinity,
                                                1,
                                                context)
                                            .width +
                                        30.w,
                                  ),
                                  Text.rich(
                                    TextSpan(
                                        text: "￥",
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            color: AppColor.textRed2,
                                            fontWeight: AppDefault.fontBold),
                                        children: [
                                          TextSpan(
                                              text: priceFormat(controller
                                                      .billDetailData[controller
                                                              .persionOrTeamIdx ==
                                                          0
                                                      ? "tolPersonAmount"
                                                      : "tolTeamAmount"] ??
                                                  0.0),
                                              style: TextStyle(
                                                  fontSize: 17.sp,
                                                  color: AppColor.textRed2,
                                                  fontWeight:
                                                      AppDefault.fontBold))
                                        ]),
                                  )
                                ], width: 345 - 15 * 2, height: 50),
                                personOrTeamData(controller.billDetailData[
                                        controller.persionOrTeamIdx == 0
                                            ? "personData"
                                            : "teamData"] ??
                                    []),
                              ],
                            );
                          },
                        )),
                    ghb(10),
                    Container(
                      width: 345.w,
                      decoration: getDefaultWhiteDec(),
                      child: rewardView(
                          controller.billDetailData["rewardList"] ?? []),
                    ),
                    ghb(90.5)
                  ],
                );
              },
            )),
      ),
    );
  }

  Widget personOrTeamData(List datas) {
    List<Widget> widgets = [];
    if (datas.isEmpty) {
      return ghb(0);
    }
    for (var e in datas) {
      widgets.add(
        sbhRow([
          titleText(e["tName"] ?? ""),
        ], width: 345 - 15 * 2, height: 55),
      );
      if (e["data"] != null && (e["data"] is List) && e["data"].isNotEmpty) {
        List<Widget> cells = [];
        for (var item in e["data"]) {
          cells.add(machineCell("${item["tradeType"] ?? ""}(元)",
              priceFormat(item["tradeAmount"] ?? 0)));
        }
        widgets.add(
          SizedBox(
            width: 300.w + 15.w,
            child: Wrap(
              runSpacing: 10.w,
              spacing: 15.w,
              children: cells,
            ),
          ),
        );
      }
    }
    return SizedBox(
      child: Column(
        children: [
          gline(345, 0.5),
          ...widgets,
          ghb(19.5),
        ],
      ),
    );
  }

  Widget rewardView(List datas) {
    List<Widget> widgets = [];
    if (datas.isEmpty) {
      return ghb(0);
    }
    for (var e in datas) {
      widgets
          .add(sbInfo(e["codeName"] ?? "", priceFormat(e["codeAmount"] ?? 0)));
      widgets.add(gline(345 - 15 * 2, 0.5));
    }
    if (controller.billDetailData["rewardSum"] != null) {
      widgets.add(sbInfo("${numToChinessNum(datas.length)}项总计(元)",
          priceFormat(controller.billDetailData["rewardSum"] ?? 0)));
      widgets.add(gline(345 - 15 * 2, 0.5));
    }
    if (controller.billDetailData["rewardTax"] != null) {
      widgets.add(sbInfo("${numToChinessNum(datas.length)}项税后(元)",
          priceFormat(controller.billDetailData["rewardTax"] ?? 0)));
      widgets.add(gline(345 - 15 * 2, 0.5));
    }
    return SizedBox(
      child: Column(
        children: [
          sbhRow([
            getSimpleText("其他明细", 15, AppColor.textBlack, isBold: true),
          ], width: 345 - 15 * 2, height: 50),
          gline(345, 0.5),
          ...widgets,
        ],
      ),
    );
  }

  Widget machineCell(String t1, String t2) {
    return Container(
        width: 150.w,
        height: 75.w,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.w),
            color: const Color(0xFFF5F9FC)),
        child: Center(
          child: sbRow([
            centClm([
              getSimpleText(t1, 13, AppColor.textGrey, isBold: true),
              ghb(8),
              getSimpleText(t2, 16, const Color(0xFF2C3135), isBold: true),
            ], crossAxisAlignment: CrossAxisAlignment.start)
          ], width: 150 - 12.5 * 2),
        ));
  }

  Widget sbInfo(String t1, String t2) {
    return sbhRow([
      getSimpleText(t1, 15, AppColor.textBlack),
      getSimpleText(t2, 15, AppColor.textBlack, isBold: true),
    ], width: 345 - 15 * 2, height: 60);
  }

  Widget titleText(String text) {
    Size size = calculateTextSize(text, 15, AppDefault.fontBold,
        double.infinity, 1, Global.navigatorKey.currentContext!);
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Stack(
        children: [
          Positioned(
              right: 0,
              bottom: 1.9.w,
              width: 22.5.w,
              height: 4.w,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1.w),
                    color: const Color(0xFF91BBFB)),
              )),
          Positioned.fill(
              child: getSimpleText(text, 15, AppColor.textBlack,
                  isBold: true, overflow: TextOverflow.clip)),
        ],
      ),
    );
  }
}
