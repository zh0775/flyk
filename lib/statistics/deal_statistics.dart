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

class DealStatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DealStatisticsController>(DealStatisticsController());
  }
}

class DealStatisticsController extends GetxController {
  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  CustomDropDownController dropDownCtrl = CustomDropDownController();

  List colors = [
    "FF437BFE",
    "FFF9C529",
    "FF3AD3D2",
    "FFFF7544",
    "FFF93635",
  ];

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      loadData();
    }
  }

  final _filterIndex = 0.obs;
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

  Map leftSumCount = {};
  Map leftBsCount = {};
  double maxSumNum = 0;
  double maxBsNum = 0;

  String maxSumStr = "";
  String maxBsStr = "";

  int maxSumInt = 0;
  int maxBsInt = 0;

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
        url: Urls.userTransactionStatisticsList,
        params: params,
        success: (success, json) {
          // if (success) {
          Map data = json["data"] ?? {};
          dataList[topIndex] = data;
          List datas = dataList[topIndex]["tranTerminalData"] ?? [];
          double num = 0.0;
          double bsCount = 0.0;
          datas = List.generate(datas.length, (index) {
            Map e = datas[index];
            if ((e["totalAmt"] ?? 0.0) > num) {
              num = e["totalAmt"] ?? 0.0;
            }
            if ((e["totalNum"] ?? 0.0) > bsCount) {
              bsCount = (e["totalNum"] ?? 0.0) * 1.0;
            }
            double creditAmount = e["creditAmount"] ?? 0.0;
            double qrAmount = e["qrAmount"] ?? 0.0;
            return {
              ...e,
              "name": e["title"] ?? "",
              "num": e["totalAmt"] ?? 0.0,
              "count": e["totalNum"] ?? 0,
              "creditAmount": creditAmount,
              "qrAmount": qrAmount,
              "sum": qrAmount,
              "percent": priceFormat(
                  creditAmount / qrAmount > 1 ? 1 : creditAmount / qrAmount),
            };
          });
          int tmpMaxSumInt = getMaxCount(num);
          Map tmpLeftSumCount = getChartScale(num);
          int tmpMaxBsInt = getMaxCount(bsCount);
          Map tmpLeftBsCount = getChartScale(bsCount);

          dataList[topIndex]["maxSumInt"] = tmpMaxSumInt;
          dataList[topIndex]["leftSumCount"] = tmpLeftSumCount;
          dataList[topIndex]["maxBsInt"] = tmpMaxBsInt;
          dataList[topIndex]["leftBsCount"] = tmpLeftBsCount;
          dataList[topIndex]["bsCount"] = bsCount.floor();
          update();
        },
        after: () {
          isLoading = false;
        },
        useCache: params["typeTime"] != null && params["typeTime"] == 0);
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

