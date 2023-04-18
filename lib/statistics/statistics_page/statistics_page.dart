// 统计 主页

import 'dart:math' as math;

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsPageController extends GetxController {
  final _topIdx = 0.obs;
  int get topIdx => _topIdx.value;
  set topIdx(v) {
    if (_topIdx.value != v) {
      _topIdx.value = v;
    }
  }

  final _tagX = 0.0.obs;
  double get tagX => _tagX.value;
  set tagX(v) => _tagX.value = v;

  changeTagPosition() {
    Future.delayed(const Duration(milliseconds: 10), () {
      final RenderBox box =
          keyList[topIdx].currentContext!.findRenderObject()! as RenderBox;
      final Offset tapPos = box.localToGlobal(Offset.zero);
      tagX = tapPos.dx + ((box.size.width / 2) - (18.w / 2));
    });
    // print(tapPos.dx);
    // print(box.size.width);
  }

  List<GlobalKey> keyList = [GlobalKey(), GlobalKey(), GlobalKey()];

  final _dealSelectIdx = 0.obs;
  int get dealSelectIdx => _dealSelectIdx.value;
  set dealSelectIdx(v) => _dealSelectIdx.value = v;

  List ppList = [];
// 品牌选择
  final _selectPP = 0.obs;
  int get selectPP => _selectPP.value;
  set selectPP(v) {
    if (_selectPP.value != v) {
      _selectPP.value = v;
      loadSevendDaysData();
    }
  }

  // 0交易 1终端 2服务商
  final _selectTopRightType = 0.obs;
  int get selectTopRightType => _selectTopRightType.value;
  set selectTopRightType(v) => _selectTopRightType.value = v;

  // 选择的月份
  final _selectDate = "".obs;
  String get selectDate => _selectDate.value;
  set selectDate(v) => _selectDate.value = v;

  dataFormat() {
    Map publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalBrand"].isNotEmpty &&
        publicHomeData["terminalBrand"] is List) {
      List terminalBrands = publicHomeData["terminalBrand"] ?? [];
      selectPP = 0;
      ppList = [
        {"enumValue": -1, "enumName": "全部品牌"},
        ...terminalBrands
      ];
    }
    selectDate = dateFormat.format(DateTime.now());
  }

  DateFormat dateFormat = DateFormat("yyyy年MM月");

  final _updateDate = "".obs;
  String get updateDate => _updateDate.value;
  set updateDate(v) => _updateDate.value = v;

  final _sevendDaysDatas = Rx<List<ChartSampleData>>([]);
  List<ChartSampleData> get sevendDaysDatas => _sevendDaysDatas.value;
  set sevendDaysDatas(v) => _sevendDaysDatas.value = v;

  loadSevendDaysData() {
    Future.delayed(const Duration(seconds: 1), () {
      updateDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      List tmpList = [];
      DateTime now = DateTime.now();
      for (var i = 0; i < 7; i++) {
        tmpList.add({
          "title":
              DateFormat("MM-dd").format(now.subtract(Duration(days: 6 - i))),
          "bs": 100.0 + math.Random().nextDouble() * (2000.0 - 100.0),
          "amout": 2000.0 + math.Random().nextDouble() * (100000.0 - 2000.0),
        });
      }
      sevendDaysDatas = tmpList
          .map((e) => ChartSampleData(
                x: e["title"] ?? "",
                y: e["amout"] ?? 0.0,
                secondSeriesYValue: e["bs"] ?? 0.0,
              ))
          .toList();
    });
  }

  homeDataNotify(arg) {
    dataFormat();
    update();
  }

  @override
  void onInit() {
    tagX = (calculateTextSize("统计", 18, AppDefault.fontBold, double.infinity, 1,
                        Global.navigatorKey.currentContext!)
                    .width +
                15.w * 2) /
            2 -
        9.w;
    dataFormat();
    bus.on(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    bus.on(HOME_PUBLIC_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onInit();
  }

  @override
  void onReady() {
    loadSevendDaysData();
    super.onReady();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, homeDataNotify);
    bus.off(HOME_PUBLIC_DATA_UPDATE_NOTIFY, homeDataNotify);
    super.onClose();
  }
}

