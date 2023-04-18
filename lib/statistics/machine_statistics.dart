import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MachineStatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineStatisticsController>(MachineStatisticsController());
  }
}

class MachineStatisticsController extends GetxController {
  GlobalKey headKey = GlobalKey();
  GlobalKey stackKey = GlobalKey();

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      _currentTopIndex.value = 0;
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

  CustomDropDownController dropDownCtrl = CustomDropDownController();

  final _currentTopIndex = 0.obs;
  int get currentTopIndex => _currentTopIndex.value;
  set currentTopIndex(v) {
    if (_currentTopIndex.value != v) {
      _currentTopIndex.value = v;
      loadData();
    }
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  int pieSectionIndex = -1;
  List<PieChartSectionData> pieSections = [];

  List tableTitles = ["名称", "合计", "库存", "出库", "已激活", "有效激活"];
  List tableDatas = [];

  List zyTop = [
    {
      "id": 0,
      "name": "全部",
    },
    {
      "id": 1,
      "name": "我的",
    },
    {
      "id": 2,
      "name": "我的合伙人",
    },
  ];
  List tdTop = [
    {
      "id": 0,
      "name": "全部",
    },
    {
      "id": 3,
      "name": "我的运营中心",
    },
    {
      "id": 4,
      "name": "我的盘主",
    },
  ];

  List currentTop = [];

  List colors = [
    "FF437BFE",
    "FFF9C529",
    "FF3AD3D2",
    "FFFF7544",
    "FFF93635",
  ];

  List allDataList = [];

  showFilter() {
    if (dropDownCtrl.isShow) {
      dropDownCtrl.hide();
    } else {
      filterIndex = realFilterIdx;
      changeDate();
      dropDownCtrl.show(stackKey, headKey);
    }
  }

  double chartAllNum = 0;

  final _startDate = "".obs;
  String get startDate => _startDate.value;
  set startDate(v) => _startDate.value = v;

  final _endDate = "".obs;
  String get endDate => _endDate.value;
  set endDate(v) => _endDate.value = v;

  double maxNum = 0;
  String maxStr = "";
  changeData() {
    currentTopIndex = 0;
    pieSectionIndex = -1;

    pieSections = [];
    int realIndex = 0;
    chartAllNum = 0;

    int bigIndex = 0;

    int i = 0;
    maxNum = 0;
    for (var e in allDataList) {
      if (e["show"] ?? true) {
        chartAllNum += (e["num"] ?? 0);
        if (maxNum < (e["num"] ?? 0)) {
          maxNum = (e["num"] ?? 0) * 1.0;
          bigIndex = i;
        }
        if ((e["name"] ?? "").length > maxStr.length) {
          maxStr = (e["name"] ?? "");
        }
        i++;
      }
    }
    for (var e in allDataList) {
      bool isTouched = pieSectionIndex == -1
          ? realIndex == bigIndex
          : pieSectionIndex == realIndex;
      if ((e["show"] ?? true) && e["num"] != null && e["num"] > 0) {
        String cStr = colors[realIndex % colors.length];
        pieSections.add(PieChartSectionData(
            radius: isTouched ? 55.w : 40.w,
            showTitle: false,
            // badgeWidget: getSimpleText(
            //     isTouched ? "${e["name"] ?? ""}\n${e["num"] ?? 0}" : "",
            //     10,
            //     AppColor.text,
            //     maxLines: 2),
            value:
                (e["show"] ?? true) ? (e["num"] ?? 0.0) / chartAllNum * 100 : 0,
            color: Color(int.parse(cStr, radix: 16))));
        realIndex++;
      }
    }

    update();
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

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
    changeDate();
  }

  List dataList = [{}, {}, {}];

  loadData({String? start, String? end}) {
    switch (topIndex) {
      case 0:
        currentTop = [];
        break;
      case 1:
        currentTop = zyTop;
        break;
      case 2:
        currentTop = tdTop;
        break;
    }

    update();

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

    if (topIndex > 0) {
      params["subType"] = currentTop[currentTopIndex]["id"];
    }

    simpleRequest(
      url: Urls.userTerminalStatisticsList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          double maxNum = 0.0;
          List machineTypes = [];
          double kc = (data["inToryNum"] ?? 0.0) * 1.0;
          double ck = (data["outNum"] ?? 0.0) * 1.0;
          double yjh = (data["actNum"] ?? 0.0) * 1.0;
          double yxjh = (data["assNum"] ?? 0.0) * 1.0;
          double zf = (data["badNum"] ?? 0.0) * 1.0;
          if (kc > maxNum) {
            maxNum = kc;
          }
          machineTypes.add({"name": "库存", "num": kc});
          if (ck > maxNum) {
            maxNum = ck;
          }
          machineTypes.add({"name": "出库", "num": ck});
          if (yjh > maxNum) {
            maxNum = yjh;
          }
          machineTypes.add({"name": "已激活", "num": yjh});
          if (yxjh > maxNum) {
            maxNum = yxjh;
          }
          machineTypes.add({"name": "有效激活", "num": yxjh});
          if (zf > maxNum) {
            maxNum = zf;
          }
          machineTypes.add({"name": "作废", "num": zf});
          data["machineTypes"] = machineTypes;
          data["maxCount"] = getMaxCount(maxNum);
          data["chartScale"] = getChartScale(maxNum);
          data["maxNum"] = maxNum;
          data["maxStr"] = "有效激活";
          dataList[topIndex] = data;
          update();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  @override
  void onInit() {
    // changeData();
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    dropDownCtrl.dispose();
    super.onClose();
  }
}

class MachineStatistics extends GetView<MachineStatisticsController> {
  const MachineStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "设备统计", action: [
        CustomButton(
          onPressed: () {
            controller.showFilter();
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
      body: Stack(key: controller.stackKey, children: [
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
                                child: GetX<MachineStatisticsController>(
                                  builder: (_) {
                                    return centClm([
                                      ghb(10),
                                      getSimpleText(
                                          index == 0
                                              ? "数据总览"
                                              : index == 1
                                                  ? "自营设备"
                                                  : "团队设备",
                                          15,
                                          controller.topIndex == index
                                              ? AppColor.text
                                              : AppColor.text3,
                                          isBold: controller.topIndex == index),
                                      ghb(6),
                                      Container(
                                        width: 15.w,
                                        height: 2.w,
                                        decoration: BoxDecoration(
                                            color: controller.topIndex == index
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
                  gwb(375),
                  GetBuilder<MachineStatisticsController>(
                    builder: (_) {
                      return controller.topIndex == 0
                          ? ghb(16)
                          : sbhRow(
                              List.generate(
                                  controller.currentTop.length,
                                  (index) => CustomButton(onPressed: () {
                                        controller.currentTopIndex = index;
                                      }, child:
                                          GetX<MachineStatisticsController>(
                                        builder: (_) {
                                          return Container(
                                            width: 105.w,
                                            height: 30.w,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4.w),
                                              color:
                                                  controller.currentTopIndex ==
                                                          index
                                                      ? AppColor.theme
                                                      : AppColor.theme
                                                          .withOpacity(0.1),
                                            ),
                                            child: Center(
                                              child: getSimpleText(
                                                  controller.currentTop[index]
                                                          ["name"] ??
                                                      "",
                                                  12,
                                                  controller.currentTopIndex ==
                                                          index
                                                      ? Colors.white
                                                      : AppColor.text,
                                                  textHeight: 1.3),
                                            ),
                                          );
                                        },
                                      ))),
                              width: 375 - 15 * 2,
                              height: 66);
                    },
                  ),
                  pieView(),
                  ghb(16),
                  barView(),
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
      ]),
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
                  GetX<MachineStatisticsController>(
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
                                  GetX<MachineStatisticsController>(
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

    DateTime initialDate =
        str.isEmpty ? DateTime.now() : controller.dateFormat.parse(str);
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

  Widget pieView() {
    return GetBuilder<MachineStatisticsController>(
      builder: (_) {
        Map data = controller.dataList[controller.topIndex];
        List datas = data["machineTypes"] ?? [];

        controller.pieSections = [];
        int realIndex = 0;
        double chartAllNum = 0.0;

        int bigIndex = -1;

        int i = 0;
        double maxNum = data["maxNum"] ?? 0.0;
        String maxStr = "";
        for (var e in datas) {
          if (e["show"] ?? true) {
            chartAllNum += (e["num"] ?? 0) * 1.0;
            if (maxNum < (e["num"] ?? 0)) {
              maxNum = (e["num"] ?? 0) * 1.0;
              bigIndex = i;
            }
            if ((e["name"] ?? "").length > maxStr.length) {
              maxStr = (e["name"] ?? "");
            }
            i++;
          }
        }
        for (var e in datas) {
          bool isTouched = controller.pieSectionIndex == -1
              ? realIndex == bigIndex
              : controller.pieSectionIndex == realIndex;
          if ((e["show"] ?? true) && e["num"] != null) {
            double value =
                (e["show"] ?? true) ? (e["num"] ?? 0.0) / chartAllNum * 100 : 0;

            String cStr =
                controller.colors[realIndex % controller.colors.length];
            controller.pieSections.add(PieChartSectionData(
                radius: isTouched ? 50.w : 40.w,
                showTitle: false,
                // badgeWidget: getSimpleText(
                //     isTouched ? "${e["name"] ?? ""}\n${e["num"] ?? 0}" : "",
                //     10,
                //     AppColor.text,
                //     maxLines: 2),
                value: chartAllNum > 0 ? value : 1,
                color: Color(int.parse(cStr, radix: 16))));
            realIndex++;
          }
        }
        // if (controller.pieSections.isEmpty) {
        //   controller.pieSections.add(PieChartSectionData(
        //       radius: 40.w,
        //       showTitle: false,
        //       // badgeWidget: getSimpleText(
        //       //     isTouched ? "${e["name"] ?? ""}\n${e["num"] ?? 0}" : "",
        //       //     10,
        //       //     AppColor.text,
        //       //     maxLines: 2),
        //       value: 1,
        //       color: Color(int.parse(controller.colors[0], radix: 16))));
        // }
        return Container(
          width: 345.w,
          // padding: EdgeInsets.only(left: 10.w),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
          child: Column(
            children: [
              titleCell("设备状态占比统计"),
              ghb(10),
              datas.isEmpty
                  ? GetX<MachineStatisticsController>(
                      builder: (_) {
                        return Center(
                          child: CustomEmptyView(
                            topSpace: 10,
                            centerSpace: 10,
                            imageWidth: 120,
                            bottomSpace: 10,
                            isLoading: controller.isLoading,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: sbRow([
                        SizedBox(
                          width: 150.w,
                          height: 150.w,
                          child: PieChart(PieChartData(
                            sections: controller.pieSections,
                            sectionsSpace: 0,
                          )),
                        ),
                        SizedBox(
                          width: 140.w,
                          // height: 160.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                                datas.length,
                                (index) => Padding(
                                      padding: EdgeInsets.only(
                                          top: index != 0 ? 18.w : 0),
                                      child: centRow([
                                        Container(
                                          width: 10.w,
                                          height: 10.w,
                                          color: Color(int.parse(
                                              controller.colors[index %
                                                  controller.colors.length],
                                              radix: 16)),
                                        ),
                                        gwb(12),
                                        getWidthText(
                                            "${datas[index]["name"]}(${priceFormat(datas[index]["num"], savePoint: 0)}台)",
                                            12,
                                            AppColor.text,
                                            140 - 12 - 10,
                                            2,
                                            textHeight: 1.3)
                                      ]),
                                    )),
                          ),
                        ),
                      ], width: 315),
                    ),
              ghb(15),
            ],
          ),
        );
      },
    );
  }

  Widget barView() {
    return GetBuilder<MachineStatisticsController>(
      builder: (_) {
        Map data = controller.dataList[controller.topIndex];
        List datas = data["machineTypes"] ?? [];
        List<BarChartGroupData> barGroupData = [];
        int maxInt = getMaxCount(data["maxNum"] ?? 0.0);
        barGroupData = List.generate(
            datas.length,
            (index) => BarChartGroupData(x: index, barsSpace: 20.w, barRods: [
                  BarChartRodData(
                      borderRadius: BorderRadius.zero,
                      toY: 4 * datas[index]["num"] / maxInt,
                      color: AppColor.theme,
                      width: 16.w),
                ], showingTooltipIndicators: [
                  0
                ]));

        Map scale = getChartScale(data["maxNum"] ?? 0.0);

        double leftWidth = calculateTextSize(scale[4], 11, FontWeight.normal,
                double.infinity, 1, Global.navigatorKey.currentContext!)
            .width;
        leftWidth += 6.w;

        double barWidth = calculateTextSize(
                    controller.maxStr,
                    10,
                    FontWeight.normal,
                    double.infinity,
                    1,
                    Global.navigatorKey.currentContext!)
                .width +
            10.w;
        barWidth = barWidth + 5.w;
        double barRealWidth = datas.length * barWidth + leftWidth;

        if (barRealWidth < 297.w) {
          barRealWidth = 297.w;
        }
        return Container(
          width: 345.w,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
          child: Column(
            children: [
              titleCell("设备数量统计"),
              ghb(10),
              datas.isEmpty
                  ? GetX<MachineStatisticsController>(
                      builder: (_) {
                        return Center(
                          child: CustomEmptyView(
                            topSpace: 10,
                            centerSpace: 10,
                            imageWidth: 120,
                            bottomSpace: 10,
                            isLoading: controller.isLoading,
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      width: 297.w,
                      height: 160.w,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: barRealWidth,
                          height: 160.w,
                          child: BarChart(
                            BarChartData(
                              barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    tooltipBgColor: Colors.transparent,
                                    // fitInsideVertically: true,
                                    // direction: TooltipDirection.top,
                                    // fitInsideHorizontally: true,
                                    tooltipBorder: BorderSide.none,
                                    tooltipRoundedRadius: 0,
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 0,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                          // controller.dropIndex - 1 == 2
                                          //     ? priceFormat(
                                          //         controller.dataList[groupIndex]
                                          //                 ["tolNum"] ??
                                          //             0,
                                          //         tenThousand: true)
                                          //     :
                                          "${(datas[groupIndex]["num"] ?? 0).round()}",
                                          TextStyle(
                                              fontSize: 13.sp,
                                              color: AppColor.text));
                                    },
                                  )),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) {
                                      var style = TextStyle(
                                        color: AppColor.text3,
                                        fontSize: 12.sp,
                                      );
                                      String text = scale[value.toInt()] ?? "";
                                      return SideTitleWidget(
                                        axisSide: AxisSide.bottom,
                                        // axisSide: meta.axisSide,
                                        space: 8.w,
                                        child: Text(text,
                                            style: style,
                                            textAlign: TextAlign.left),
                                      );
                                    },
                                    reservedSize: leftWidth,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.ceil();
                                      Map data = datas[index];
                                      // String title = "${data["name"]}：${data["num"]}";
                                      String title = data["name"] ?? "";
                                      // switch (controller.allDataList) {
                                      //   case 0:
                                      //     title =
                                      //         "${data["year"] ?? 0}/${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}/${(data["day"] ?? 0) < 10 ? "0${data["day"] ?? 0}" : "${data["day"] ?? 0}"}";
                                      //     break;
                                      //   case 1:
                                      //     title =
                                      //         "${data["year"] ?? 0}/${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}";
                                      //     break;
                                      //   case 2:
                                      //     title = "${data["year"] ?? 0}";
                                      //     break;
                                      // }

                                      return SideTitleWidget(
                                        axisSide: meta.axisSide,
                                        space: 3.w,
                                        child: getSimpleText(
                                            title, 10, AppColor.text3),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: false,
                              ),
                              backgroundColor: Colors.white,
                              barGroups: barGroupData,
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                      color: const Color(0x19437DF4),
                                      strokeWidth: 1.w);
                                },
                              ),
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 4,
                              minY: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
              ghb(15),
            ],
          ),
        );
      },
    );
  }

  Widget tableView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          titleCell("设备详细数据"),
          GetBuilder<MachineStatisticsController>(
            builder: (_) {
              Map data = controller.dataList[controller.topIndex];
              List datas = data["terminalData"] ?? [];
              return datas.isEmpty
                  ? GetX<MachineStatisticsController>(
                      builder: (_) {
                        return Center(
                          child: CustomEmptyView(
                            topSpace: 10,
                            centerSpace: 10,
                            imageWidth: 120,
                            bottomSpace: 10,
                            isLoading: controller.isLoading,
                          ),
                        );
                      },
                    )
                  : SizedBox(
                      width: 315.w,
                      child: Column(
                        children: [
                          tableRow(-1, {}),
                          ...List.generate(
                              datas.length,
                              (index) => tableRow(
                                    index,
                                    datas[index],
                                  )),
                        ],
                      ),
                    );
            },
          ),
          ghb(15),
        ],
      ),
    );
  }

  Widget tableRow(int index, Map data) {
    int length = controller.tableTitles.length;

    return Row(
      children: List.generate(length, (idx) {
        String str = "";
        if (index >= 0) {
          switch (idx) {
            case 0:
              str = data["title"] ?? "";
              break;
            case 1:
              str = "${data["totalNum"] ?? 0}";
              break;
            case 2:
              str = "${data["inToryNum"] ?? 0}";
              break;
            case 3:
              str = "${data["outNum"] ?? 0}";
              break;
            case 4:
              str = "${data["actNum"] ?? 0}";
              break;
            case 5:
              str = "${data["assNum"] ?? 0}";
              break;
          }
        }
        double width = idx == 0
            ? 80.w
            : idx == 5
                ? 55.w
                : (315 - 80 - 55).w / (length - 2);
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
            child: getWidthText(index == -1 ? controller.tableTitles[idx] : str,
                12, index == -1 ? Colors.white : AppColor.text, width, 1,
                alignment: Alignment.center, textAlign: TextAlign.center),
          ),
        );
      }),
    );
  }

  Widget titleCell(String title) {
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
        ])
      ], width: 345 - 15 * 2, height: 55),
    );
  }
}
