// 统计 主页
import 'dart:math' as math;

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_business_list.dart';
import 'package:cxhighversion2/statistics/statistics_page/statistics_facilitator_list.dart';
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

  final _topIdx = 0.obs;
  int get topIdx => _topIdx.value;
  set topIdx(v) {
    if (_topIdx.value != v) {
      _topIdx.value = v;
      changePage(topIdx);
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

  /// 服务商排序
  List filterTypeList = [
    {"id": 0, "name": "默认排序"},
    {"id": 1, "name": "当日激活"},
    {"id": 2, "name": "当月激活"},
    {"id": 3, "name": "当月交易"},
    {"id": 4, "name": "级别排序"}
  ];
  final _filterTypeIdx = 0.obs;

  /// 服务商排序index
  int get filterTypeIdx => _filterTypeIdx.value;
  set filterTypeIdx(v) {
    if (_filterTypeIdx.value != v) {
      _filterTypeIdx.value = v;
    }
  }

  List<GlobalKey> keyList = [GlobalKey(), GlobalKey(), GlobalKey()];

  final _dealSelectIdx = 0.obs;
  int get dealSelectIdx => _dealSelectIdx.value;
  set dealSelectIdx(v) => _dealSelectIdx.value = v;

  /// 服务商统计
  List teamList = [
    {"id": 0, "name": "全部"},
    {"id": 1, "name": "自营"},
    {"id": 2, "name": "团队"},
  ];
  final _machineTeamSelectIdx = 0.obs;
  int get machineTeamSelectIdx => _machineTeamSelectIdx.value;
  set machineTeamSelectIdx(v) {
    if (_machineTeamSelectIdx.value != v) {
      _machineTeamSelectIdx.value = v;
      loadBusinessData();
    }
  }

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

  final _selectTopRightType = 0.obs;

  /// 0交易 1终端 2服务商
  int get selectTopRightType => _selectTopRightType.value;
  set selectTopRightType(v) {
    if (_selectTopRightType.value != v) {
      _selectTopRightType.value = v;
      // 数据如果为空则请求
      if (selectTopRightType == 0) {
        // && sevendDaysDatas.isEmpty
        loadSevendDaysData();
      } else if (selectTopRightType == 1) {
        //  && machineDatas.isEmpty
        loadMachineData();
      } else if (selectTopRightType == 2) {
        //  && businessDatas.isEmpty
        loadBusinessData();
      }
    }
  }

  // 交易金额选择的月份
  final _dealSelectDate = "".obs;
  String get dealSelectDate => _dealSelectDate.value;
  set dealSelectDate(v) {
    if (_dealSelectDate.value != v) {
      _dealSelectDate.value = v;
      loadSevendDaysData();
    }
  }

  // 终端 选择月份
  final _machineSelectDate = "".obs;
  String get machineSelectDate => _machineSelectDate.value;
  set machineSelectDate(v) => _machineSelectDate.value = v;

  // 服务商 选择月份
  final _businessSelectDate = "".obs;
  String get businessSelectDate => _businessSelectDate.value;
  set businessSelectDate(v) => _businessSelectDate.value = v;

  Map homeTeamTanNo = {};
  //交易额相比上月比例
  final _comparedLastM = 0.0.obs;
  double get comparedLastM => _comparedLastM.value;
  set comparedLastM(v) => _comparedLastM.value = v;

  dataFormat() {
    Map homeData = AppDefault().homeData;
    homeTeamTanNo = homeData["homeTeamTanNo"] ?? {};
    // 交易额相比上月百分比
    double teamLastMAmount =
        double.parse("${homeTeamTanNo["teamLastMAmount"] ?? "0"}");

    double teamThisMAmount =
        double.parse("${homeTeamTanNo["teamThisMAmount"] ?? "0"}");
    double dValue = teamThisMAmount - teamLastMAmount;
    String cStr =
        "${dValue >= 0 ? "+" : "-"}${dValue.abs() / (teamLastMAmount <= 0.0 ? 1 : teamLastMAmount)}";
    comparedLastM = double.parse(cStr);

    Map publicHomeData = AppDefault().publicHomeData;
    if (publicHomeData.isNotEmpty &&
        publicHomeData["terminalConfig"] != null &&
        publicHomeData["terminalConfig"].isNotEmpty &&
        publicHomeData["terminalConfig"] is List) {
      List terminalBrands = publicHomeData["terminalConfig"] ?? [];
      selectPP = 0;
      ppList = [
        {"enumValue": -1, "enumName": "全部品牌"},
        ...terminalBrands
            .map((e) => {"enumValue": e["id"], "enumName": e["terninal_Name"]})
      ];
    }
    if (dealSelectDate.isEmpty) {
      dealSelectDate = dateFormat.format(DateTime.now());
    }
    if (machineSelectDate.isEmpty) {
      machineSelectDate = dateFormat.format(DateTime.now());
    }
    if (businessSelectDate.isEmpty) {
      businessSelectDate = dateFormat.format(DateTime.now());
    }
  }

  DateFormat dateFormat = DateFormat("yyyy年MM月");

  final _updateDate = "".obs;
  String get updateDate => _updateDate.value;
  set updateDate(v) => _updateDate.value = v;

  /// 近七日交易数据
  List<ChartSampleData> get sevendDaysDatas => _sevendDaysDatas.value;
  final _sevendDaysDatas = Rx<List<ChartSampleData>>([]);
  set sevendDaysDatas(v) => _sevendDaysDatas.value = v;

  /// 终端统计数据
  List<ChartSampleData> get machineDatas => _machineDatas.value;
  final _machineDatas = Rx<List<ChartSampleData>>([]);
  set machineDatas(v) => _machineDatas.value = v;
  // 商户统计数据
  final _businessDatas = Rx<List<ChartSampleData>>([]);
  List<ChartSampleData> get businessDatas => _businessDatas.value;
  set businessDatas(v) => _businessDatas.value = v;

  Map machineData = {};
  String machineBuildId = "StatisticsPage_machineBuildId";

  /// 终端统计总数
  int totalMachineCount = 0;

  /// 请求终端统计数据
  loadMachineData() {
    DateTime date = dateFormat.parse(dealSelectDate);
    DateFormat date2 = DateFormat("yyyy-MM-dd");
    simpleRequest(
        url: Urls.userTermiList,
        params: {
          "terminalBrandId":
              ppList.isEmpty ? -1 : ppList[selectPP]["enumValue"] ?? -1,
          "startingTime": date2.format(DateTime(date.year, date.month, 1)),
          "end_Time": date2.format(DateTime(date.year, date.month + 1, 0)),
        },
        success: (success, json) {
          if (success) {
            machineData = json["data"] ?? {};
            machineDatas.clear();
            totalMachineCount = 0;

            /// 库存
            int noBingNum = machineData["noBingNum"] ?? 0;
            totalMachineCount += noBingNum;

            /// 出库
            int outNum = machineData["outNum"] ?? 0;
            totalMachineCount += outNum;

            /// 已激活
            int dateActNum = machineData["dateActNum"] ?? 0;
            totalMachineCount += dateActNum;

            /// 达标,有效激活
            int dateActivNum = machineData["dateActivNum"] ?? 0;
            totalMachineCount += dateActivNum;

            /// 无效
            int invalidNum = machineData["invalidNum"] ?? 0;
            totalMachineCount += invalidNum;

            machineDatas.add(ChartSampleData(
                x: "库存",
                y: totalMachineCount == 0 ? 1 : noBingNum,
                // text: maxKey == "noBingNum" ? "100%" : "90%",
                text: "100%",
                pointColor: getChartColor(0)));
            machineDatas.add(ChartSampleData(
                x: "出库",
                y: totalMachineCount == 0 ? 1 : outNum,
                // text: maxKey == "outNum" ? "100%" : "90%",
                text: "100%",
                pointColor: getChartColor(1)));
            machineDatas.add(ChartSampleData(
                x: "已激活",
                y: totalMachineCount == 0 ? 1 : dateActNum,
                // text: maxKey == "dateActNum" ? "100%" : "90%",
                text: "100%",
                pointColor: getChartColor(2)));
            machineDatas.add(ChartSampleData(
                x: "达标,有效激活",
                y: totalMachineCount == 0 ? 1 : dateActivNum,
                // text: maxKey == "dateActivNum" ? "100%" : "90%",
                text: "100%",
                pointColor: getChartColor(3)));
            machineDatas.add(ChartSampleData(
                x: "无效",
                y: totalMachineCount == 0 ? 1 : invalidNum,
                // text: maxKey == "invalidNum" ? "100%" : "90%",
                text: "100%",
                pointColor: getChartColor(4)));

            update([machineBuildId]);
            update();
          }
        },
        after: () {});
  }

  Map businessData = {};
  String businessBuildId = "StatisticsPage_businessData";

  /// 商户统计总数
  int totalBusinessCount = 0;

  /// 请求商户统计数据
  loadBusinessData() {
    DateTime date = dateFormat.parse(dealSelectDate);
    DateFormat date2 = DateFormat("yyyy-MM-dd");
    simpleRequest(
        url: Urls.userPeopleList,
        params: {
          "startingTime": date2.format(DateTime(date.year, date.month, 1)),
          "end_Time": date2.format(DateTime(date.year, date.month + 1, 0)),
          "teamType": teamList[machineTeamSelectIdx]["id"]
        },
        success: (success, json) {
          if (success) {
            businessData = json["data"] ?? {};
            businessDatas.clear();

            int chanTotalAddUser = businessData["chanTotalAddUser"] ?? 0;
            int soleTotalAddUser = businessData["soleTotalAddUser"] ?? 0;

            totalBusinessCount += chanTotalAddUser;
            totalBusinessCount += (chanTotalAddUser - soleTotalAddUser);

            businessDatas.add(ChartSampleData(
                x: "我的新增",
                y: totalBusinessCount == 0 ? 1 : soleTotalAddUser,
                text: "100%",
                pointColor: const Color(0xFF3AD3D2)));
            businessDatas.add(ChartSampleData(
                x: "其他新增",
                y: totalBusinessCount == 0
                    ? 1
                    : chanTotalAddUser - soleTotalAddUser,
                text: "100%",
                pointColor: const Color(0xFF437BFE)));
            update([businessBuildId]);
            update();
          }
        },
        after: () {});
  }

  Map dealData = {};
  List dealList = [[], []];
  String dealBuildId = "StatisticsPage_dealBuildId";
  // 请求7天交易数据
  loadSevendDaysData() {
    DateTime date = dateFormat.parse(dealSelectDate);
    DateFormat date2 = DateFormat("yyyy-MM-dd");
    simpleRequest(
        url: Urls.userTranList,
        params: {
          "terminalBrandId":
              ppList.isEmpty ? -1 : ppList[selectPP]["enumValue"] ?? -1,
          "startingTime": date2.format(DateTime(date.year, date.month, 1)),
          "end_Time": date2.format(DateTime(date.year, date.month + 1, 0)),
        },
        success: (success, json) {
          if (success) {
            dealData = json["data"] ?? {};
            // Map publicHomeData = AppDefault().homeData;
            List tranTopData = dealData["tranTopData"] ?? [];
            sevendDaysDatas = tranTopData
                .map((e) => ChartSampleData(
                      x: (e["rq"] ?? "").isEmpty
                          ? ""
                          : DateFormat("MM-dd").format(
                              DateFormat("yyyy/MM/dd HH:mm:ss").parse(e["rq"])),
                      y: e["tolTxnAmt"] ?? 0.0,
                      secondSeriesYValue: e["tolTxnNum"] ?? 0,
                    ))
                .toList();

            List tranTypeData = dealData["tranTypeData"] ?? [];
            List list1 = [];
            List list2 = [];
            for (var e in tranTypeData) {
              int v = e["tranValue"] ?? -1;
              if (v == 1 || v == 2) {
                list2.add(e);
              } else {
                list1.add(e);
              }
            }
            dealList[0] = list1;
            dealList[1] = list2;
            update([dealBuildId]);
            update();
          }
        },
        after: () {});
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
      child: GestureDetector(
        onTap: () => takeBackKeyboard(context),
        child: Scaffold(
          appBar: myAppbar(context),
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            // onPageChanged: (value) {
            //   controller.topIdx = value;
            //   controller.changeTagPosition();
            // },
            controller: controller.pageCtrl,
            children: [
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                        width: 375.w,
                        color: Colors.white,
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            ghb(25),
                            sbRow([
                              dropSelectView(),
                              centRow(List.generate(
                                  3,
                                  (index) => CustomButton(
                                        onPressed: () {
                                          controller.selectTopRightType = index;
                                        },
                                        child: GetX<StatisticsPageController>(
                                            builder: (context) {
                                          return Container(
                                            width: 55.w,
                                            height: 24.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: controller
                                                            .selectTopRightType ==
                                                        index
                                                    ? null
                                                    : Border.all(
                                                        width: 0.5.w,
                                                        color: AppColor
                                                            .lineColor),
                                                borderRadius:
                                                    BorderRadius.horizontal(
                                                        left: Radius.circular(
                                                            index == 0
                                                                ? 4.w
                                                                : 0),
                                                        right: Radius.circular(
                                                            index == 2
                                                                ? 4.w
                                                                : 0)),
                                                color: controller
                                                            .selectTopRightType ==
                                                        index
                                                    ? AppColor.theme
                                                    : Colors.white),
                                            child: getSimpleText(
                                                index == 0
                                                    ? "交易"
                                                    : index == 1
                                                        ? "终端"
                                                        : "服务商",
                                                12,
                                                controller.selectTopRightType ==
                                                        index
                                                    ? Colors.white
                                                    : AppColor.textBlack),
                                          );
                                        }),
                                      )))
                            ], width: 345),
                            GetBuilder<StatisticsPageController>(
                              builder: (_) {
                                return GetX<StatisticsPageController>(
                                  // 0交易 1终端 2服务商
                                  builder: (controller) {
                                    return controller.selectTopRightType == 1 ||
                                            controller.selectTopRightType == 2
                                        ? centRow(List.generate(
                                            2,
                                            (index) => SizedBox(
                                                  width: 345.w / 2,
                                                  height: 101.w,
                                                  child: Center(
                                                      child: centClm([
                                                    getSimpleText(
                                                        controller.selectTopRightType ==
                                                                1
                                                            ? index == 0
                                                                ? "终端总数(台)"
                                                                : "激活总数(台)"
                                                            : index == 0
                                                                ? "总服务商(人)"
                                                                : "本月新增人数",
                                                        12,
                                                        AppColor.textBlack),
                                                    ghb(5),
                                                    centRow([
                                                      getSimpleText(
                                                          controller.selectTopRightType ==
                                                                  1
                                                              ? "${controller.machineData[index == 0 ? "totalNum" : "totalActNum"] ?? "0"}"
                                                              : "${controller.homeTeamTanNo[index == 0 ? "teamTotalAddUser" : "teamThisMAddUser"] ?? "0"}",
                                                          30,
                                                          AppColor.textBlack,
                                                          isBold: true),
                                                      controller.selectTopRightType ==
                                                                  2 &&
                                                              index == 1
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.w),
                                                              child: Builder(
                                                                  builder:
                                                                      (context) {
                                                                int cLastData = int
                                                                        .parse(
                                                                            "${controller.homeTeamTanNo["teamThisMAddUser"] ?? "0"}") -
                                                                    int.parse(
                                                                        "${controller.homeTeamTanNo["teamLastMAddUser"] ?? "0"}");

                                                                return cLastData ==
                                                                        0
                                                                    ? gwb(0)
                                                                    : AnimatedRotation(
                                                                        turns: cLastData >
                                                                                0
                                                                            ? 1
                                                                            : 0.5,
                                                                        duration:
                                                                            const Duration(milliseconds: 100),
                                                                        child: Image.asset(
                                                                            assetsName(
                                                                                "statistics_page/icon_dataup"),
                                                                            width:
                                                                                9.w,
                                                                            fit: BoxFit.fitWidth),
                                                                      );
                                                              }),
                                                            )
                                                          : gwb(0)
                                                    ])
                                                  ])),
                                                )))
                                        : sbhRow([
                                            centClm([
                                              getSimpleText("本月交易额(元)", 12,
                                                  AppColor.textBlack),
                                              ghb(5),
                                              getSimpleText(
                                                  priceFormat(
                                                      controller.homeTeamTanNo[
                                                              "teamThisMAmount"] ??
                                                          0,
                                                      tenThousand: double.parse(
                                                              "${controller.homeTeamTanNo["teamThisMAmount"] ?? 0}") >=
                                                          100000),
                                                  30,
                                                  AppColor.textBlack,
                                                  isBold: true)
                                            ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start),
                                            getRichText(
                                                "同比上月  ",
                                                "${controller.comparedLastM >= 0 ? "+" : ""}${priceFormat(controller.comparedLastM * 100, savePoint: 0)}%",
                                                12,
                                                AppColor.textBlack,
                                                18,
                                                controller.comparedLastM < 0
                                                    ? AppColor.theme
                                                    : const Color(0xFF08C487),
                                                isBold2: true)
                                          ],
                                            width: 345,
                                            height: 101,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end);
                                  },
                                );
                              },
                            ),
                          ],
                        )),
                    GetX<StatisticsPageController>(builder: (_) {
                      return centClm([
                        // 近7日图表视图
                        controller.selectTopRightType == 0
                            ? sevenDaysChartView()
                            : pieWidget(),
                        // 交易金额统计
                        controller.selectTopRightType == 0
                            ? dealView()
                            : ghb(0),
                      ]);
                    }),
                    ghb(20)
                  ],
                ),
              ),
              const StatisticsFacilitatorList(),
              const StatisticsBusinessList(),
            ],
          ),
        ),
      ),
    );
  }

  // 饼状图
  // 终端设备数据统计 / 服务商人数统计
  Widget pieWidget() {
    return GetBuilder<StatisticsPageController>(builder: (_) {
      return Container(
        alignment: Alignment.topCenter,
        margin: EdgeInsets.only(top: 15.w),
        width: 375.w,
        color: Colors.white,
        child: GetX<StatisticsPageController>(builder: (context) {
          return Column(
            children: [
              ghb(17.5),
              sbRow([
                getSimpleText(
                    controller.selectTopRightType == 1 ? "终端设备数据统计" : "服务商人数统计",
                    16,
                    AppColor.textBlack,
                    isBold: true),
                CustomButton(
                  onPressed: () {
                    showDatePick(controller.selectTopRightType == 1
                        ? controller.machineSelectDate
                        : controller.businessSelectDate);
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
                      GetX<StatisticsPageController>(builder: (_) {
                        return getSimpleText(
                            controller.selectTopRightType == 1
                                ? controller.machineSelectDate
                                : controller.businessSelectDate,
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
              ], width: 345),
              ghb(25),
              SizedBox(
                  width: 375.w,
                  height: 210.w,
                  child: GetX<StatisticsPageController>(builder: (_) {
                    return SfCircularChart(
                        // margin: EdgeInsets.zero,
                        title: ChartTitle(text: ''),
                        legend: Legend(
                            isVisible: true,
                            width: "30%",
                            // itemPadding: 12.w,
                            // offset: Offset(100, 0),
                            alignment: ChartAlignment.center,
                            legendItemBuilder:
                                (legendText, series, point, seriesIndex) {
                              // ChartSampleData pointData = point as ChartSampleData;
                              return Padding(
                                  padding: EdgeInsets.only(
                                      top: seriesIndex == 0 ? 0 : 12.w),
                                  child: Row(children: [
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      color: point.pointColor ??
                                          controller.getChartColor(seriesIndex),
                                    ),
                                    gwb(8),
                                    getSimpleText(
                                        "${point.x}(${(controller.selectTopRightType == 1 && controller.totalMachineCount == 0) || (controller.selectTopRightType == 2 && controller.totalBusinessCount == 0) ? 0 : point.y}${controller.selectTopRightType == 1 ? "台" : "人"})",
                                        12,
                                        AppColor.textBlack)
                                  ]));
                            },
                            overflowMode: LegendItemOverflowMode.scroll),
                        series: <DoughnutSeries<ChartSampleData, String>>[
                          DoughnutSeries<ChartSampleData, String>(
                              radius: '110%',
                              // explode: true,
                              // explodeOffset: '20%',
                              animationDuration: 1000,
                              dataSource: controller.selectTopRightType == 1
                                  ? controller.machineDatas
                                  : controller.businessDatas,
                              xValueMapper: (ChartSampleData data, _) =>
                                  data.x as String,
                              yValueMapper: (ChartSampleData data, _) => data.y,
                              dataLabelMapper: (ChartSampleData data, _) =>
                                  data.x as String,
                              startAngle: 100,
                              endAngle: 100,
                              pointRadiusMapper: (ChartSampleData data, _) =>
                                  data.text,
                              pointColorMapper: (ChartSampleData data, _) =>
                                  data.pointColor
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
                          duration: 2000,
                          builder:
                              (data, point, series, pointIndex, seriesIndex) {
                            ChartSampleData myPoint = data;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: getSimpleText(
                                  "${myPoint.x}:${(controller.selectTopRightType == 1 && controller.totalMachineCount == 0) || (controller.selectTopRightType == 2 && controller.totalBusinessCount == 0) ? 0 : myPoint.y}${controller.selectTopRightType == 1 ? "台" : "人"}",
                                  12,
                                  Colors.white),
                            );
                          },
                        ));
                  })),
              ghb(30),
              centRow(List.generate(
                  controller.selectTopRightType == 1 ? 3 : 2,
                  (index) => SizedBox(
                      width:
                          345.w / (controller.selectTopRightType == 1 ? 3 : 2),
                      child: Center(
                          child: centClm([
                        getSimpleText(
                            "${controller.selectTopRightType == 1 ? controller.machineData[index == 0 ? "teamTotalBingTerminal" : index == 1 ? "teamTotalActTerminal" : "mineTotalActTerminal"] ?? 0 : controller.selectTopRightType == 2 ? controller.businessData[index == 0 ? "chanTotalAddUser" : "soleTotalAddUser"] ?? "" : ""}",
                            18,
                            AppColor.textBlack,
                            isBold: true),
                        ghb(12),
                        getSimpleText(
                            controller.selectTopRightType == 1
                                ? index == 0
                                    ? "本月总台数"
                                    : index == 1
                                        ? "团队激活"
                                        : "个人激活"
                                : controller.selectTopRightType == 2
                                    ? index == 0
                                        ? "服务商新增"
                                        : "我的新增"
                                    : "",
                            12,
                            AppColor.textBlack)
                      ]))))),
              ghb(25)
            ],
          );
        }),
      );
    });
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
                  showDatePick(controller.dealSelectDate);
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
                          controller.dealSelectDate, 12, AppColor.textBlack);
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
              List dataList = controller.dealList[controller.dealSelectIdx];

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
                                getSimpleText(dataList[index]["title"] ?? "",
                                    14, AppColor.textBlack)
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
                  child: sbRow(
                      List.generate(
                          2,
                          (index) => SizedBox(
                                width: 345.w / 2,
                                child: Center(
                                    child: centClm([
                                  getSimpleText(
                                      priceFormat(controller.dealData[index == 0
                                              ? "teamTaxAmt"
                                              : "mineTaxAmt"] ??
                                          0),
                                      18,
                                      AppColor.textBlack,
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
  showDatePick(String dateStr) async {
    DateTime now = DateTime.now();
    DateTime? selectDate = await showMonthPicker(
        context: Global.navigatorKey.currentContext!,
        // initialEntryMode: DatePickerEntryMode.calendar,
        initialDate: controller.dateFormat.parse(dateStr),
        firstDate: DateTime(now.year - 5, now.month),
        lastDate: DateTime.now(),
        cancelWidget: getSimpleText("取消", 15, AppColor.theme),
        confirmWidget: getSimpleText("确认", 15, AppColor.theme));
    if (selectDate != null) {
      if (controller.selectTopRightType == 0) {
        controller.dealSelectDate = controller.dateFormat.format(selectDate);
      } else if (controller.selectTopRightType == 1) {
        controller.machineSelectDate = controller.dateFormat.format(selectDate);
      } else if (controller.selectTopRightType == 2) {
        controller.businessSelectDate =
            controller.dateFormat.format(selectDate);
      }
    }
  }

  // 自定义导航栏
  PreferredSize myAppbar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size(375.w, 53.5.w),
      child: Container(
        padding: EdgeInsets.only(top: paddingSizeTop(context) + 20.w),
        color: Colors.white,
        child: Column(
          children: [
            sbRow([
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
                              ]))))),
              GetX<StatisticsPageController>(builder: (_) {
                return controller.topIdx != 1
                    ? gwb(0)
                    : DropdownButtonHideUnderline(
                        child: DropdownButton2(
                            dropdownElevation: 0,
                            buttonElevation: 0,
                            offset: Offset(-10.w, -5.w),
                            customButton: Container(
                              width: 80.w,
                              height: 30.w,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.w),
                                  color: Colors.white),
                              alignment: Alignment.center,
                              child: centRow([
                                Image.asset(
                                  assetsName("product_store/icon_filter"),
                                  width: 14.w,
                                  fit: BoxFit.fitWidth,
                                ),
                                gwb(5),
                                getSimpleText("筛选", 14, AppColor.textBlack)
                              ]),
                            ),
                            items: List.generate(
                                controller.filterTypeList.length,
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
                                              padding:
                                                  EdgeInsets.only(left: 11.w),
                                              child: getSimpleText(
                                                  "${controller.filterTypeList[index]["name"] ?? ""}",
                                                  12,
                                                  controller.filterTypeIdx ==
                                                          index
                                                      ? AppColor.textRed
                                                      : AppColor.textBlack),
                                            );
                                          }),
                                        ),
                                      ),
                                    ]))),
                            // value: ctrl.machineDataIdx,
                            value: controller.filterTypeIdx,
                            buttonWidth: 90.w,
                            buttonHeight: 50.w,
                            itemHeight: 30.w,
                            onChanged: (value) {
                              controller.filterTypeIdx = value;
                              bus.emit("setFacilitatorIdx",
                                  controller.filterTypeIdx);
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
                                ])));
              })
            ], width: 375),
            SizedBox(
                width: 375.w,
                height: 3.w,
                child: Stack(children: [
                  GetX<StatisticsPageController>(builder: (_) {
                    return AnimatedPositioned(
                        top: 0,
                        left: controller.tagX,
                        duration: const Duration(milliseconds: 180),
                        child: Container(
                          width: 18.w,
                          height: 3.w,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.5.w),
                              color: AppColor.theme),
                        ));
                  })
                ])),
            gline(375, 0.5),
          ],
        ),
      ),
    );
  }

  Widget dropSelectView() {
    return GetX<StatisticsPageController>(builder: (_) {
      return DropdownButtonHideUnderline(
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
                      return controller.selectTopRightType == 2
                          ? getSimpleText(
                              controller
                                      .teamList[controller.machineTeamSelectIdx]
                                  ["name"],
                              12,
                              AppColor.textBlack)
                          : getSimpleText(
                              controller.ppList.isEmpty
                                  ? ""
                                  : controller.ppList[controller.selectPP]
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
                  controller.selectTopRightType == 2
                      ? controller.teamList.length
                      : controller.ppList.length,
                  (index) => DropdownMenuItem<int>(
                      value: index,
                      child: centClm([
                        SizedBox(
                          height: 30.w,
                          width: 110.w,
                          child: Align(
                            alignment: const Alignment(-1, 0),
                            child: GetX<StatisticsPageController>(builder: (_) {
                              return Padding(
                                padding: EdgeInsets.only(left: 9.w),
                                child: controller.selectTopRightType == 2
                                    ? getSimpleText(
                                        "${controller.teamList[index]["name"]}",
                                        12,
                                        controller.machineTeamSelectIdx == index
                                            ? AppColor.textRed
                                            : AppColor.textBlack)
                                    : getSimpleText(
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
              value: controller.selectTopRightType == 2
                  ? controller.machineTeamSelectIdx
                  : controller.selectPP,
              buttonWidth: 110.w,
              dropdownWidth: 110.w,
              buttonHeight: 60.w,
              itemHeight: 30.w,
              onChanged: (value) {
                if (controller.selectTopRightType == 2) {
                  controller.machineTeamSelectIdx = value;
                } else {
                  controller.selectPP = value;
                }
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
                  ])));
    });
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
