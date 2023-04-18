import 'dart:math' as math;

import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/myTeam/my_team_people_info.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyTeamBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyTeamCtrl>(MyTeamCtrl());
  }
}

class MyTeamCtrl extends GetxController {
  String teamDatabuildId = "MyTeamCtrl_teamDatabuildId";
  TextEditingController searchInputCtrl = TextEditingController();
  RefreshController pullCtrl = RefreshController();
  GlobalKey dealChartRendererKey = GlobalKey();
  GlobalKey dealChartKey = GlobalKey();

  GlobalKey addChartRendererKey = GlobalKey();
  GlobalKey addChartKey = GlobalKey();

  GlobalKey activeChartRendererKey = GlobalKey();
  GlobalKey activeChartKey = GlobalKey();

  final _topButtonHeight = RxDouble(0.0);
  get topButtonHeight => _topButtonHeight.value;
  set topButtonHeight(v) => _topButtonHeight.value = v;

  final _dataOrPersionIdx = 0.obs;
  int get dataOrPersionIdx => _dataOrPersionIdx.value;
  set dataOrPersionIdx(v) => _dataOrPersionIdx.value = v;

  final _directlyOrTeamIdx = 0.obs;
  int get directlyOrTeamIdx => _directlyOrTeamIdx.value;
  set directlyOrTeamIdx(v) {
    _directlyOrTeamIdx.value = v;
    loadTeamOrDirectly();
  }

  final _statisticsIdx = 0.obs;
  int get statisticsIdx => _statisticsIdx.value;
  set statisticsIdx(v) {
    _statisticsIdx.value = v;
    statisticsDate = getCurrentDate();
  }

  final _chartIdx = 0.obs;
  int get chartIdx => _chartIdx.value;
  set chartIdx(v) {
    _chartIdx.value = v;
    chartDate = getCurrentDate(isChart: true);
  }

  final _statisticsDate = "".obs;
  String get statisticsDate => _statisticsDate.value;
  set statisticsDate(v) => _statisticsDate.value = v;

  final _chartDate = "".obs;
  String get chartDate => _chartDate.value;
  set chartDate(v) => _chartDate.value = v;

  changeStatisticsDate(bool add) {}
  DateTime nowDate = DateTime.now();
  DateFormat dayFormat = DateFormat("MM/dd");
  DateFormat monthFormat = DateFormat("yyyy/MM");
  DateFormat yearFormat = DateFormat("yyyy");
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  DateFormat dateFormat2 = DateFormat("MM/dd");
  double textVSpace = 15;
  Map homeData = {};

  String getCurrentDate({bool isChart = false}) {
    String date = "";
    switch (isChart ? chartIdx : statisticsIdx) {
      case 0:
        date = dayFormat.format(nowDate);
        break;
      case 1:
        date = monthFormat.format(nowDate);
        break;
      case 2:
        date = yearFormat.format(nowDate);
        break;
      case 3:
        date = dayFormat.format(nowDate);
        break;
      default:
    }
    return date;
  }

  Map teamAllData = {};
  List dealChartDatas = [];
  List addChartDatas = [];
  List activeChartDatas = [];