class StatisticsPage extends GetView<StatisticsPageController> {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: myAppbar(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: 375.w,
                color: Colors.white,
                alignment: Alignment.center,
                child: sbhRow([
                  centClm([
                    getSimpleText("本月交易额(元)", 12, AppColor.textBlack),
                    ghb(5),
                    getSimpleText(priceFormat(24678.59), 30, AppColor.textBlack,
                        isBold: true)
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                  getRichText("同比上月  ", "-77%", 12, AppColor.textBlack, 18,
                      AppColor.theme,
                      isBold2: true)
                ],
                    width: 345,
                    height: 101,
                    crossAxisAlignment: CrossAxisAlignment.end),
              ),
              // 近7日图表视图
              sevenDaysChartView(),
              // 交易金额统计
              dealView(),
              ghb(20)
            ],
          ),
        ),
      ),
    );
  }

  // 近7日图表视图
  Widget sevenDaysChartView() {
    return Container(
      width: 375.w,
      color: Colors.white,
      alignment: Alignment.topCenter,
      margin: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          sbhRow([
            getSimpleText("近七日数据统计", 16, AppColor.textBlack, isBold: true),
            GetX<StatisticsPageController>(
              builder: (_) {
                return controller.updateDate.isEmpty
                    ? gwb(0)
                    : getSimpleText("数据更新与：${controller.updateDate}", 10,
                        AppColor.assisText);
              },
            )
          ], width: 345, height: 51),
          ghb(10),
          sbRow([
            centRow([
              centRow([
                Container(
                    width: 6.w, height: 6.w, color: const Color(0xFF007BFF)),
                gwb(5),
                getSimpleText("交易笔数", 10, AppColor.textBlack)
              ]),
              gwb(20),
              centRow([
                Container(
                    width: 15.w, height: 1.w, color: const Color(0xFF08C487)),
                gwb(5),
                getSimpleText("交易量", 10, AppColor.textBlack)
              ])
            ]),
            getSimpleText("单位：元", 12, AppColor.assisText)
          ], width: 345),
          ghb(10),
          SizedBox(
            width: 345.w,
            height: 180.w,
            child: GetX<StatisticsPageController>(builder: (_) {
              return SfCartesianChart(
                // title: ChartTitle(text: 'Sales report'),
                // legend: Legend(isVisible: true),

                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                    // rangePadding: ChartRangePadding.round,
                    // maximumLabelWidth: 1.5,
                    labelStyle:
                        TextStyle(fontSize: 12.sp, color: AppColor.text3),
                    majorGridLines: const MajorGridLines(width: 0),
                    edgeLabelPlacement: EdgeLabelPlacement.shift),
                primaryYAxis: NumericAxis(
                    numberFormat: NumberFormat.compact(),
                    minimum: 0,
                    // desiredIntervals: 5,
                    maximumLabels: 6,
                    axisLine:
                        const AxisLine(width: 0.0, color: Colors.transparent),
                    majorTickLines: const MajorTickLines(
                        color: Colors.transparent, width: 0.0),
                    labelStyle:
                        TextStyle(fontSize: 12.sp, color: AppColor.text3),
                    // interval: 50,
                    // maximum: 150,
                    // decimalPlaces: 6,
                    majorGridLines: MajorGridLines(
                        width: 0.5.w, color: AppColor.lineColor)),
                axes: <ChartAxis>[
                  NumericAxis(
                    axisLine:
                        const AxisLine(width: 0, color: Colors.transparent),
                    // numberFormat: NumberFormat.compact(),
                    majorGridLines:
                        MajorGridLines(width: 0.5.w, color: AppColor.lineColor),
                    majorTickLines: const MajorTickLines(
                        color: Colors.transparent, width: 0.0),
                    opposedPosition: true,
                    name: 'yAxis1',
                    labelStyle:
                        TextStyle(fontSize: 12.sp, color: AppColor.text3),
                    // interval: 1000,
                    minimum: 0,
                    maximumLabels: 6,
                    // desiredIntervals: 5,
                    // maximum: 7000
                  )
                ],
                series: _getDefaultAnimationSeries(controller.sevendDaysDatas),
                // selectionType: SelectionType.cluster,
                tooltipBehavior: TooltipBehavior(enable: true),
              );
            }),
          ),
          ghb(25)
        ],
      ),
    );
  }

  // 近七日图表数据绘制
  List<ChartSeries<ChartSampleData, String>> _getDefaultAnimationSeries(
      List<ChartSampleData> chartDatas) {
    return <ChartSeries<ChartSampleData, String>>[
      ColumnSeries<ChartSampleData, String>(
          animationDuration: 1000,
          dataSource: chartDatas,
          trackColor: AppColor.textGrey5,
          xValueMapper: (ChartSampleData sales, _) => "${sales.x}",
          yValueMapper: (ChartSampleData sales, _) =>
              double.parse(priceFormat(sales.y)),
          color: AppColor.theme2,
          width: 0.5,
          name: "交易量"),
      LineSeries<ChartSampleData, String>(
        animationDuration: 1000,
        dataSource: chartDatas,
        width: 2.5,
        onRendererCreated: (ChartSeriesController controller) {
          // _chartSeriesController2 = controller;
        },
        xValueMapper: (ChartSampleData sales, _) => "${sales.x}",
        yValueMapper: (ChartSampleData sales, _) => sales.secondSeriesYValue,
        yAxisName: 'yAxis1',
        color: const Color(0xFF08C487),
        name: "交易笔数",
        markerSettings:
            const MarkerSettings(isVisible: true, color: Colors.white),
      )
    ];
  }

