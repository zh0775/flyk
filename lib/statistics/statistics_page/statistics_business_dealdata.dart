import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_page.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticsBusinessDealDataBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsBusinessDealDataController>(
        StatisticsBusinessDealDataController(datas: Get.arguments));
  }
}

class StatisticsBusinessDealDataController extends GetxController {
  final dynamic datas;
  StatisticsBusinessDealDataController({this.datas});

  List chartColors = [
    '#EA80FC',
    '#FF7BBF',
    '#FE9677',
    '#F5EB6D',
    '#9CB898',
    '#88F4FF',
    '#EFDBCB',
    '#5983FC',
    '#A7226F',
    '#F46C3F',
    '#3E60C1',
    '#4BB4DE',
    '#1F9CE4',
    '#FFCdAA',
    '#ED8554',
    '#F64668',
    '#964EC2',
    '#AA4FF6',
    '#F7DC68',
    '#2E4583',
    '#3B8AC4',
    '#625AD8',
    '#EE8980',
    '#BE375F',
    '#9B4063',
    '#50409A',
    '#8D39EC',
    '#ECB1AC',
    '#2E9599',
    '#293556',
    '#345DA7',
    '#7339AB',
    '#F14666',
    '#5F236B',
    '#41436A',
    '#313866',
    '#7827E6'
  ];

