import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class IntegralStatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralStatisticsController>(IntegralStatisticsController());
  }
}

class IntegralStatisticsController extends GetxController {
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

  Map currentData = {};

  Map data = {
    "all": {
      "jf": 89128,
      "ky": 12938,
      "types": [
        {
          "name": "常规",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "奖励",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "复购",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "专属",
          "sy": 1237,
          "out": 1000,
        }
      ]
    },
    "self": {
      "jf": 89128,
      "ky": 12938,
      "types": [
        {
          "name": "常规",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "奖励",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "复购",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "专属",
          "sy": 1237,
          "out": 1000,
        }
      ]
    },
    "team": {
      "jf": 89128,
      "ky": 12938,
      "types": [
        {
          "name": "常规",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "奖励",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "复购",
          "sy": 1237,
          "out": 1000,
        },
        {
          "name": "专属",
          "sy": 1237,
          "out": 1000,
        }
      ]
    }
  };

  int realFilterIdx = -1;

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

  final _startDate = "".obs;
  String get startDate => _startDate.value;
  set startDate(v) => _startDate.value = v;

  final _endDate = "".obs;
  String get endDate => _endDate.value;
  set endDate(v) => _endDate.value = v;

  changeData() {
    if (topIndex == 0) {
      currentData = data["all"] ?? {};
    } else if (topIndex == 1) {
      currentData = data["self"] ?? {};
    } else if (topIndex == 2) {
      currentData = data["team"] ?? {};
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
        url: Urls.userIntegralStatisticsList,
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

class IntegralStatistics extends GetView<IntegralStatisticsController> {
  const IntegralStatistics({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "积分统计", action: [
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
                                  child: GetX<IntegralStatisticsController>(
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
                    jfTypeView(),
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
          color: const Color(0xFFFFB72D),
          borderRadius: BorderRadius.circular(8.w)),
      child: Stack(
        children: [
          Positioned(
              right: 10.w,
              bottom: 5.w,
              child: Image.asset(
                assetsName("statistics/jf_icon"),
                width: 81.5.w,
                fit: BoxFit.fitWidth,
              )),
          Positioned.fill(
              top: 25.w,
              left: 22.w,
              child: GetBuilder<IntegralStatisticsController>(
                builder: (_) {
                  Map data = controller.dataList[controller.topIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      getSimpleText("累积总积分", 14, Colors.white.withOpacity(0.7)),
                      ghb(5),
                      getSimpleText(
                          priceFormat(data["totalAmount"] ?? 0, savePoint: 0),
                          30,
                          Colors.white,
                          isBold: true),
                      ghb(5),
                      getSimpleText(
                        "当前可用积分  ${priceFormat(data["nowAmount"] ?? 0, savePoint: 0)}",
                        14,
                        Colors.white.withOpacity(0.7),
                      ),
                    ],
                  );
                },
              ))
        ],
      ),
    );
  }

  Widget jfTypeView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.w),
      ),
      child: Column(
        children: [
          titleCell("积分类型"),
          ghb(10),
          GetBuilder<IntegralStatisticsController>(
            builder: (_) {
              double chartWidth = 110.w;
              Map data = controller.dataList[controller.topIndex];
              List datas = data["accountInfo"] ?? [];
              // List types = controller.currentData["types"] ?? [];
              return datas.isEmpty
                  ? GetX<IntegralStatisticsController>(
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
                  : Column(
                      children: [
                        ...List.generate(datas.length, (index) {
                          Map account = datas[index];
                          return Padding(
                            padding:
                                EdgeInsets.only(top: index != 0 ? 25.w : 0),
                            child: Row(
                              children: [
                                gwb(55),
                                SizedBox(
                                  width: chartWidth,
                                  height: chartWidth,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: SfCircularChart(
                                            margin: EdgeInsets.zero,
                                            series: <CircularSeries>[
                                              RadialBarSeries<Map, String>(
                                                  innerRadius:
                                                      "${chartWidth / 2 - 20}",
                                                  radius: "${chartWidth / 2}",
                                                  cornerStyle:
                                                      CornerStyle.bothCurve,
                                                  pointColorMapper:
                                                      (datum, idx) {
                                                    return Color(int.parse(
                                                        controller.colors[
                                                            index %
                                                                controller
                                                                    .colors
                                                                    .length],
                                                        radix: 16));
                                                  },
                                                  maximumValue:
                                                      ((account["amout2"] ??
                                                                      0.0) <=
                                                                  0
                                                              ? 1.0
                                                              : (account[
                                                                      "amout2"] ??
                                                                  0.0)) *
                                                          1.0,
                                                  trackColor:
                                                      AppColor.assisText,
                                                  dataSource: [account],
                                                  xValueMapper: (Map data, _) {
                                                    // return "10000";
                                                    return "${(account["amout"] ?? 0.0)}";
                                                  },
                                                  yValueMapper: (Map data, _) {
                                                    return (account["amout"] ??
                                                                0.0) <=
                                                            0
                                                        ? 1.0
                                                        : (account["amout"] ??
                                                            0.0);
                                                    // return 10000;
                                                  })
                                            ]),
                                      ),
                                      Positioned.fill(
                                          child: Center(
                                        child: centClm([
                                          getSimpleText(
                                              "${account["name"] ?? ""}积分",
                                              14,
                                              AppColor.text),
                                          getSimpleText(
                                              priceFormat(
                                                  (account["amout2"] ?? 0.0),
                                                  savePoint: 0),
                                              14,
                                              AppColor.text,
                                              isBold: true)
                                        ]),
                                      ))
                                    ],
                                  ),
                                ),
                                gwb(40),
                                centClm([
                                  centRow([
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      color: Color(int.parse(
                                          controller.colors[
                                              index % controller.colors.length],
                                          radix: 16)),
                                    ),
                                    gwb(8),
                                    centClm([
                                      getSimpleText("剩余积分", 13, AppColor.text,
                                          textHeight: 0.9),
                                      ghb(2),
                                      getSimpleText(
                                          priceFormat(account["amout"] ?? 0.0,
                                              savePoint: 0),
                                          14,
                                          AppColor.text,
                                          fw: FontWeight.w500),
                                    ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start),
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start),
                                  ghb(10),
                                  centRow([
                                    Container(
                                      width: 10.w,
                                      height: 10.w,
                                      color: AppColor.assisText,
                                    ),
                                    gwb(8),
                                    centClm([
                                      getSimpleText("已使用积分", 13, AppColor.text,
                                          textHeight: 0.9),
                                      ghb(2),
                                      getSimpleText(
                                          priceFormat(account["amout3"] ?? 0.0,
                                              savePoint: 0),
                                          14,
                                          AppColor.text,
                                          fw: FontWeight.w500),
                                    ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start),
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start)
                                ], crossAxisAlignment: CrossAxisAlignment.start)
                              ],
                            ),
                          );
                        })
                      ],
                    );
            },
          ),
          ghb(25),
        ],
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
                  GetX<IntegralStatisticsController>(
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
                                  GetX<IntegralStatisticsController>(
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
