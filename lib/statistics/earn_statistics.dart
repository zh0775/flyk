import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EarnStatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<EarnStatisticsController>(EarnStatisticsController());
  }
}

class EarnStatisticsController extends GetxController {
  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  CustomDropDownController dropDownCtrl = CustomDropDownController();

  int pieSectionIndex = -1;

  List tableTitles = ["名称", "分润收益", "扫码收益", "奖励收益", "其他收益"];

  List colors = [
    "FF437BFE",
    "FFF9C529",
    "FF3AD3D2",
    "FFFF7544",
    "FFF93635",
  ];

  Map currentData = {};

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      loadData();
    }
  }

  final _filterIndex = (-1).obs;
  int get filterIndex => _filterIndex.value;
  set filterIndex(v) {
    if (_filterIndex.value != v) {
      _filterIndex.value = v;
      changeDate();
    }
  }

  int realFilterIdx = -1;

  final _startDate = "".obs;
  String get startDate => _startDate.value;
  set startDate(v) => _startDate.value = v;

  final _endDate = "".obs;
  String get endDate => _endDate.value;
  set endDate(v) => _endDate.value = v;

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  List<Map> dataList = [{}, {}, {}];

  loadData({String? start, String? end}) {
    // changeData();

    if (dataList[topIndex].isEmpty) {
      isLoading = true;
    }

    Map<String, dynamic> params = {
      "teamType": topIndex,
    };
    if (start == null && end == null) {
      params["typeTime"] = 0;
    }
    if (start != null && start.isNotEmpty) {
      params["startingTime"] = start;
    }

    if (end != null && end.isNotEmpty) {
      params["end_Time"] = end;
    }

    simpleRequest(
        url: Urls.userIncomeStatisticsList,
        params: params,
        success: (success, json) {
          // if (success) {
          Map data = json["data"] ?? {};
          dataList[topIndex] = data;
          update();
          // }
        },
        after: () {
          isLoading = false;
        },
        useCache: params["typeTime"] != null && params["typeTime"] == 0);
  }

  changeDate() {
    if (filterIndex == -1) {
      startDate = "";
      endDate = "";
      return;
    }
    DateTime now = DateTime.now();
    endDate = dateFormat.format(now);
    if (filterIndex == 0) {
      startDate = endDate;
    } else if (filterIndex == 1) {
      startDate = dateFormat.format(now.subtract(const Duration(days: 7)));
    } else if (filterIndex == 2) {
      startDate = dateFormat.format(now.subtract(const Duration(days: 30)));
    }
  }

  confirmCheck() {
    realFilterIdx = filterIndex;
    dropDownCtrl.hide();
    if (realFilterIdx != -1) {
      loadData(start: startDate, end: endDate);
    } else {
      loadData();
    }
  }

  resetCheck() {
    filterIndex = -1;
    realFilterIdx = -1;
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    dropDownCtrl.dispose();
    super.onClose();
  }
}