  loadTeamData() {
    simpleRequest(
      url: Urls.userTeamCount,
      params: {},
      success: (success, json) {
        if (success) {
          teamAllData = json["data"] ?? {};
          dealChartDatas = teamAllData["txnData"] ?? [];
          addChartDatas = teamAllData["peopleData"] ?? [];
          activeChartDatas = teamAllData["activData"] ?? [];
          update([teamDatabuildId]);
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    loadTeamData();
    loadTeamOrDirectly();
    statisticsDate = getCurrentDate();
    chartDate = getCurrentDate(isChart: true);
    getUserData().then((value) {
      AppDefault appDefault = AppDefault();
      if (appDefault.loginStatus) {
        homeData = AppDefault().homeData;
      } else {
        popToLogin();
      }
    });

    calcuTopButtonHeight();
    super.onInit();
  }

  @override
  void onClose() {
    searchInputCtrl.dispose();
    pullCtrl.dispose();
    super.onClose();
  }

  //按交易量，0正序，1倒序
  final _isDealPositiva = true.obs;
  get isDealPositiva => _isDealPositiva.value;
  set isDealPositiva(v) => _isDealPositiva.value = v;

  //按激活率，-1 不排序，0正序，1倒序
  final _isActiveArrange = RxInt(-1);
  get isActiveArrange => _isActiveArrange.value;
  set isActiveArrange(v) => _isActiveArrange.value = v;

  List<List> peopleDataList = [[], []];
  String peopleDataListBuildId = "MyTeam_peopleDataListBuildId";
  List pageNos = [1, 1];
  List pageSizes = [10, 10];
  List counts = [0, 0];
  //1直属，2盟友
  loadTeamOrDirectly({bool isLoad = false}) {
    isLoad ? pageNos[directlyOrTeamIdx]++ : pageNos[directlyOrTeamIdx] = 1;

    simpleRequest(
      url: Urls.userTeamByPeopleList,
      params: {
        "type": directlyOrTeamIdx,
        "userInfo": searchInputCtrl.text,
        "pageSize": pageSizes[directlyOrTeamIdx],
        "pageNo": pageNos[directlyOrTeamIdx]
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List dataList = data["data"] ?? [];
          counts[directlyOrTeamIdx] = data["count"] ?? 0;
          if (isLoad) {
            peopleDataList[directlyOrTeamIdx] = [
              ...peopleDataList[directlyOrTeamIdx],
              ...dataList
            ];
          } else {
            peopleDataList[directlyOrTeamIdx] = dataList;
          }
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update([peopleDataListBuildId]);
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {},
    );
  }

  calcuTopButtonHeight() {
    if (Global.navigatorKey.currentContext != null) {
      double tHeight = calculateTextHeight("日交易", 13, FontWeight.normal,
          double.infinity, 1, Global.navigatorKey.currentContext!,
          color: AppColor.textBlack);
      topButtonHeight = (1 + 55 + textVSpace * 4 + 15).w + tHeight * 4;
    } else {
      topButtonHeight = 203.w;
    }
  }

  var filterIdx = 0.obs;

  int get filterIndex => filterIdx.value;

  void setFilterIdx(int idx) {
    if (filterIndex != idx) {
      filterIdx = idx.obs;
      update();
    }
  }

  // RxMap directlyTeamData = {
  //   "dayMoney": 829123,
  //   "dayPeople": 202,
  //   "dayActive": 31,
  //   "phone": "139****2192",
  //   "name": "刘德华",
  //   "from": "吕老师",
  //   "frlevel": "VIP1",
  //   "lblevel": "团长VIP5",
  //   "img": "rank/icon_userdefault_head",
  //   "yqCode": "ASL87621992",
  // }.obs;
  // RxMap teamData = {
  //   "dayMoney": 89200000,
  //   "dayPeople": 209,
  //   "dayActive": 301,
  //   "phone": "139****2192",
  //   "name": "吕老师",
  //   "from": "刘德华",
  //   "frlevel": "VIP1",
  //   "lblevel": "团长VIP5",
  //   "img": "rank/icon_userdefault_head",
  //   "yqCode": "ASL87621992",
  // }.obs;
}

class MyTeam extends GetView<MyTeamCtrl> {
  const MyTeam({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        backgroundColor: AppColor.pageBackgroundColor,
        appBar: getDefaultAppBar(context, "我的伙伴"),
        body: Stack(
          children: [
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 40.w,
                child: Container(
                  height: 40.w,
                  width: 375.w,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                          top: BorderSide(
                              width: 0.5.w, color: AppColor.lineColor))),
                  child: Row(
                    children: List.generate(
                        2,
                        (index) => CustomButton(
                              onPressed: () {
                                controller.dataOrPersionIdx = index;
                              },
                              child: SizedBox(
                                height: 40.w,
                                width: 375.w / 2,
                                child: Center(child: GetX<MyTeamCtrl>(
                                  builder: (_) {
                                    return getSimpleText(
                                        index == 0 ? "数据统计" : "成员",
                                        18,
                                        controller.dataOrPersionIdx == index
                                            ? AppDefault().getThemeColor() ??
                                                AppColor.buttonTextBlue
                                            : AppColor.textBlack);
                                  },
                                )),
                              ),
                            )),
                  ),
                )),
            //成员 列表搜索
            GetX<MyTeamCtrl>(
              builder: (_) {
                return controller.dataOrPersionIdx != 1
                    ? Align(
                        child: ghb(0),
                      )
                    : Positioned(
                        top: 40.w,
                        left: 0,
                        right: 0,
                        height: 80.w,
                        child: Center(
                          child: Container(
                            width: 345.w,
                            height: 50.w,
                            decoration: getDefaultWhiteDec(),
                            child: centRow(
                              [
                                CustomInput(
                                  placeholder: "请输入姓名或者手机号查询",
                                  textEditCtrl: controller.searchInputCtrl,
                                  onChange: (str) {},
                                  onEditingComplete: (str) {},
                                  width: 256.w,
                                  heigth: 50.w,
                                ),
                                CustomButton(
                                  onPressed: () {
                                    takeBackKeyboard(context);
                                    controller.loadTeamOrDirectly();
                                  },
                                  child: Container(
                                    width: 64.w,
                                    height: 30.w,
                                    decoration: BoxDecoration(
                                        color: AppColor.textBlack,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Center(
                                      child:
                                          getSimpleText("搜索", 15, Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
              },
            ),
            //成员 团队切换
            GetX<MyTeamCtrl>(
              builder: (_) {
                return Positioned(
                    top: 40.w + 80.w,
                    left: 0,
                    right: 0,
                    height: 40.w,
                    child: controller.dataOrPersionIdx != 1
                        ? Align(
                            child: ghb(0),
                          )
                        : Container(
                            height: 40.w,
                            width: 375.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              // border: Border(
                              //     top: BorderSide(
                              //         width: 0.5.w,
                              //         color: AppColor.lineColor))
                            ),
                            child: Row(
                              children: List.generate(
                                  2,
                                  (index) => CustomButton(
                                        onPressed: () {
                                          controller.directlyOrTeamIdx = index;
                                        },
                                        child: SizedBox(
                                          height: 40.w,
                                          width: 375.w / 2,
                                          child: Center(child: GetX<MyTeamCtrl>(
                                            builder: (_) {
                                              return getSimpleText(
                                                  index == 0 ? "直属客户" : "展业伙伴",
                                                  18,
                                                  controller.directlyOrTeamIdx ==
                                                          index
                                                      ? AppDefault()
                                                              .getThemeColor() ??
                                                          AppColor
                                                              .buttonTextBlue
                                                      : AppColor.textBlack);
                                            },
                                          )),
                                        ),
                                      )),
                            ),
                          ));
              },
            ),

            // 团队数据
            // Positioned(child: child)
            // GetX<MyTeamCtrl>(
            //   init: controller,
            //   initState: (_) {},
            //   builder: (_) {
            //     return Positioned(
            //         top: 16.5.w,
            //         left: 15.w,
            //         width: 345.w,
            //         height: controller.topButtonHeight,
            //         child: GetBuilder<MyTeamCtrl>(
            //           init: controller,
            //           initState: (_) {},
            //           builder: (ctrl) {
            //             return sbRow([
            //               topTeam(true, ctrl.directlyTeamData, context),
            //               topTeam(false, ctrl.teamData, context),
            //             ], width: 345);
            //           },
            //         ));
            //   },
            // ),

            // Positioned(
            //     top: 16.5.w + controller.topButtonHeight + 80.w,
            //     left: 0,
            //     height: 50.w,
            //     child: GetBuilder<MyTeamCtrl>(
            //       init: MyTeamCtrl(),
            //       initState: (_) {},
            //       builder: (ctrl) {
            //         return Container(
            //           width: 375.w,
            //           height: 50.w,
            //           color: Colors.white,
            //           child: Center(
            //             child: Row(
            //               children: [
            //                 centClm([
            //                   gwb(78),
            //                   getSimpleText("共计", 12, AppColor.textBlack),
            //                   getSimpleText("${controller.count}户", 12,
            //                       AppColor.textBlack),
            //                 ]),
            //                 gline(1, 25),
            //                 filterButton(0, ctrl),
            //                 filterButton(1, ctrl),
            //                 filterButton(2, ctrl),
            //               ],
            //             ),
            //           ),
            //         );
            //       },
            //     )),
            //成员 列表
            GetX<MyTeamCtrl>(
              builder: (_) {
                return Positioned(
                    top: 40.w + 80.w + 40.w,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: controller.dataOrPersionIdx != 1
                        ? Align(
                            child: ghb(0),
                          )
                        : GetBuilder<MyTeamCtrl>(
                            id: controller.peopleDataListBuildId,
                            init: controller,
                            initState: (_) {},
                            builder: (ctrl) {
                              return SmartRefresher(
                                physics: const BouncingScrollPhysics(),
                                controller: controller.pullCtrl,
                                onLoading: () {
                                  controller.loadTeamOrDirectly(isLoad: true);
                                },
                                onRefresh: () {
                                  controller.loadTeamOrDirectly();
                                },
                                enablePullUp: controller
                                        .counts[controller.directlyOrTeamIdx] >
                                    controller
                                        .peopleDataList[
                                            controller.directlyOrTeamIdx]
                                        .length,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: ctrl.peopleDataList != null &&
                                          ctrl.peopleDataList.isNotEmpty &&
                                          ctrl.peopleDataList[controller
                                                  .directlyOrTeamIdx] !=
                                              null &&
                                          ctrl
                                              .peopleDataList[
                                                  controller.directlyOrTeamIdx]
                                              .isNotEmpty
                                      ? ctrl
                                              .peopleDataList[
                                                  controller.directlyOrTeamIdx]
                                              .length +
                                          1
                                      : 1,
                                  itemBuilder: (context, index) {
                                    return index == 0
                                        ? SizedBox(
                                            width: 375.w,
                                            height: 30.w,
                                            child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child: getSimpleText(
                                                  "- 共计${controller.counts[controller.directlyOrTeamIdx] ?? 0}户 -",
                                                  14,
                                                  AppColor.textGrey2),
                                            ),
                                          )
                                        : teamCell(
                                            index,
                                            ctrl.peopleDataList[controller
                                                .directlyOrTeamIdx][index - 1],
                                            ((idx, data) {
                                            takeBackKeyboard(context);
                                            push(
                                                MyTeamPeopleInfo(
                                                  isDirectly: controller
                                                          .directlyOrTeamIdx ==
                                                      0,
                                                  teamData: data,
                                                ),
                                                null,
                                                binding:
                                                    MyTeamPeopleInfoBinding());
                                            // push(
                                            //     MyTeamInfoCard(
                                            //       isDirectly:
                                            //           (index - 1) % 2 == 0
                                            //               ? true
                                            //               : false,
                                            //       haveAuth: (index - 1) % 2 == 0
                                            //           ? true
                                            //           : false,
                                            //       infoData: ctrl.peopleDataList[
                                            //               controller
                                            //                   .directlyOrTeamIdx]
                                            //           [index - 1],
                                            //     ),
                                            //     context,
                                            //     setName: "MyTeamInfoCard");
                                          }));
                                  },
                                ),
                              );
                            },
                          ));
              },
            ),
            //数据统计 总统计
            GetX<MyTeamCtrl>(
              builder: (_) {
                return controller.dataOrPersionIdx != 0
                    ? Align(
                        child: ghb(0),
                      )
                    : Positioned(
                        top: 40.w,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: GetBuilder<MyTeamCtrl>(
                              id: controller.teamDatabuildId,
                              builder: (_) {
                                return Column(
                                  children: [
                                    ghb(8),
                                    dataTitle("数据统计"),
                                    Container(
                                        width: 345.w,
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12.w),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0x26333333),
                                                offset: Offset(0, 2.w),
                                                blurRadius: 8.w,
                                                spreadRadius: 0.0,
                                              )
                                            ]),
                                        child: Column(
                                          children: [
                                            ghb(12),
                                            // dateSelectView(0),
                                            // ghb(10),
                                            // dateChangeView(0),
                                            // ghb(10),
                                            sbRow([
                                              topTeam(true, {}, context),
                                              topTeam(false, {}, context),
                                            ], width: 345 - 12 * 2),
                                            ghb(12),
                                          ],
                                        )),
                                    ghb(8),
                                    dataTitle("数据图表"),
                                    Container(
                                      width: 345.w,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12.w),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0x26333333),
                                              offset: Offset(0, 2.w),
                                              blurRadius: 8.w,
                                              spreadRadius: 0.0,
                                            )
                                          ]),
                                      child: Column(
                                        children: [
                                          ghb(20),
                                          // dateSelectView(1),
                                          // ghb(10),
                                          // dateChangeView(1),
                                          // ghb(10),
                                          chartView(
                                              0, controller.dealChartDatas),
                                          chartView(
                                              1, controller.addChartDatas),
                                          chartView(
                                              2, controller.activeChartDatas),
                                        ],
                                      ),
                                    ),
                                    ghb(40),
                                  ],
                                );
                              }),
                        ));
              },
            )
          ],
        ),
      ),
    );
  }

  Widget chartView(int type, List datas) {
    // if (type == 0) {
    //   for (var e in datas) {
    //     e["personTxnAmt"] = getRandomInt(0, 11) * 1.0;
    //     e["teamTxnAmt"] = getRandomInt(10, 90000) * 1.0;
    //   }
    // }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getSimpleText(
            "近七日${type == 0 ? "交易" : type == 1 ? "新增" : "激活"}",
            16,
            AppColor.textBlack),
        ghb(20),
        sbRow([
          gwb(0),
          centRow([
            Container(
              width: 18.w,
              height: 8.w,
              decoration: BoxDecoration(
                  color: const Color(0xFF165DFF),
                  borderRadius: BorderRadius.circular(4.w)),
            ),
            gwb(3),
            getSimpleText("直属", 10, const Color(0xFF4D4D4D)),
            gwb(12),
            Container(
              width: 18.w,
              height: 8.w,
              decoration: BoxDecoration(
                  color: const Color(0xFFFF7040),
                  borderRadius: BorderRadius.circular(4.w)),
            ),
            gwb(3),
            getSimpleText("伙伴", 10, const Color(0xFF4D4D4D)),
          ]),
        ], width: 345 - 24 - 24),
        ghb(6),
        sbRow([
          SizedBox(
            width: (345 - 24 - 36).w,
            height: 130.w,
            child: LineChart(
              mainData(type, datas),
              key: type == 0
                  ? controller.dealChartKey
                  : type == 1
                      ? controller.addChartKey
                      : controller.activeChartKey,
              chartRendererKey: type == 0
                  ? controller.dealChartRendererKey
                  : type == 1
                      ? controller.addChartRendererKey
                      : controller.activeChartRendererKey,
            ),
          )
        ], width: 345 - 24 - 24),
        ghb(20)
      ],
    );
  }

  LineChartData mainData(int type, List datas) {
    double maxNum = 0.0;
    for (var e in datas) {
      double num1 = double.parse(
          "${e[type == 0 ? "personTxnAmt" : type == 1 ? "personNum" : "personActivN"] ?? 0}");
      if (maxNum < num1) {
        maxNum = num1 * 1.0;
      }
      double num2 = double.parse(
          "${e[type == 0 ? "teamTxnAmt" : type == 1 ? "teamNum" : "teamActivN"] ?? 0}");
      if (maxNum < num2) {
        maxNum = num2 * 1.0;
      }
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        // drawVerticalLine: true,
        // horizontalInterval: 1,
        // verticalInterval: 1,
        drawVerticalLine: false,
        drawHorizontalLine: false,
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
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                // space: 8.0,
                child: getSimpleText(
                    value.toInt() < datas.length
                        ? controller.dateFormat2.format(controller.dateFormat
                            .parse((datas[value.toInt()]["rq"] ?? "")))
                        : controller.dateFormat2.format(controller.nowDate
                            .add(Duration(days: value.toInt() - 6))),
                    12,
                    AppColor.textBlack),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              var style = TextStyle(
                color: AppColor.textBlack,
                fontSize: 11.sp,
              );
              Map scale = getChartScale(maxNum);
              String text = scale[value.toInt()];
              return Text(text, style: style, textAlign: TextAlign.left);
            },
            reservedSize: 37.w,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 4,
      lineBarsData: [
        getChartBarData(type, datas, true, maxNum),
        getChartBarData(type, datas, false, maxNum),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white,
          tooltipBorder:
              BorderSide(width: 0.5.w, color: const Color(0x4C165DFF)),
          getTooltipItems: (touchedSpots) {
            List<LineTooltipItem> item = [];

            for (LineBarSpot e in touchedSpots) {
              dynamic personData = 0;
              dynamic teamData = 0;
              if (datas.length > e.spotIndex) {
                Map d = datas[e.spotIndex];
                switch (type) {
                  case 0:
                    personData = d["personTxnAmt"] ?? 0.0;
                    teamData = d["teamTxnAmt"] ?? 0.0;
                    break;
                  case 1:
                    personData = d["personNum"] ?? 0;
                    teamData = d["teamNum"] ?? 0;
                    break;
                  case 2:
                    personData = d["personActivN"] ?? 0;
                    teamData = d["teamActivN"] ?? 0;
                    break;
                  default:
                }
              }

              item.add(LineTooltipItem(
                e.barIndex == 0 ? "直属团队\n" : "团队盟友\n",
                TextStyle(
                  color: AppColor.textBlack,
                  // fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: "${e.barIndex == 0 ? personData : teamData}",
                    style: TextStyle(
                      color: AppColor.textBlack,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ));
            }
            return item;
          },
        ),
      ),
    );
  }

  LineChartBarData getChartBarData(
      int type, List datas, bool directly, double maxNum) {
    int maxInt = getMaxCount(maxNum);
    return LineChartBarData(
      spots: datas == null || datas.isEmpty
          ? List.generate(7, (index) => FlSpot(index * 1.0, 0.0))
          : datas.asMap().entries.map((e) {
              double num = double.parse(
                  "${e.value[type == 0 ? (directly ? "personTxnAmt" : "teamTxnAmt") : type == 1 ? (directly ? "personNum" : "teamNum") : (directly ? "personActivN" : "teamActivN")] ?? 1}");
              double spotY = 4 * ((num == 0 ? 1 : num) / maxInt);
              return FlSpot(double.parse("${e.key}"), spotY);
            }).toList(),

      isCurved: true,
      // gradient: const LinearGradient(
      //   colors: [Color(0x4C165DFF), Color(0xFF65DFF)],
      //   begin: Alignment(0, -1.0),
      //   end: Alignment(0, -0.8),
      // ),
      barWidth: 1.w,
      color: directly ? const Color(0x4C165DFF) : const Color(0xFFFFC6B3),
      isStrokeCapRound: true,

      dotData: FlDotData(
        show: true,
        checkToShowDot: (spot, barData) {
          return true;
        },
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
              color:
                  directly ? const Color(0xFF165DFF) : const Color(0xFFFF7040));
        },
      ),

      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: directly
              ? const [Color(0x4C165DFF), Color(0x00165dff)]
              : const [Color(0x4CFF7040), Color(0x02ffffff)],
          begin: const Alignment(0, -1.0),
          end: const Alignment(0, 1),
        ),
      ),
    );
  }

  Widget dateSelectView(int type) {
    return Row(
      children: List.generate(4, (index) {
        String t = "";
        switch (index) {
          case 0:
            t = "日";
            break;
          case 1:
            t = "月";
            break;
          case 2:
            t = "年";
            break;
          case 3:
            t = "近七日";
            break;
          default:
        }
        return CustomButton(
          onPressed: () {
            if (type == 0) {
              controller.statisticsIdx = index;
            } else {
              controller.chartIdx = index;
            }
          },
          child: SizedBox(
            width: 345.w / 4,
            height: 40.w,
            child: Center(child: GetX<MyTeamCtrl>(
              builder: (_) {
                return getSimpleText(
                    t,
                    14,
                    (type == 0
                                ? controller.statisticsIdx
                                : controller.chartIdx) ==
                            index
                        ? AppDefault().getThemeColor() ??
                            AppColor.buttonTextBlue
                        : AppColor.textGrey);
              },
            )),
          ),
        );
      }),
    );
  }

  Widget dateChangeView(int type) {
    return GetX<MyTeamCtrl>(
      builder: (_) {
        return centRow([
          CustomButton(
            onPressed: () {},
            child: SizedBox(
              width: 30.w,
              height: 24.w,
              child: Center(
                  child: Transform.rotate(
                angle: -math.pi / 1,
                child: Image.asset(
                  assetsName("home/myteam/btn_arrow_right_select"),
                  width: 7.w,
                  fit: BoxFit.fitWidth,
                ),
              )),
            ),
          ),
          getSimpleText(
              type == 0 ? controller.statisticsDate : controller.chartDate,
              15,
              AppDefault().getThemeColor() ?? AppColor.buttonTextBlue),
          CustomButton(
            onPressed: () {},
            child: SizedBox(
              width: 30.w,
              height: 24.w,
              child: Center(
                child: Image.asset(
                  assetsName("home/myteam/btn_arrow_right_select"),
                  width: 7.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ]);
      },
    );
  }

  Widget dataTitle(String title) {
    return SizedBox(
      height: 56.w,
      child: Center(
          child: centRow([
        gline(16, 1, color: AppColor.textBlack),
        gwb(6),
        getSimpleText(title, 16, AppColor.textBlack),
        gwb(6),
        gline(16, 1, color: AppColor.textBlack),
      ])),
    );
  }

  Widget topTeam(bool directly, Map data, BuildContext context) {
    double textVSpace = controller.textVSpace;
    return Container(
      width: 153.w,
      // height: controller.topButtonHeight,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
          boxShadow: [
            BoxShadow(
              color: const Color(0x3F000000),
              offset: Offset(0, 2.w),
              blurRadius: 4.w,
              spreadRadius: 0.0,
            )
          ]),
      child: Column(
        children: [
          ghb(1),
          // Container(
          //   width: 166.w,
          //   height: 55.w,
          //   color: const Color(0xFFF8FAFF),
          //   child:
          //   Row(
          //     children: [
          //       gwb(10.5),
          //       Container(
          //         width: 4.w,
          //         height: 15.w,
          //         decoration: BoxDecoration(
          //             borderRadius: BorderRadius.circular(2.w),
          //             color: directly
          //                 ? const Color(0xFF5BA3F7)
          //                 : const Color(0xFFF75B5B)),
          //       ),
          //       gwb(9),
          //       getSimpleText(
          //           directly ? "直属团队总统计" : "团队盟友总统计", 15, AppColor.textBlack,
          //           isBold: true),
          //     ],
          //   ),
          // ),
          SizedBox(
            height: 36.w,
            child: Center(
              child: getSimpleText(
                  directly ? "直属客户" : "展业伙伴", 18, AppColor.textBlack),
            ),
          ),

          SizedBox(
            width: (153 - 8 * 2).w,
            child: getRichText(
                "交易(元)：",
                priceFormat(directly
                    ? (controller.teamAllData["soleTotalAmount"] ?? 0)
                    : (controller.teamAllData["teamTotalAmount"] ?? 0)),
                14,
                const Color(0xFF4D4D4D),
                14,
                AppDefault().getThemeColor() ?? const Color(0XFF3381FF)),
          ),
          ghb(textVSpace),
          SizedBox(
            width: (153 - 8 * 2).w,
            child: getRichText(
                directly ? "总人数(人)：" : "总人数(人)：",
                "${directly ? controller.teamAllData["soleTotalAddUser"] ?? "0" : controller.teamAllData["teamPeopleNum"] ?? "0"}",
                14,
                const Color(0xFF4D4D4D),
                14,
                AppDefault().getThemeColor() ?? const Color(0XFF3381FF)),
          ),
          ghb(textVSpace),
          SizedBox(
            width: (153 - 8 * 2).w,
            child: getRichText(
                "激活(台)：",
                "${directly ? controller.teamAllData["soleTotalActTerminal"] ?? "0" : controller.teamAllData["teamTotalActTerminal"] ?? "0"}",
                14,
                const Color.fromARGB(255, 49, 32, 32),
                14,
                AppDefault().getThemeColor() ?? const Color(0XFF3381FF)),
          ),

          // sbRow([
          //   getSimpleText(
          //       "日交易(元)：${directly ? priceFormat(data["dayMoney"]) : thousandFormat(data["dayMoney"])}",
          //       13,
          //       AppColor.textBlack),
          // ], width: 168 - 11 * 2),
          // ghb(textVSpace),
          // sbRow([
          //   getSimpleText("日激活(台)：${priceFormat(data["dayActive"])}", 13,
          //       AppColor.textBlack),
          // ], width: 168 - 11 * 2),
          // ghb(textVSpace),
          // sbRow([
          //   getSimpleText("日新增(人)：${priceFormat(data["dayPeople"])}", 13,
          //       AppColor.textBlack),
          // ], width: 168 - 11 * 2),
          ghb(textVSpace),
          // CustomButton(
          //   onPressed: () {},
          //   child: Container(
          //     width: 48.w,
          //     height: 20.w,
          //     decoration: BoxDecoration(
          //         color: AppColor.textBlack,
          //         borderRadius: BorderRadius.circular(4.w)),
          //     child: Center(
          //       child: getSimpleText("明细", 14, Colors.white),
          //     ),
          //   ),
          // ),
          // sbRow([
          //   getSimpleText("查看详细数据", 13, const Color(0xFFB3B3B3)),
          // ], width: 168 - 11 * 2),
          // ghb(10)
        ],
      ),
    );
  }

  Widget filterButton(int idx, MyTeamCtrl ctrl) {
    return CustomButton(
      onPressed: () {
        if (ctrl.filterIdx.value != idx) {
          ctrl.setFilterIdx(idx);
        }
      },
      child: SizedBox(
        width: 375.w / 4 - 0.4.w,
        height: 50.w,
        child: Center(
          child: centRow([
            getSimpleText(
              idx == 0
                  ? "全部"
                  : idx == 1
                      ? "按激活"
                      : "按交易",
              15,
              ctrl.filterIdx.value == idx
                  ? AppDefault().getThemeColor() ?? AppColor.buttonTextBlue
                  : const Color(0xFFB3B3B3),
            ),
            idx > 0
                ? Icon(
                    Icons.unfold_more,
                    size: 15.w,
                    color: ctrl.filterIdx.value == idx
                        ? AppDefault().getThemeColor() ??
                            AppColor.buttonTextBlue
                        : const Color(0xFFB3B3B3),
                  )
                : const SizedBox(),
          ]),
        ),
      ),
    );
  }

  Widget teamCell(int idx, Map data, Function(int idx, Map data) cellClick) {
    double marginSpace = 14;
    return GestureDetector(
      onTap: () {
        if (cellClick != null) {
          cellClick(idx, data);
        }
      },
      child: Align(
        child: Container(
          margin: EdgeInsets.only(top: 10.w),
          padding: EdgeInsets.symmetric(vertical: 14.w),
          width: 345.w,
          decoration: getDefaultWhiteDec(),
          child: centClm([
            sbRow([
              centRow([
                ClipRRect(
                  borderRadius: BorderRadius.circular(20.w),
                  child: data["u_Avatar"] == null
                      ? Image.asset(
                          assetsName(
                              "home/machinetransfer/icon_machine_transfer_defaultpeople"),
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.fill,
                        )
                      : CustomNetworkImage(
                          src: AppDefault().imageUrl + data["u_Avatar"],
                          width: 40.w,
                          height: 40.w,
                          fit: BoxFit.fill,
                        ),
                ),
                gwb(22.5),
                centClm([
                  getSimpleText(
                      "${data["u_Name"] ?? ""}${data["u_Name"] != null ? " | " : ""}${hidePhoneNum(data["u_Mobile"] ?? "")}",
                      15,
                      AppColor.textBlack,
                      isBold: true),
                  // ghb(8),
                  // getSimpleText("123", 15, AppColor.textBlack, isBold: true),
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ]),
              SizedBox(
                width: 60.w,
                height: 40.w,
                child: Align(
                  alignment: Alignment.centerRight,
                  child:
                      assetsSizeImage("common/icon_cell_right_arrow", 20, 20),
                ),
              )
            ], width: 345 - 14.5 * 2),
            ghb(15),
            Container(
              width: (345 - 14.5 * 2).w,
              padding: EdgeInsets.symmetric(vertical: 15.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: centClm([
                sbRow([
                  centRow([
                    getSimpleText("本月装机数", 13, const Color(0xFF808080)),
                    gwb(16),
                    getSimpleText(
                        "${data["monBindingC"] ?? 0}台", 13, AppColor.textBlack,
                        isBold: true),
                  ]),
                  centRow([
                    getSimpleText("本月激活量", 13, const Color(0xFF808080)),
                    gwb(16),
                    getSimpleText(
                        "${data["monActTermiC"] ?? 0}台", 13, AppColor.textBlack,
                        isBold: true),
                  ]),
                ], width: 345 - 14.5 * 2 - 25.5 * 2),
                ghb(12),
                sbRow([
                  centRow([
                    getSimpleText("本月交易量", 13, const Color(0xFF808080)),
                    gwb(16),
                    getSimpleText(priceFormat(data["monTxnNum"] ?? 0) + "元", 13,
                        AppColor.textBlack,
                        isBold: true),
                  ]),
                  centRow([
                    getSimpleText("总计盟友数", 13, const Color(0xFF808080)),
                    gwb(16),
                    getSimpleText(
                        "${data["peopleC"] ?? 0}人", 13, AppColor.textBlack,
                        isBold: true),
                  ]),
                ], width: 345 - 14.5 * 2 - 25.5 * 2),
              ]),
            )
          ]),
        ),
      ),
    );
  }

  Widget cellCountText(String t1, String t2) {
    return centRow([
      getSimpleText(t1, 13, const Color(0xFF808080)),
      gwb(20),
      getSimpleText(t2, 13, AppColor.textBlack, isBold: true),
    ]);
  }
}