  Color getChartColor(int index) {
    String cStr = chartColors[index % chartColors.length];
    return Color(int.parse("0xFF${cStr.substring(1, cStr.length)}"));
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  List<ChartSampleData> chartDatas1 = [];
  List<ChartSampleData> chartDatas2 = [];

  final _dealSelectIdx = 0.obs;
  int get dealSelectIdx => _dealSelectIdx.value;
  set dealSelectIdx(v) => _dealSelectIdx.value = v;

  final _dealSelect2Idx = 0.obs;
  int get dealSelect2Idx => _dealSelect2Idx.value;
  set dealSelect2Idx(v) => _dealSelect2Idx.value = v;

  final _monthDateStr = "".obs;
  String get monthDateStr => _monthDateStr.value;
  set monthDateStr(v) {
    if (_monthDateStr.value != v) {
      _monthDateStr.value = v;
      loadData();
    }
  }

  final _dayDateStr = "".obs;
  String get dayDateStr => _dayDateStr.value;
  set dayDateStr(v) {
    if (_dayDateStr.value != v) {
      _dayDateStr.value = v;
      loadData();
    }
  }

  final _topIdx = 0.obs;
  int get topIdx => _topIdx.value;
  set topIdx(v) {
    if (isPageAnimate) return;
    if (_topIdx.value != v) {
      _topIdx.value = v;
      changePage(topIdx);
      loadData();
    }
  }

  bool isPageAnimate = false;
  final pageCtrl = PageController();
  changePage(int? toIdx) {
    if (isPageAnimate) {
      return;
    }
    isPageAnimate = true;
    int idx = toIdx ?? topIdx;
    pageCtrl
        .animateToPage(idx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut)
        .then((value) {
      isPageAnimate = false;
    });
  }

  List dataLists = [
    [[], []],
    [[], []]
  ];
  List pageNos = [1, 1];
  List pageSizes = [20, 20];
  List counts = [0, 0];

  double totalPrice = 0.0;
  double totalPrice2 = 0.0;

  DateFormat monthFormat = DateFormat("yyyy-MM");
  DateFormat dayFormat = DateFormat("yyyy-MM-dd");

  String buildId = "StatisticsBusinessDealData_buildid_";

  loadData({int? loadIdx}) {
    int myLoadIdx = loadIdx ?? topIdx;

    String start = "";
    String end = "";
    if (myLoadIdx == 0) {
      DateTime time = monthFormat.parse(monthDateStr);
      start = dayFormat.format(DateTime(time.year, time.month, 1));
      end = dayFormat.format(DateTime(time.year, time.month + 1, 0));
    } else {
      DateTime time = dayFormat.parse(dayDateStr);
      start = dayFormat.format(DateTime(time.year, time.month, time.day));
      end = dayFormat.format(DateTime(time.year, time.month, time.day));
    }

    simpleRequest(
        url: Urls.userMerchantOrder3List,
        params: {
          "startingTime": start,
          "end_Time": end,
          "tNo": businessData["tNo"] ?? ""
        },
        success: (success, json) {
          if (success) {
            List list = json["data"] ?? [];

            if (myLoadIdx == 0) {
              totalPrice = 0.0;
            } else {
              totalPrice2 = 0.0;
            }

            for (var e in list) {
              if (myLoadIdx == 0) {
                totalPrice += (e["tolTxnAmt"] ?? 0.0);
              } else {
                totalPrice2 += (e["tolTxnAmt"] ?? 0.0);
              }
            }

            if (myLoadIdx == 0) {
              chartDatas1 = list
                  .asMap()
                  .entries
                  .map((e) => ChartSampleData(
                      x: e.value["title"] ?? "",
                      y: totalPrice == 0 ? 1 : e.value["tolTxnAmt"] ?? 0.0,
                      pointColor: getChartColor(e.key)))
                  .toList();
            } else {
              chartDatas2 = list
                  .asMap()
                  .entries
                  .map((e) => ChartSampleData(
                      x: e.value["title"] ?? "",
                      y: totalPrice2 == 0 ? 1 : e.value["tolTxnAmt"] ?? 0.0,
                      pointColor: getChartColor(e.key)))
                  .toList();
            }

            List list1 = [];
            List list2 = [];
            for (var e in list) {
              int v = e["tranValue"] ?? -1;
              if (v == 1 || v == 2) {
                list2.add(e);
              } else {
                list1.add(e);
              }
            }
            dataLists[myLoadIdx][0] = list1;
            dataLists[myLoadIdx][1] = list2;

            update(["$buildId$myLoadIdx"]);
          }
        },
        after: () {
          isFirstLoading = false;
          isLoading = false;
        });
  }

  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  Map businessData = {};
  @override
  void onInit() {
    businessData = (datas ?? {})["data"] ?? {};
    DateTime now = DateTime.now();
    _dayDateStr.value = dayFormat.format(now);
    _monthDateStr.value = monthFormat.format(now);
    super.onInit();
  }
}

class StatisticsBusinessDealData
    extends GetView<StatisticsBusinessDealDataController> {
  /// 商户-交易明细
  ///
  /// 参数
  ///
  /// data 必传 商户信息
  const StatisticsBusinessDealData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(context, "交易明细"),
        body: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 50.w,
              child: Container(
                  color: Colors.white,
                  child: Stack(children: [
                    Positioned(
                        top: 20.w,
                        left: 0,
                        right: 0,
                        height: 20.w,
                        child: Row(
                            children: List.generate(2, (index) {
                          return CustomButton(onPressed: () {
                            controller.topIdx = index;
                          }, child: GetX<StatisticsBusinessDealDataController>(
                              builder: (_) {
                            return SizedBox(
                                width: 375.w / 2 - 0.1.w,
                                child: Center(
                                    child: getSimpleText(
                                  index == 0 ? "按月统计" : "按日统计",
                                  15,
                                  controller.topIdx == index
                                      ? AppColor.theme
                                      : AppColor.text2,
                                  isBold: controller.topIdx == index,
                                )));
                          }));
                        }))),
                    GetX<StatisticsBusinessDealDataController>(
                      builder: (_) {
                        return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            top: 47.w,
                            width: 18.w,
                            left: controller.topIdx * (375.w / 2 - 0.1.w) +
                                ((375.w / 2 - 0.1.w) - 15.w) / 2,
                            height: 3.w,
                            child: Container(
                                decoration: BoxDecoration(
                                    color: AppColor.theme,
                                    borderRadius:
                                        BorderRadius.circular(1.5.w))));
                      },
                    )
                  ]))),
          Positioned.fill(
              top: 50.w,
              child: PageView.builder(
                controller: controller.pageCtrl,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return contentView(index);
                },
              ))
        ]));
  }

  Widget contentView(int idx) {
    return GetBuilder<StatisticsBusinessDealDataController>(
        id: "${controller.buildId}$idx",
        builder: (_) {
          List dealList = controller.dataLists[idx];
          return Container(
            alignment: Alignment.topCenter,
            margin: EdgeInsets.only(top: 15.w),
            width: 375.w,
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ghb(17.5),
                  sbRow([
                    getSimpleText("交易金额统计", 16, AppColor.textBlack,
                        isBold: true),
                    CustomButton(
                        onPressed: () {
                          if (idx == 0) {
                            showMonthPick();
                          } else {
                            showDayPick();
                          }
                          // showDatePick(controller.dealSelectDate);
                        },
                        child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            height: 24.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.w),
                                border: Border.all(
                                    width: 0.5.w, color: AppColor.lineColor)),
                            alignment: Alignment.center,
                            child: centRow([
                              GetX<StatisticsBusinessDealDataController>(
                                  builder: (_) {
                                return getSimpleText(
                                    idx == 0
                                        ? controller.monthDateStr
                                        : controller.dayDateStr,
                                    12,
                                    AppColor.textBlack);
                              }),
                              gwb(12),
                              Image.asset(assetsName("income/btn_down_arrow"),
                                  width: 6.w, fit: BoxFit.fitWidth)
                            ])))
                  ], width: 345),
                  ghb(25),
                  Container(
                      width: 345.w,
                      height: 30.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(15.w)),
                      child: Stack(children: [
                        Positioned.fill(
                            child: centRow(List.generate(
                                2,
                                (index) => CustomButton(
                                      onPressed: () {
                                        if (idx == 0) {
                                          controller.dealSelectIdx = index;
                                        } else {
                                          controller.dealSelect2Idx = index;
                                        }
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
                        GetX<StatisticsBusinessDealDataController>(
                            builder: (_) {
                          return AnimatedPositioned(
                              left: 345.w /
                                  2 *
                                  (idx == 0
                                      ? controller.dealSelectIdx
                                      : controller.dealSelect2Idx),
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
                                      (idx == 0
                                                  ? controller.dealSelectIdx
                                                  : controller
                                                      .dealSelect2Idx) ==
                                              0
                                          ? "交易类型"
                                          : "卡类型",
                                      14,
                                      Colors.white)));
                        })
                      ])),
                  chartView(idx),
                  GetX<StatisticsBusinessDealDataController>(builder: (_) {
                    List dataList = dealList[(idx == 0
                        ? controller.dealSelectIdx
                        : controller.dealSelect2Idx)];
                    return centClm(
                        List.generate(
                            dataList.length,
                            (index) => centClm([
                                  sbhRow([
                                    centRow([
                                      Image.asset(
                                        assetsName(
                                            "statistics_page/icon_dealtype${dataList[index]["tranValue"] ?? 1}"),
                                        width: 30.w,
                                        fit: BoxFit.fitWidth,
                                      ),
                                      gwb(13),
                                      getSimpleText(
                                          dataList[index]["title"] ?? "",
                                          14,
                                          AppColor.textBlack)
                                    ]),
                                    getSimpleText(
                                        priceFormat(
                                            dataList[index]["tolTxnAmt"] ?? 0),
                                        16,
                                        AppColor.textBlack,
                                        isBold: true)
                                  ], width: 375 - 30 * 2, height: 55),
                                  index >= dataList.length - 1
                                      ? ghb(0)
                                      : gline(270, 0.5)
                                ])),
                        crossAxisAlignment: CrossAxisAlignment.end);
                  }),
                  SizedBox(
                      width: 375.w,
                      height: 120.w,
                      child: Center(
                          child: getRichText(
                              "累计交易总额(元)      ",
                              priceFormat(idx == 0
                                  ? controller.totalPrice
                                  : controller.totalPrice2),
                              12,
                              AppColor.textBlack,
                              24,
                              AppColor.theme,
                              isBold2: true)))
                ],
              ),
            ),
          );
        });
  }

  Widget chartView(int idx) {
    List<ChartSampleData> charts =
        idx == 0 ? controller.chartDatas1 : controller.chartDatas2;
    return SizedBox(
        width: 375.w,
        height: 210.w,
        child: SfCircularChart(
            key: ValueKey(idx),
            // margin: EdgeInsets.zero,
            title: ChartTitle(text: ''),
            legend: Legend(
                isVisible: true,
                width: "30%",
                // itemPadding: 12.w,
                // offset: Offset(100, 0),
                alignment: ChartAlignment.center,
                legendItemBuilder: (legendText, series, point, seriesIndex) {
                  // ChartSampleData pointData = point as ChartSampleData;
                  return Padding(
                      padding:
                          EdgeInsets.only(top: seriesIndex == 0 ? 0 : 12.w),
                      child: Row(children: [
                        Container(
                          width: 10.w,
                          height: 10.w,
                          color: point.pointColor ??
                              controller.getChartColor(seriesIndex),
                        ),
                        gwb(8),
                        getSimpleText(
                            "${point.x}(${priceFormat((idx == 0 ? controller.totalPrice : controller.totalPrice2) == 0 ? 0 : point.y)})",
                            12,
                            AppColor.textBlack)
                      ]));
                },
                overflowMode: LegendItemOverflowMode.scroll),
            series: <DoughnutSeries<ChartSampleData, String>>[
              DoughnutSeries<ChartSampleData, String>(
                  radius: '90%',
                  // explode: true,
                  // explodeOffset: '20%',
                  animationDuration: 1000,
                  dataSource: charts,
                  xValueMapper: (ChartSampleData data, _) => data.x as String,
                  yValueMapper: (ChartSampleData data, _) => data.y,
                  dataLabelMapper: (ChartSampleData data, _) =>
                      data.x as String,
                  startAngle: 100,
                  endAngle: 100,
                  pointRadiusMapper: (ChartSampleData data, _) => data.text,
                  pointColorMapper: (ChartSampleData data, _) => data.pointColor
                  // dataLabelSettings: const DataLabelSettings(
                  //     isVisible: true,
                  //     labelPosition: ChartDataLabelPosition.outside)
                  )
            ],
            // onTooltipRender: (TooltipArgs args) {
            //   final NumberFormat format = NumberFormat.decimalPattern();
            //   args.text = args.dataPoints![args.pointIndex!.toInt()].x
            //           .toString() +
            //       ' : ' +
            //       format.format(
            //           args.dataPoints![args.pointIndex!.toInt()].y);
            // },
            tooltipBehavior: TooltipBehavior(
                enable: true,
                builder: (data, point, series, pointIndex, seriesIndex) {
                  ChartSampleData myPoint = data;
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: getSimpleText(
                          "${myPoint.x}:${priceFormat((idx == 0 ? controller.totalPrice : controller.totalPrice2) == 0 ? 0 : myPoint.y)}",
                          12,
                          Colors.white));
                })));
  }

  showMonthPick() async {
    DateTime? time = await showMonthPicker(
        context: Global.navigatorKey.currentContext!,
        initialDate: controller.dayFormat.parse(controller.dayDateStr),
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now(),
        cancelWidget: getSimpleText("取消", 15, AppColor.theme),
        confirmWidget: getSimpleText("确认", 15, AppColor.theme));
    if (time != null) {
      controller.monthDateStr = controller.monthFormat.format(time);
    }
  }

  showDayPick() async {
    DateTime? time = await showDatePicker(
        context: Global.navigatorKey.currentContext!,
        initialDate: controller.dayFormat.parse(controller.dayDateStr),
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now());
    if (time != null) {
      controller.dayDateStr = controller.dayFormat.format(time);
    }
  }
}