class EarnStatistics extends GetView<EarnStatisticsController> {
  const EarnStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "收益统计", action: [
        CustomButton(
          onPressed: () {
            if (controller.dropDownCtrl.isShow) {
              controller.dropDownCtrl.hide();
            } else {
              controller.dropDownCtrl
                  .show(controller.stackKey, controller.headKey);
            }
          },
          child: SizedBox(
            width: 80.w,
            height: kToolbarHeight,
            child: centRow([
              Image.asset(
                assetsName("common/btn_filter"),
                width: 24.w,
                fit: BoxFit.fitWidth,
              ),
              gwb(2),
              getSimpleText("筛选", 14, AppColor.text),
            ]),
          ),
        )
      ]),
      body: Stack(
        key: controller.stackKey,
        children: [
          Positioned(
              key: controller.headKey,
              top: 0,
              left: 0,
              right: 0,
              height: 55.w,
              child: Container(
                color: Colors.white,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(
                        3,
                        (index) => CustomButton(
                              onPressed: () {
                                if (controller.dropDownCtrl.isShow) {
                                  controller.dropDownCtrl.hide();
                                  return;
                                }
                                controller.topIndex = index;
                              },
                              child: SizedBox(
                                  width: 375.w / 3 - 0.1.w,
                                  child: GetX<EarnStatisticsController>(
                                    builder: (_) {
                                      return centClm([
                                        ghb(10),
                                        getSimpleText(
                                            index == 0
                                                ? "数据总览"
                                                : index == 1
                                                    ? "自营数据"
                                                    : "团队数据",
                                            15,
                                            controller.topIndex == index
                                                ? AppColor.text
                                                : AppColor.text3,
                                            isBold:
                                                controller.topIndex == index),
                                        ghb(6),
                                        Container(
                                          width: 15.w,
                                          height: 2.w,
                                          decoration: BoxDecoration(
                                              color:
                                                  controller.topIndex == index
                                                      ? AppColor.theme
                                                      : Colors.transparent),
                                        ),
                                        ghb(7),
                                      ]);
                                    },
                                  )),
                            ))),
              )),
          Positioned(
              top: 55.w,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ghb(16),
                    topView(),
                    ghb(16),
                    percentView(),
                    ghb(16),
                    tableView(),
                    ghb(20),
                  ],
                ),
              )),
          CustomDropDownView(
              height: 255.w,
              dropDownCtrl: controller.dropDownCtrl,
              dropWidget: filterView()),
        ],
      ),
    );
  }

  Widget topView() {
    return Container(
      width: 345.w,
      height: 135.w,
      decoration: BoxDecoration(
          color: AppColor.theme, borderRadius: BorderRadius.circular(8.w)),
      child: Stack(
        children: [
          Positioned(
              right: 10.w,
              bottom: 5.w,
              child: Image.asset(
                assetsName("statistics/sy_icon"),
                width: 81.5.w,
                fit: BoxFit.fitWidth,
              )),
          Positioned.fill(
              top: 25.w,
              left: 22.w,
              child: GetBuilder<EarnStatisticsController>(
                builder: (_) {
                  Map data = controller.dataList[controller.topIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getSimpleText(
                          "总收益(元)", 14, Colors.white.withOpacity(0.5)),
                      ghb(5),
                      getSimpleText(priceFormat(data["totalAmount"] ?? 0), 30,
                          Colors.white,
                          isBold: true),
                      ghb(5),
                      getSimpleText(
                        "已结算金额  ¥${priceFormat(data["creditAmount"] ?? 0)}",
                        14,
                        Colors.white.withOpacity(0.5),
                      ),
                    ],
                  );
                },
              ))
        ],
      ),
    );
  }

  Widget percentView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          titleCell("收益来源及占比"),
          ghb(10),
          SizedBox(
              width: 345.w,
              height: 160.w,
              child: GetBuilder<EarnStatisticsController>(
                builder: (_) {
                  Map data = controller.dataList[controller.topIndex];
                  // List lyList = controller.currentData["ly"];
                  List lyList = data["incomeData"] ?? [];
                  lyList = List.generate(lyList.length, (index) {
                    Map e = lyList[index];

                    return {
                      ...e,
                      "show": true,
                      "num": (e["rewardAmt1"] ?? 0) +
                          (e["rewardAmt2"] ?? 0) +
                          (e["rewardAmt3"] ?? 0) +
                          (e["rewardAmt4"] ?? 0),
                      "name": e["title"] ?? "",
                    };
                  });
                  int realIndex = 0;
                  List<PieChartSectionData> pieSections = [];
                  for (var e in lyList) {
                    bool isTouched = controller.pieSectionIndex == realIndex;
                    if ((e["show"] ?? true) && e["num"] != null) {
                      String cStr = controller
                          .colors[realIndex % controller.colors.length];
                      double value = (e["show"] ?? true)
                          ? (e["num"] ?? 0.0) /
                              (data["totalAmount"] == null ||
                                      data["totalAmount"] == 0
                                  ? 1
                                  : data["totalAmount"]) *
                              100
                          : 0;
                      pieSections.add(PieChartSectionData(
                          radius: isTouched ? 55.w : 40.w,
                          showTitle: false,
                          // badgeWidget: getSimpleText(
                          //     isTouched ? "${e["name"] ?? ""}\n${e["num"] ?? 0}" : "",
                          //     10,
                          //     AppColor.text,
                          //     maxLines: 2),
                          value: (data["totalAmount"] ?? 0) > 0 ? value : 1,
                          color: Color(int.parse(cStr, radix: 16))));
                      realIndex++;
                    }
                  }

                  return lyList.isEmpty
                      ? GetX<EarnStatisticsController>(
                          builder: (_) {
                            return Center(
                              child: CustomEmptyView(
                                topSpace: 0,
                                centerSpace: 10,
                                imageWidth: 120,
                                isLoading: controller.isLoading,
                              ),
                            );
                          },
                        )
                      : Center(
                          child: sbRow([
                            SizedBox(
                                width: 160.w,
                                height: 160.w,
                                child: PieChart(
                                  PieChartData(
                                    sections: pieSections,
                                    sectionsSpace: 0,
                                  ),
                                )),
                            centClm(List.generate(
                                lyList.length,
                                (index) => Padding(
                                      padding: EdgeInsets.only(
                                          top: index != 0 ? 15.w : 0),
                                      child: centRow([
                                        Container(
                                          width: 10.w,
                                          height: 10.w,
                                          color: Color(int.parse(
                                              controller.colors[index %
                                                  controller.colors.length],
                                              radix: 16)),
                                        ),
                                        gwb(10),
                                        getWidthText(
                                            "${lyList[index]["name"]}(${((lyList[index]["num"] / (data["totalAmount"] == null || data["totalAmount"] == 0 ? 1 : data["totalAmount"])) * 100).floor()}%)",
                                            12,
                                            AppColor.text,
                                            345 -
                                                20 * 2 -
                                                10 -
                                                160 -
                                                10 -
                                                0.1 -
                                                35,
                                            1,
                                            textHeight: 1.3),
                                      ]),
                                    )))
                          ], width: 345 - 20 * 2),
                        );
                },
              )),
          ghb(25)
        ],
      ),
    );
  }

  Widget tableView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          titleCell("收益详细数据"),
          ghb(10),
          Center(
            child: GetBuilder<EarnStatisticsController>(
              builder: (_) {
                Map data = controller.dataList[controller.topIndex];
                // List lyList = controller.currentData["ly"];
                List lyList = data["incomeData"] ?? [];
                return lyList.isEmpty
                    ? GetX<EarnStatisticsController>(
                        builder: (_) {
                          return Center(
                            child: CustomEmptyView(
                              topSpace: 10,
                              centerSpace: 10,
                              imageWidth: 120,
                              bottomSpace: 20,
                              isLoading: controller.isLoading,
                            ),
                          );
                        },
                      )
                    : Column(
                        children: [
                          tableRow(-1, {}),
                          ...List.generate(lyList.length,
                              (index) => tableRow(index, lyList[index])),
                        ],
                      );
              },
            ),
          ),
          ghb(15),
        ],
      ),
    );
  }

  Widget tableRow(int index, Map tableDatas) {
    int length = controller.tableTitles.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(length, (idx) {
        String str = "";
        if (index >= 0) {
          Map data = tableDatas;
          switch (idx) {
            case 0:
              str = data["title"] ?? "";
              break;
            case 1:
              str = priceFormat(data["rewardAmt1"] ?? 0, tenThousand: true);
              break;
            case 2:
              str = priceFormat(data["rewardAmt2"] ?? 0, tenThousand: true);
              break;
            case 3:
              str = priceFormat(data["rewardAmt3"] ?? 0, tenThousand: true);
              break;
            case 4:
              str = priceFormat(data["rewardAmt4"] ?? 0, tenThousand: true);
              break;
          }
        }
        double width = idx == 0 ? 60.w : (315 - 60).w / (length - 1);
        return Container(
          width: width,
          height: 40.w,
          decoration: BoxDecoration(
            border: Border(
                right: BorderSide(
                  width: 0.5.w,
                  color: Colors.white,
                ),
                bottom: BorderSide(width: 0.5.w, color: Colors.white)),
            color:
                index == -1 ? AppColor.theme : AppColor.theme.withOpacity(0.1),
          ),
          child: Center(
              child: getWidthText(
                  index == -1 ? controller.tableTitles[idx] : str,
                  12,
                  index == -1 ? Colors.white : AppColor.text,
                  width,
                  textAlign: TextAlign.center,
                  alignment: Alignment.center,
                  1)),
        );
      }),
    );
  }

  Widget filterView() {
    return SizedBox(
      width: 375.w,
      height: 255.w,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 375.w,
              height: 200.w,
              child: Column(
                children: [
                  gline(375, 0.5),
                  ghb(18),
                  sbRow([
                    getSimpleText("快速选择", 15, AppColor.text, isBold: true),
                  ], width: 375 - 15.5 * 2),
                  ghb(18),
                  GetX<EarnStatisticsController>(
                    builder: (_) {
                      return sbRow(
                          List.generate(
                              3,
                              (index) => CustomButton(
                                    onPressed: () {
                                      if (controller.filterIndex != index) {
                                        controller.filterIndex = index;
                                      } else {
                                        controller.filterIndex = -1;
                                      }
                                    },
                                    child: Container(
                                      width: 105.w,
                                      height: 30.w,
                                      decoration: BoxDecoration(
                                          color: controller.filterIndex == index
                                              ? AppColor.theme
                                              : AppColor.theme.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4.w)),
                                      child: Center(
                                        child: getSimpleText(
                                            index == 0
                                                ? "今日"
                                                : index == 1
                                                    ? "最近7天"
                                                    : "最近30天",
                                            12,
                                            controller.filterIndex == index
                                                ? Colors.white
                                                : AppColor.text2),
                                      ),
                                    ),
                                  )),
                          width: 345);
                    },
                  ),
                  ghb(18),
                  sbRow([
                    getSimpleText("起止时间", 15, AppColor.text, isBold: true),
                  ], width: 375 - 15.5 * 2),
                  ghb(18),
                  sbRow(
                      List.generate(3, (index) {
                        if (index == 1) {
                          return getSimpleText("至", 12, AppColor.text2);
                        } else {
                          return CustomButton(
                            onPressed: () {
                              showDatePick(isStart: index == 0);
                            },
                            child: Container(
                              width: 150.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5.w, color: AppColor.lineColor)),
                              child: Center(
                                child: sbRow([
                                  gwb(8),
                                  GetX<EarnStatisticsController>(
                                    builder: (_) {
                                      String text = index == 0
                                          ? controller.startDate
                                          : controller.endDate;
                                      return getSimpleText(
                                          text.isEmpty
                                              ? index == 0
                                                  ? "开始时间"
                                                  : "结束时间"
                                              : text,
                                          12,
                                          text.isEmpty
                                              ? AppColor.assisText
                                              : AppColor.text);
                                    },
                                  ),
                                  Image.asset(
                                    assetsName("statistics/icon_date"),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ], width: 150 - 8 * 2),
                              ),
                            ),
                          );
                        }
                      }),
                      width: 345)
                ],
              ),
            ),
            centRow(List.generate(
                2,
                (index) => CustomButton(
                      onPressed: () {
                        if (index == 0) {
                          controller.resetCheck();
                        } else {
                          controller.confirmCheck();
                        }
                      },
                      child: Container(
                        width: 375.w / 2 - 0.1.w,
                        height: 55.w,
                        color: index == 0
                            ? AppColor.theme.withOpacity(0.1)
                            : AppColor.theme,
                        child: Center(
                          child: getSimpleText(index == 0 ? "重置" : "确定", 15,
                              index == 0 ? AppColor.theme : Colors.white),
                        ),
                      ),
                    )))
          ],
        ),
      ),
    );
  }

  showDatePick({bool isStart = true}) async {
    String str = isStart ? controller.startDate : controller.endDate;
    DateTime initialDate = str.isEmpty
        ? DateTime.now()
        : controller.dateFormat
            .parse(isStart ? controller.startDate : controller.endDate);
    DateTime? select = await showDatePicker(
        context: Global.navigatorKey.currentContext!,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now());
    if (select != null) {
      if (isStart) {
        controller.startDate = controller.dateFormat.format(select);
      } else {
        var start = controller.dateFormat.parse(controller.startDate);
        if (select.isAfter(start)) {
          ShowToast.normal("结束日期不能早于开始日期，请重新选择");
        } else {
          controller.endDate = controller.dateFormat.format(select);
        }
      }
    }
  }

  Widget titleCell(String title, {Widget? rightWidget}) {
    return Center(
      child: sbhRow([
        centRow([
          Container(
            width: 2.w,
            height: 14.w,
            decoration: BoxDecoration(
                color: AppColor.theme,
                borderRadius: BorderRadius.circular(0.5.w)),
          ),
          gwb(10),
          getSimpleText(title, 16, AppColor.text, isBold: true),
        ]),
        rightWidget ?? gwb(0)
      ], width: 345 - 15 * 2, height: 55),
    );
  }
}