class DealStatistics extends GetView<DealStatisticsController> {
  const DealStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "交易统计", action: [
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
                                  child: GetX<DealStatisticsController>(
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
                    dealOverView(),
                    ghb(16),
                    lineChartView(),
                    ghb(16),
                    barChartView(),
                    ghb(16),
                    percentView(),
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

  Widget dealOverView() {
    return Container(
        width: 345.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: GetBuilder<DealStatisticsController>(
          builder: (_) {
            Map data = controller.dataList[controller.topIndex];
            double totalAmount = data["totalAmount"] ?? 0;
            String unit = "";
            if (totalAmount >= 100000) {
              unit = "万元";
            } else {
              unit = "元";
            }
            return Column(
              children: [
                titleCell("交易概览"),
                // ghb(10),
                getSimpleText("交易总额($unit)", 14, AppColor.text2),
                ghb(7),
                getSimpleText(
                    priceFormat(data["totalAmount"] ?? 0,
                        tenThousand: totalAmount >= 100000,
                        tenThousandUnit: false),
                    30,
                    AppColor.text,
                    isBold: true),
                ghb(5),
                getSimpleText(
                    "交易笔数 ${data["bsCount"] ?? 0}", 14, AppColor.text2),
                ghb(25),
                sbRow(
                    List.generate(
                        3,
                        (index) => index == 1
                            ? gline(1, 40)
                            : SizedBox(
                                width: 345.w / 2 - 0.1.w - 1.w,
                                child: centRow([
                                  Image.asset(
                                    assetsName(
                                      "statistics/icon_deal_${index == 0 ? "normal" : "sm"}",
                                    ),
                                    width: 18.w,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  gwb(10),
                                  centClm([
                                    getSimpleText(
                                        "￥${priceFormat(index == 0 ? data["creditAmount"] ?? 0 : data["qrAmount"] ?? 0, tenThousand: index == 0 ? (data["creditAmount"] ?? 0) >= 100000 : (data["qrAmount"] ?? 0) >= 100000)}",
                                        14,
                                        AppColor.text2),
                                    getSimpleText(
                                        "${index == 0 ? "标准" : "扫码"}交易额",
                                        12,
                                        AppColor.text2),
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start)
                                ]),
                              )),
                    width: 345),
                ghb(23),
              ],
            );
          },
        ));
  }

  Widget lineChartView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: GetBuilder<DealStatisticsController>(
        builder: (_) {
          Map data = controller.dataList[controller.topIndex];
          // List datas = controller.currentDealData["je"] ?? [];
          List datas = data["tranTerminalData"] ?? [];

          List<FlSpot> spots = List.generate(datas.length, (index) {
            int maxSumInt = data["maxSumInt"] ?? 0;
            double num = datas[index]["totalAmt"] * 1.0;
            double y = num / (maxSumInt <= 0 ? 1 : maxSumInt) * 4.0;
            return FlSpot((index) * 1.0, y);
          });

          LineChartBarData lineChartBarData = LineChartBarData(
            spots: spots,
            isCurved: false,
            gradient: LinearGradient(
              colors: [
                AppColor.theme,
                AppColor.theme
                // AppColor.theme.withOpacity(0.1),
              ],
            ),
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            // showingIndicators: [1, 2, 5],
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: const Alignment(0, 1.5),
                  colors: [
                    AppColor.theme.withOpacity(0.5),
                    AppColor.theme.withOpacity(0.1),
                    Colors.transparent,
                  ]),
            ),
          );

          // List tops = [1, 2, 5];

          return Column(
            children: [
              titleCell("交易金额统计",
                  rightWidget: getSimpleText("单位：万元", 12, AppColor.text2)),
              SizedBox(
                width: 315.w,
                height: 155.5.w,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    height: 155.5.w,
                    width: datas.length * 45.w < 315.w
                        ? 315.w
                        : datas.length * 45.w,
                    child: LineChart(
                      LineChartData(
                        // showingTooltipIndicators: tops
                        //     .map((index) => ShowingTooltipIndicators([
                        //           LineBarSpot(
                        //             lineChartBarData,
                        //             0,
                        //             spots[index],
                        //           ),
                        //         ]))
                        //     .toList(),
                        lineTouchData: LineTouchData(
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
                            return spotIndexes.map((index) {
                              return TouchedSpotIndicatorData(
                                FlLine(color: AppColor.theme, strokeWidth: 0),
                                FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) =>
                                          FlDotCirclePainter(
                                    radius: 3,
                                    color: Colors.white,
                                    strokeWidth: 2,
                                    strokeColor: AppColor.theme,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          touchTooltipData: LineTouchTooltipData(
                            // tooltipBgColor: AppColor.theme,
                            tooltipBgColor: Colors.transparent,
                            tooltipPadding: EdgeInsets.zero,
                            tooltipRoundedRadius: 8,
                            getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                              return lineBarsSpot.map((lineBarSpot) {
                                return LineTooltipItem(
                                  "${datas[lineBarSpot.spotIndex]["num"]}",
                                  TextStyle(
                                    color: AppColor.theme,
                                    fontWeight: FontWeight.normal,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 1,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: AppColor.lineColor,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30.w,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                Widget text;

                                if (value.floor() < datas.length) {
                                  text = getSimpleText(
                                      (datas[value.toInt()]["title"] ?? ""),
                                      12,
                                      AppColor.text3);
                                } else {
                                  text = gemp();
                                }
                                return SideTitleWidget(
                                  axisSide: meta.axisSide,
                                  child: text,
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                TextStyle style = TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  color: AppColor.text3,
                                  fontSize: 12.sp,
                                );

                                String text = (data["leftSumCount"] ??
                                        {})[value.toInt()] ??
                                    "";

                                return SideTitleWidget(
                                  axisSide: AxisSide.bottom,
                                  // axisSide: meta.axisSide,
                                  space: 8.w,
                                  child: Text(text,
                                      style: style, textAlign: TextAlign.left),
                                );
                              },
                              reservedSize: 42.w,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                          // border: Border.all(color: const Color(0xff37434d)),
                        ),
                        minX: 0,
                        maxX: datas.length * 1.0 + 1,
                        minY: 0,
                        maxY: 4,
                        lineBarsData: [lineChartBarData],
                      ),
                    ),
                  ),
                ),
              ),
              ghb(15)
            ],
          );
        },
      ),
    );
  }

  Widget barChartView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: GetBuilder<DealStatisticsController>(
        builder: (_) {
          List<BarChartGroupData> barGroupData = [];
          Map data = controller.dataList[controller.topIndex];
          int maxInt = getMaxCount(data["maxBsNum"] ?? 0);
          List datas = data["tranTerminalData"] ?? [];
          // List datas = controller.currentDealData["bs"] ?? [];
          barGroupData = List.generate(
              datas.length,
              (index) => BarChartGroupData(x: index, barsSpace: 20.w, barRods: [
                    BarChartRodData(
                        borderRadius: BorderRadius.zero,
                        toY: 4 * (datas[index]["totalNum"] ?? 1) / maxInt,
                        color: AppColor.theme,
                        width: 16.w),
                  ], showingTooltipIndicators: [
                    0
                  ]));

          Map scale = getChartScale(controller.maxBsNum);

          String maxScale = "";
          for (var e in scale.keys) {
            String str = scale[e];
            if (maxScale.length < str.length) {
              maxScale = str;
            }
          }

          double leftWidth = calculateTextSize(maxScale, 11, FontWeight.normal,
                  double.infinity, 1, Global.navigatorKey.currentContext!)
              .width;
          leftWidth += 6.w;

          double barWidth = calculateTextSize(
                      controller.maxBsStr,
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

          return Column(
            children: [
              titleCell("交易笔数统计"),
              SizedBox(
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
                                    "${datas[groupIndex]["count"] ?? 0}",
                                    TextStyle(
                                        fontSize: 13.sp, color: AppColor.text));
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
                                String text = scale[value.toInt()];
                                return SideTitleWidget(
                                  axisSide: AxisSide.bottom,
                                  // axisSide: meta.axisSide,
                                  space: 8.w,
                                  child: Text(text,
                                      style: style, textAlign: TextAlign.left),
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
                                  child:
                                      getSimpleText(title, 10, AppColor.text3),
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
          );
        },
      ),
    );
  }

  Widget percentView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: GetBuilder<DealStatisticsController>(
        builder: (_) {
          Map data = controller.dataList[controller.topIndex];
          List datas = data["tranTerminalData"] ?? [];
          // List datas = controller.currentDealData["bl"] ?? [];
          return Column(
            children: [
              titleCell("交易类型及占比",
                  rightWidget: centRow(List.generate(
                      3,
                      (index) => index == 1
                          ? gwb(10)
                          : centRow([
                              Container(
                                width: 6.w,
                                height: 6.w,
                                color: index == 0
                                    ? AppColor.theme
                                    : AppColor.lineColor,
                              ),
                              gwb(5),
                              getSimpleText("${index == 0 ? "标准" : "扫码"}交易", 10,
                                  AppColor.text)
                            ])))),
              ghb(5),
              datas.isEmpty
                  ? GetX<DealStatisticsController>(
                      builder: (_) {
                        return Center(
                          child: CustomEmptyView(
                            topSpace: 15,
                            centerSpace: 10,
                            imageWidth: 120,
                            bottomSpace: 20,
                            isLoading: controller.isLoading,
                          ),
                        );
                      },
                    )
                  : centClm(List.generate(
                      datas.length,
                      (index) => Padding(
                            padding:
                                EdgeInsets.only(top: index != 0 ? 20.w : 0),
                            child: sbRow([
                              getWidthText(datas[index]["name"] ?? "", 12,
                                  AppColor.text, 62.5, 1,
                                  isBold: true),
                              centClm([
                                getSimpleText(
                                    "${priceFormat(datas[index]["sum"] ?? 0)}元",
                                    12,
                                    AppColor.text3),
                                ghb(5),
                                Container(
                                  width: 180.w,
                                  height: 4.w,
                                  decoration: BoxDecoration(
                                      color: AppColor.lineColor,
                                      borderRadius: BorderRadius.circular(2.w)),
                                  child: Stack(children: [
                                    AnimatedPositioned(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        left: 0,
                                        top: 0,
                                        bottom: 0,
                                        width: 180.w *
                                            (datas[index]["percent"] ?? 0.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(int.parse(
                                                  controller.colors[index %
                                                      controller.colors.length],
                                                  radix: 16)),
                                              borderRadius:
                                                  BorderRadius.circular(2.w)),
                                        ))
                                  ]),
                                )
                              ], crossAxisAlignment: CrossAxisAlignment.start),
                              getSimpleText(
                                  "${((datas[index]["percent"] ?? 0.0) * 100).round()}%",
                                  12,
                                  AppColor.text,
                                  isBold: true),
                            ],
                                width: 345 - 26 * 2,
                                crossAxisAlignment: CrossAxisAlignment.end),
                          ))),
              ghb(30),
            ],
          );
        },
      ),
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
                  GetX<DealStatisticsController>(
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
                                  GetX<DealStatisticsController>(
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