//交易金额统计
  Widget dealView() {
    return GetBuilder<StatisticsPageController>(builder: (_) {
      return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 15.w),
        width: 375.w,
        color: Colors.white,
        child: Column(
          children: [
            ghb(17.5),
            sbRow([
              getSimpleText("交易金额统计", 16, AppColor.textBlack, isBold: true),
              CustomButton(
                onPressed: () {
                  showDatePick();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  height: 24.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      border:
                          Border.all(width: 0.5.w, color: AppColor.lineColor)),
                  alignment: Alignment.center,
                  child: centRow([
                    GetX<StatisticsPageController>(builder: (_) {
                      return getSimpleText(
                          controller.selectDate, 12, AppColor.textBlack);
                    }),
                    gwb(12),
                    Image.asset(
                      assetsName("income/btn_down_arrow"),
                      width: 6.w,
                      fit: BoxFit.fitWidth,
                    )
                  ]),
                ),
              ),
            ], width: 345),
            ghb(25),
            Container(
              width: 345.w,
              height: 30.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(15.w)),
              child: Stack(
                children: [
                  Positioned.fill(
                      child: centRow(List.generate(
                          2,
                          (index) => CustomButton(
                                onPressed: () {
                                  controller.dealSelectIdx = index;
                                },
                                child: SizedBox(
                                  width: 345.w / 2,
                                  height: 30.w,
                                  child: Center(
                                    child: getSimpleText(
                                        index == 0 ? "交易类型" : "卡类型",
                                        14,
                                        AppColor.textBlack),
                                  ),
                                ),
                              )))),
                  GetX<StatisticsPageController>(builder: (_) {
                    return AnimatedPositioned(
                        left: 345.w / 2 * controller.dealSelectIdx,
                        top: 0,
                        width: 345.w / 2,
                        height: 30.w,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.w),
                            color: AppColor.theme,
                          ),
                          child: getSimpleText(
                              controller.dealSelectIdx == 0 ? "交易类型" : "卡类型",
                              14,
                              Colors.white),
                        ));
                  })
                ],
              ),
            ),
            GetX<StatisticsPageController>(builder: (_) {
              int length = controller.dealSelectIdx == 0 ? 6 : 2;
              return centClm(
                  List.generate(
                      length,
                      (index) => centClm([
                            sbhRow([
                              centRow([
                                Image.asset(
                                  assetsName(
                                      "statistics_page/icon_dealtype_${index == 0 ? "normal" : index == 1 ? "alipay" : index == 2 ? "wx" : index == 3 ? "union" : index == 4 ? "union" : "up"}"),
                                  width: 30.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                gwb(13),
                                getSimpleText(
                                    index == 0
                                        ? "正常"
                                        : index == 1
                                            ? "支付宝"
                                            : index == 2
                                                ? "微信支付"
                                                : index == 3
                                                    ? "银联二维码≤1000"
                                                    : index == 4
                                                        ? "银联二维码＞1000"
                                                        : "成长值",
                                    14,
                                    AppColor.textBlack)
                              ]),
                              getSimpleText(
                                  "5226513.00", 16, AppColor.textBlack,
                                  isBold: true)
                            ], width: 375 - 30 * 2, height: 55),
                            index >= length - 1 ? ghb(0) : gline(270, 0.5)
                          ])),
                  crossAxisAlignment: CrossAxisAlignment.end);
            }),
            SizedBox(
              width: 375.w,
              height: 120.w,
              child: Center(
                  child: sbRow(
                      List.generate(
                          2,
                          (index) => SizedBox(
                                width: 345.w / 2,
                                child: Center(
                                    child: centClm([
                                  getSimpleText(
                                      "15216245.20", 18, AppColor.textBlack,
                                      isBold: true),
                                  ghb(12),
                                  getSimpleText(
                                      index == 0 ? "服务商交易额(元)" : "我的交易额(元)",
                                      12,
                                      AppColor.textBlack)
                                ])),
                              )),
                      width: 345)),
            )
          ],
        ),
      );
    });
  }

  // 月份选择器
  showDatePick() async {
    DateTime now = DateTime.now();
    DateTime? selectDate = await showMonthPicker(
        context: Global.navigatorKey.currentContext!,
        // initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: controller.dateFormat.parse(controller.selectDate),
        firstDate: DateTime(now.year - 5, now.month),
        lastDate: DateTime.now(),
        cancelWidget: getSimpleText("取消", 15, AppColor.theme),
        confirmWidget: getSimpleText("确认", 15, AppColor.theme));
    if (selectDate != null) {
      controller.selectDate = controller.dateFormat.format(selectDate);
    }
  }

  // 自定义导航栏
  PreferredSize myAppbar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(375.w, 46.1.w + paddingSizeTop(context)),
      child: Container(
        padding: EdgeInsets.only(top: paddingSizeTop(context) + 20.w),
        color: Colors.white,
        child: Column(
          children: [
            Row(
              children: List.generate(
                  3,
                  (index) => CustomButton(
                        key: controller.keyList[index],
                        onPressed: () {
                          controller.topIdx = index;
                          controller.changeTagPosition();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: centClm([
                            GetX<StatisticsPageController>(builder: (_) {
                              controller.topIdx;
                              return getSimpleText(
                                  index == 0
                                      ? "统计"
                                      : index == 1
                                          ? "服务商"
                                          : "商户",
                                  controller.topIdx == index ? 18 : 16,
                                  controller.topIdx == index
                                      ? AppColor.textBlack
                                      : AppColor.textGrey5,
                                  isBold: controller.topIdx == index);
                            }),
                            ghb(6),
                          ]),
                        ),
                      )),
            ),
            SizedBox(
              width: 375.w,
              height: 3.w,
              child: Stack(
                children: [
                  GetX<StatisticsPageController>(builder: (_) {
                    return AnimatedPositioned(
                        top: 0,
                        left: controller.tagX,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 18.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.5.w),
                              color: AppColor.theme),
                        ));
                  })
                ],
              ),
            ),
            gline(375, 0.5),
            ghb(25),
            sbRow([
              DropdownButtonHideUnderline(
                  child: DropdownButton2(
                      dropdownElevation: 0,
                      buttonElevation: 0,
                      offset: Offset(0, -5.w),
                      customButton: Container(
                        // width: 105.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          height: 24.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.w),
                              color: AppColor.pageBackgroundColor),
                          alignment: Alignment.center,
                          child: centRow([
                            GetX<StatisticsPageController>(builder: (_) {
                              return getSimpleText(
                                  controller.ppList[controller.selectPP]
                                          ["enumName"] ??
                                      "",
                                  12,
                                  AppColor.textBlack);
                            }),
                            gwb(12),
                            Image.asset(
                              assetsName("income/btn_down_arrow"),
                              width: 6.w,
                              fit: BoxFit.fitWidth,
                            )
                          ]),
                        ),
                      ),
                      items: List.generate(
                          controller.ppList.length,
                          (index) => DropdownMenuItem<int>(
                              value: index,
                              child: centClm([
                                SizedBox(
                                  height: 30.w,
                                  width: 90.w,
                                  child: Align(
                                    alignment: const Alignment(-1, 0),
                                    child: GetX<StatisticsPageController>(
                                        builder: (_) {
                                      return Padding(
                                        padding: EdgeInsets.only(left: 9.w),
                                        child: getSimpleText(
                                            "${controller.ppList[index]["enumName"] ?? ""}",
                                            12,
                                            controller.selectPP == index
                                                ? AppColor.textRed
                                                : AppColor.textBlack),
                                      );
                                    }),
                                  ),
                                ),
                              ]))),
                      // value: ctrl.machineDataIdx,
                      value: controller.selectPP,
                      buttonWidth: 90.w,
                      buttonHeight: 60.w,
                      itemHeight: 30.w,
                      onChanged: (value) {
                        controller.selectPP = value;
                      },
                      itemPadding: EdgeInsets.zero,
                      dropdownPadding: EdgeInsets.zero,
                      // dropdownWidth: 90.w,
                      dropdownDecoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.w),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0x1A040000),
                                // offset: Offset(0, 5.w),
                                blurRadius: 5.w)
                          ]))),
              centRow(List.generate(
                  3,
                  (index) => CustomButton(
                        onPressed: () {
                          controller.selectTopRightType = index;
                        },
                        child:
                            GetX<StatisticsPageController>(builder: (context) {
                          return Container(
                            width: 55.w,
                            height: 24.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                border: controller.selectTopRightType == index
                                    ? null
                                    : Border.all(
                                        width: 0.5.w,
                                        color: AppColor.lineColor),
                                borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(index == 0 ? 4.w : 0),
                                    right:
                                        Radius.circular(index == 2 ? 4.w : 0)),
                                color: controller.selectTopRightType == index
                                    ? AppColor.theme
                                    : Colors.white),
                            child: getSimpleText(
                                index == 0
                                    ? "交易"
                                    : index == 1
                                        ? "终端"
                                        : "服务商",
                                12,
                                controller.selectTopRightType == index
                                    ? Colors.white
                                    : AppColor.textBlack),
                          );
                        }),
                      )))
            ], width: 345),
          ],
        ),
      ),
    );
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData(
      {this.x,
      this.y,
      this.xValue,
      this.yValue,
      this.secondSeriesYValue,
      this.thirdSeriesYValue,
      this.pointColor,
      this.size,
      this.text,
      this.open,
      this.close,
      this.low,
      this.high,
      this.volume});

  /// Holds x value of the datapoint
  final dynamic x;

  /// Holds y value of the datapoint
  final num? y;

  /// Holds x value of the datapoint
  final dynamic xValue;

  /// Holds y value of the datapoint
  final num? yValue;

  /// Holds y value of the datapoint(for 2nd series)
  final num? secondSeriesYValue;

  /// Holds y value of the datapoint(for 3nd series)
  final num? thirdSeriesYValue;

  /// Holds point color of the datapoint
  final Color? pointColor;

  /// Holds size of the datapoint
  final num? size;

  /// Holds datalabel/text value mapper of the datapoint
  final String? text;

  /// Holds open value of the datapoint
  final num? open;

  /// Holds close value of the datapoint
  final num? close;

  /// Holds low value of the datapoint
  final num? low;

  /// Holds high value of the datapoint
  final num? high;

  /// Holds open value of the datapoint
  final num? volume;
}
