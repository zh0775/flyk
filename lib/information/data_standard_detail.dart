import 'package:cxhighversion2/component/custom_background.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class DataStandardDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<DataStandardDetailController>(DataStandardDetailController());
  }
}

class DataStandardDetailController extends GetxController {
  RefreshController pullCtrl = RefreshController();
  String performCellBuildId = "DataStandardDetailController_performCellBuildId";
  String chartCellBuildId = "DataStandardDetailController_chartCellBuildId";
  final _dropIndex = 1.obs;
  int get dropIndex => _dropIndex.value;
  set dropIndex(v) {
    if (_dropIndex.value != v) {
      _dropIndex.value = v;
      update([performCellBuildId]);
      loadData();
    }
  }

  List<PieChartSectionData> pieSections = [];
  int pieSectionIndex = -1;

  double chartAllNum = 0.0;
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

  List pDropDownList = [
    {"id": 1, "name": "绑定设备", "unit": "台", "barUnit": "绑定（台）"},
    {"id": 2, "name": "会员人数", "unit": "人", "barUnit": "会员（人）"},
    {"id": 3, "name": "交易金额", "unit": "元", "barUnit": "交易额（元）"},
    {"id": 4, "name": "机具激活", "unit": "台", "barUnit": "激活（台）"},
    {"id": 5, "name": "使用商户", "unit": "户", "barUnit": "商户（户）"},
    {"id": 6, "name": "未绑定设备", "unit": "台", "barUnit": "绑定（台）"},
  ];
  final _isLoadding = false.obs;
  bool get isLoadding => _isLoadding.value;
  set isLoadding(v) => _isLoadding.value = v;

  final _dateIndex = 0.obs;
  int get dateIndex => _dateIndex.value;
  set dateIndex(v) {
    if (_dateIndex.value != v) {
      _dateIndex.value = v;

      loadData();
    }
  }

  final _topIndex = 1.obs;
  int get topIndex => _topIndex.value;

  set topIndex(v) {
    if (_topIndex.value != v) {
      _topIndex.value = v;
      update([performCellBuildId]);
      loadData();
      loadChart();
    }
  }

  final _showChart = true.obs;
  bool get showChart => _showChart.value;
  set showChart(v) => _showChart.value = v;

  bool isFirst = true;
  DataStandardDetailType type = DataStandardDetailType.earn;

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  List dataList = [];

  onLoad() {
    loadData(isLoad: true);
  }

  onRefresh() {
    loadData();
  }

  List chartDatas = [];
  loadChart() {
    if (isFirst) {
      return;
    }
    if (type == DataStandardDetailType.earn) {
      simpleRequest(
          url: Urls.userBounsDetail,
          params: {
            "b_Type": 0,
            "b_Source": topIndex == 0
                ? 2
                : topIndex == 1
                    ? 0
                    : 1
          },
          success: (success, json) {
            if (success) {
              chartDatas = json["data"] ?? [];
              chartAllNum = 0.0;
              for (var e in chartDatas) {
                e["show"] = true;
                chartAllNum += e["tolBounsN"] ?? 0;
              }
              // if (chartDatas.isEmpty) {
              //   List.generate(length, (index) => null)
              // }
              update([chartCellBuildId]);
            }
          },
          after: () {},
          useCache: true);
    }
  }

  double maxNum = 0;

  loadData({bool isLoad = false}) {
    if (isFirst) return;
    isLoadding = dataList.isEmpty;
    isLoad ? pageNo++ : pageNo = 1;
    simpleRequest(
        url: type == DataStandardDetailType.earn
            ? Urls.userEarningsDataList
            : Urls.userPerformanceDetailList,
        params: {
          "soleTeamType": topIndex == 0
              ? 3
              : topIndex == 1
                  ? 1
                  : 2,
          "timeType": dateIndex + 1,
          "performType":
              type == DataStandardDetailType.performance ? dropIndex : 0,
          "pageNo": pageNo,
          "pageSize": pageSize,
        },
        success: (success, json) {
          if (success) {
            Map data = json["data"] ?? {};
            count = data["count"] ?? 0;
            List items = data["data"] ?? [];
            for (var i = 0; i < items.length; i++) {
              var e = items[i];
              e["open"] = isLoad ? false : (i == 0);
            }
            isLoad ? dataList = [...dataList, ...items] : dataList = items;
            isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();

            if (type == DataStandardDetailType.performance) {
              maxNum = 0;
              for (var e in dataList) {
                if (e["tolNum"] > maxNum) {
                  maxNum = e["tolNum"] * 1.0;
                }
              }
            }
            update();
            if (type == DataStandardDetailType.performance) {
              update([chartCellBuildId]);
            }
          } else {
            isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
          }
        },
        after: () {
          isLoadding = false;
        },
        useCache: !isLoad);
  }

  Map performData = {};

  dataInit(int index, DataStandardDetailType t, Map pData, int performIndex) {
    if (!isFirst) return;
    type = t;

    topIndex = index;
    performData = pData;
    dropIndex = performIndex;
    isFirst = false;
    loadChart();
    loadData();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    super.onClose();
  }
}

enum DataStandardDetailType {
  earn,
  performance,
}

class DataStandardDetail extends GetView<DataStandardDetailController> {
  final int index;
  final DataStandardDetailType type;
  final Map performData;
  final int performIndex;
  const DataStandardDetail(
      {super.key,
      this.index = 1,
      this.type = DataStandardDetailType.earn,
      this.performIndex = 1,
      this.performData = const {}});

  @override
  Widget build(BuildContext context) {
    controller.dataInit(index, type, performData, performIndex);
    double barHeight = paddingSizeTop(context) + 10.w + 32.w;
    double dateBtnTop = barHeight + 12.w;
    double dateBtnHeight = 28.w;
    double chartTop = dateBtnTop + dateBtnHeight + 15.w;
    double chartHeight = type == DataStandardDetailType.earn ? 220.w : 297.w;
    double listTop =
        controller.showChart ? (chartTop + chartHeight + 15.w) : chartTop;
    double closeHeight = 40.w;

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(375.w, 95.w),
          child: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: gemp(),
            flexibleSpace: CustomBackground(
              child: Stack(
                children: [
                  Positioned(
                      top: paddingSizeTop(context) + 10.w,
                      left: 0,
                      right: 0,
                      height: 33.w,
                      child: sbhRow([
                        centRow([
                          defaultBackButton(context),
                          gwb(14),
                          getSimpleText(
                              "${controller.type == DataStandardDetailType.earn ? "收益" : "业绩"}详情",
                              20,
                              AppColor.textBlack3),
                        ]),
                        GetX<DataStandardDetailController>(
                          builder: (_) {
                            List indexs = [
                              controller.topIndex - 1 >= 0
                                  ? controller.topIndex - 1
                                  : 2,
                              controller.topIndex,
                              controller.topIndex + 1 > 2
                                  ? 0
                                  : controller.topIndex + 1
                            ];
                            return centRow(List.generate(
                              3,
                              (index) => Padding(
                                padding: EdgeInsets.only(
                                    left: index != 0 ? 7.w : 0,
                                    right: index != 2 ? 0 : 16.w),
                                child: topBtn(indexs[index]),
                              ),
                            ));
                          },
                        ),
                        // centRow(
                        //     [topBtn(0), gwb(7), topBtn(1), gwb(7), topBtn(2), gwb(16)]),
                      ], width: 375.w)),
                  Positioned(
                      top: dateBtnTop,
                      left: 0,
                      right: 0,
                      height: dateBtnHeight,
                      child: Align(
                        child: sbhRow([
                          GetX<DataStandardDetailController>(
                            builder: (_) {
                              return centRow([
                                dateBtn(0),
                                gwb(8),
                                dateBtn(1),
                                gwb(8),
                                dateBtn(2),
                              ]);
                            },
                          ),
                          GetX<DataStandardDetailController>(
                            builder: (_) {
                              String img = "zzt";
                              if (type == DataStandardDetailType.earn) {
                                img = "bt";
                              }
                              return CustomButton(
                                onPressed: () {
                                  controller.showChart = !controller.showChart;
                                },
                                child: SizedBox(
                                  width: 50.w,
                                  height: dateBtnHeight,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Image.asset(
                                      assetsName(
                                          "pay/earndetail/btn_${controller.showChart ? "list" : img}"),
                                      height: 16.w,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        ], width: 375 - 16 * 2, height: 28),
                      )),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            const Positioned.fill(child: CustomBackground()),
            Positioned.fill(child: GetBuilder<DataStandardDetailController>(
              builder: (_) {
                double listViewHeight = 0;

                for (var i = 0; i < controller.dataList.length; i++) {
                  var e = controller.dataList[i];
                  bool cellOpen = (type == DataStandardDetailType.earn
                      ? (e["open"] ?? false)
                      : false);
                  List bonusList = e["bonusList"] ?? [];
                  double marginTop = i > 0 ? 8.w : 0;
                  listViewHeight +=
                      (cellOpen ? (46 + 44 * bonusList.length).w : 46.w) +
                          marginTop;
                }
                if (controller.dataList.isNotEmpty) {
                  listViewHeight += 20.w;
                }

                return SmartRefresher(
                  controller: controller.pullCtrl,
                  onLoading: controller.onLoad,
                  onRefresh: controller.onRefresh,
                  enablePullUp: controller.count > controller.dataList.length,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        GetX<DataStandardDetailController>(
                          builder: (_) {
                            return AnimatedContainer(
                              height: controller.showChart ? chartHeight : 0,
                              duration: const Duration(milliseconds: 300),
                              child: SingleChildScrollView(
                                physics: const NeverScrollableScrollPhysics(),
                                child: Column(
                                  children: [
                                    titleView(
                                        type == DataStandardDetailType.earn
                                            ? "收益金额占比"
                                            : controller.pDropDownList[
                                                    controller.dropIndex - 1]
                                                ["name"],
                                        dropDown: type ==
                                            DataStandardDetailType.performance,
                                        bold: true),
                                    ghb(8),
                                    GetBuilder<DataStandardDetailController>(
                                      id: controller.chartCellBuildId,
                                      builder: (_) {
                                        return Container(
                                          width: 345.w,
                                          height: type ==
                                                  DataStandardDetailType.earn
                                              ? 187.w
                                              : 266.5.w,
                                          decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFEBF3F7),
                                                    Color(0xFFFAFAFA)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter),
                                              borderRadius:
                                                  BorderRadius.circular(8.w),
                                              border: Border.all(
                                                  width: 1.w,
                                                  color: Colors.white)),
                                          child: cartView(),
                                        );
                                      },
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        ghb(10),
                        SizedBox(
                          width: 375.w,
                          height: 24.w,
                          child: titleView(
                              "${controller.type == DataStandardDetailType.earn ? "收益" : "业绩"}列表",
                              dropDown: false),
                        ),
                        ghb(10),
                        type == DataStandardDetailType.earn
                            ? gemp()
                            : GetBuilder<DataStandardDetailController>(
                                id: controller.performCellBuildId,
                                builder: (_) {
                                  dynamic e =
                                      ((performData[controller.topIndex] ??
                                                  {})["cData"] ??
                                              [])[controller.dropIndex - 1] ??
                                          0;
                                  String img = "pay/icon_infocell_bdsb";
                                  String title = "";
                                  String subTitle = "";
                                  var data = e;
                                  String unit = "";
                                  switch (controller.dropIndex - 1) {
                                    case 0:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "bdsb");
                                      title = "绑定设备";
                                      subTitle = "EQUIPMENT";
                                      unit = "台";
                                      break;
                                    case 1:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "hyrs");
                                      title = "会员人数";
                                      subTitle = "MEMBER";
                                      unit = "人";
                                      break;
                                    case 2:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "jyje");
                                      title = "交易金额";
                                      subTitle = "TRADE";
                                      unit = "元";
                                      break;
                                    case 3:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "jjjh");
                                      title = "机具激活";
                                      subTitle = "MACHINERY";
                                      unit = "台";
                                      break;
                                    case 4:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "sysh");
                                      title = "使用商户";
                                      subTitle = "MACHINERY";
                                      unit = "户";
                                      break;
                                    case 5:
                                      img = img.replaceRange(
                                          img.length - 4, img.length, "wbdsb");
                                      title = "未绑定设备";
                                      subTitle = "EQUIPMENT";
                                      unit = "台";
                                      break;
                                  }
                                  return Align(
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 8.w),
                                      width: 345.w,
                                      height: 88.w,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFEBF3F7),
                                              Color(0xFFFAFAFA),
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter),
                                        borderRadius:
                                            BorderRadius.circular(8.w),
                                        border: Border.all(
                                            width: 1.w, color: Colors.white),
                                      ),
                                      child: Align(
                                        child: sbhRow([
                                          centRow([
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  left: img.contains("sysh")
                                                      ? 9.w
                                                      : 0),
                                              child: Image.asset(
                                                assetsName(img),
                                                width: img.contains("sysh")
                                                    ? 28.w
                                                    : 44.w,
                                                height: img.contains("sysh")
                                                    ? 28.w
                                                    : 44.w,
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            gwb(img.contains("sysh") ? 17 : 11),
                                            centClm([
                                              getSimpleText(title, 16,
                                                  AppColor.textBlack3),
                                              ghb(3),
                                              getSimpleText(subTitle, 12,
                                                  const Color(0xFFBCC1CC),
                                                  fw: FontWeight.w500)
                                            ],
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start),
                                          ]),
                                          getRichText(
                                              "$data ",
                                              unit,
                                              20,
                                              AppColor.textBlack3,
                                              12,
                                              const Color(0xFF606366),
                                              fw: FontWeight.w500)
                                        ], width: 345 - 16 * 2, height: 88),
                                      ),
                                    ),
                                  );
                                },
                              ),
                        SizedBox(
                          width: 375.w,
                          height: controller.dataList.isEmpty
                              ? 300.w
                              : listViewHeight,
                          // duration: const Duration(milliseconds: 300),
                          child: controller.dataList.isEmpty
                              ? GetX<DataStandardDetailController>(
                                  builder: (_) {
                                    return CustomEmptyView(
                                      isLoading: controller.isLoadding,
                                    );
                                  },
                                )
                              : ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.only(bottom: 20.w),
                                  itemCount: controller.dataList.length,
                                  itemBuilder: (context, index) {
                                    return listCell(
                                        index, controller.dataList[index]);
                                  },
                                ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ))
          ],
        ));
  }

  Widget listCell(int index, Map data) {
    bool open = data["open"] ?? false;
    String title = "";
    if (controller.dateIndex == 0) {}

    switch (controller.dateIndex) {
      case 0:
        title =
            "${data["year"] ?? 0}-${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}-${(data["day"] ?? 0) < 10 ? "0${data["day"] ?? 0}" : "${data["day"] ?? 0}"}";
        break;
      case 1:
        title =
            "${data["year"] ?? 0}-${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}";
        break;
      case 2:
        title = "${data["year"] ?? 0}";
        break;
    }

    List bonusList = data["bonusList"] ?? [];

    String unit = "";
    switch (controller.dropIndex - 1) {
      case 0:
        unit = "台";
        break;
      case 1:
        unit = "人";
        break;
      case 2:
        unit = "元";
        break;
      case 3:
        unit = "台";
        break;
      case 4:
        unit = "户";
        break;
      case 5:
        unit = "台";
        break;
    }

    return CustomButton(
      onPressed: () {
        if (type == DataStandardDetailType.earn) {
          data["open"] = !data["open"];
          controller.update();
        }
      },
      child: AnimatedContainer(
        margin: EdgeInsets.only(top: index == 0 ? 0 : 8.w),
        duration: const Duration(milliseconds: 300),
        width: 345.w,
        height: open ? (46 + 44 * bonusList.length).w : 46.w,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFEBF3F7), Color(0xFFFAFAFA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter),
            borderRadius: BorderRadius.circular(8.w),
            border: Border.all(width: 1.w, color: Colors.white)),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              sbhRow([
                getSimpleText(title, 16, const Color(0xFF4A4A4A)),
                type == DataStandardDetailType.earn
                    ? AnimatedRotation(
                        turns: open ? 1 : 0.5,
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          assetsName("pay/earndetail/list_arrow_down"),
                          width: 13.w,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : getRichText(
                        "${(controller.dropIndex - 1) == 2 ? priceFormat(data["tolNum"] ?? 0) : data["tolNum"] ?? 0} ",
                        unit,
                        20,
                        AppColor.textBlack3,
                        12,
                        const Color(0xFF606366),
                        fw: FontWeight.w500),
              ], width: 343 - 14 * 2, height: 46),
              ...bonusList.asMap().entries.map((e) {
                List nums =
                    priceFormat(e.value["tolBounsN"] ?? "0.00", savePoint: 2)
                        .split(".");

                return centClm([
                  sbhRow([
                    getSimpleText(
                        e.value["codeName"] ?? "", 13, AppColor.textBlack3),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: "+ ",
                          style: TextStyle(
                              color: AppColor.theme,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500)),
                      TextSpan(
                          text: "${nums[0]}",
                          style: TextStyle(
                              color: AppColor.theme,
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500)),
                      TextSpan(
                          text: ".${nums[1]}",
                          style: TextStyle(
                              color: AppColor.theme,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500)),
                    ]))
                  ], width: 315, height: 43),
                  e.key != bonusList.length - 1
                      ? gline(315, 1, color: const Color(0xFFF0F0F0))
                      : ghb(0)
                ]);
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget titleView(String title, {bool dropDown = false, bool bold = false}) {
    return Align(
      child: sbhRow([
        type == DataStandardDetailType.performance && dropDown
            ? DropdownButtonHideUnderline(
                child: GetX<DataStandardDetailController>(
                init: controller,
                builder: (_) {
                  return DropdownButton2(
                      offset: Offset(11.w, -5.w),
                      customButton: centRow([
                        Container(
                          width: 4.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                AppColor.theme,
                                const Color(0x02368F2)
                              ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter)),
                        ),
                        gwb(8),
                        getSimpleText(title, 16, AppColor.textBlack3,
                            isBold: bold),
                        gwb(4),
                        dropDown
                            ? Image.asset(
                                assetsName("pay/earndetail/icon_arrow_down"),
                                width: 10.w,
                                fit: BoxFit.fitWidth,
                              )
                            : gwb(0)
                      ]),
                      items: dropItems(),
                      value: controller.dropIndex,
                      // buttonWidth: 70.w,
                      buttonHeight: kToolbarHeight,
                      itemHeight: 30.w,
                      onChanged: (value) {
                        controller.dropIndex = value;
                      },
                      itemPadding: EdgeInsets.zero,
                      dropdownWidth: 80.w,
                      dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.w),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0x26333333),
                                offset: Offset(0, 5.w),
                                blurRadius: 15.w)
                          ]));
                },
              ))
            : centRow([
                Container(
                  width: 4.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [AppColor.theme, const Color(0x02368F2)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                ),
                gwb(8),
                getSimpleText(title, 16, AppColor.textBlack3, isBold: bold),
                gwb(4),
                dropDown
                    ? Image.asset(
                        assetsName("pay/earndetail/icon_arrow_down"),
                        width: 10.w,
                        fit: BoxFit.fitWidth,
                      )
                    : gwb(0)
              ]),
      ], width: 375 - 16 * 2, height: 24),
    );
  }

  List<DropdownMenuItem<int>> dropItems() {
    return List.generate(
        controller.pDropDownList.length,
        (index) => DropdownMenuItem<int>(
            value: controller.pDropDownList[index]["id"],
            child: centClm([
              SizedBox(
                height: (18 + 4 * 2).w,
                child: Center(
                  child: getSimpleText(
                      controller.pDropDownList[index]["name"],
                      12,
                      controller.dropIndex ==
                              controller.pDropDownList[index]["id"]
                          ? AppColor.theme
                          : AppColor.textBlack),
                ),
              ),
              index != controller.pDropDownList.length - 1
                  ? gline(52, 0.5)
                  : ghb(0)
            ])));
  }

  Widget dateBtn(int index) {
    return CustomButton(
      onPressed: () {
        controller.dateIndex = index;
      },
      child: Container(
        width: 42.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: controller.dateIndex == index ? AppColor.theme : Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          boxShadow: controller.dateIndex == index
              ? [
                  BoxShadow(
                      color: const Color(0x32404040),
                      offset: Offset(0, 2.w),
                      blurRadius: 15.w)
                ]
              : null,
        ),
        child: Center(
          child: getSimpleText(
              index == 0
                  ? "日"
                  : index == 1
                      ? "月"
                      : "年",
              14,
              controller.dateIndex == index
                  ? Colors.white
                  : const Color(0xFF8A9199)),
        ),
      ),
    );
  }

  Widget topBtn(int index) {
    return GetX<DataStandardDetailController>(
      builder: (_) {
        return CustomButton(
          onPressed: () {
            if (controller.topIndex == index) {
              controller.topIndex + 1 > 2
                  ? controller.topIndex = 0
                  : controller.topIndex++;
            } else {
              controller.topIndex = index;
            }
          },
          child: centClm([
            getSimpleText(
                index == 0
                    ? "渠道"
                    : index == 1
                        ? "总览"
                        : "自营",
                controller.topIndex == index ? 18 : 14,
                controller.topIndex == index
                    ? AppColor.textBlack3
                    : const Color(0xFF8A9199)),
            Visibility(
                visible: controller.topIndex == index,
                child: centClm([
                  ghb(2),
                  Container(
                    width: 37.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.w),
                        color: AppColor.theme),
                  )
                ]))
          ]),
        );
      },
    );
  }

  Widget bCell(int index, Map data) {
    if (data["show"] == null) {
      data["show"] = true;
    }
    bool show = data["show"];
    late Color color;
    if (show) {
      String cStr =
          controller.chartColors[index % controller.chartColors.length];
      color = Color(int.parse("0xFF${cStr.substring(1, cStr.length)}"));
    } else {
      color = AppColor.textGrey;
    }
    double boundsN = (data["tolBounsN"] ?? 0) /
        (controller.chartAllNum == 0 ? 1 : controller.chartAllNum) *
        100;
    return CustomButton(
      onPressed: () {
        data["show"] = !data["show"];
        controller.update([controller.chartCellBuildId]);
      },
      child: GetBuilder<DataStandardDetailController>(
        id: controller.chartCellBuildId,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(top: index != 0 ? 5.w : 0),
            child: sbRow([
              Container(
                margin: EdgeInsets.only(top: ((16.5 - 12) / 2).w),
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6.w),
                    border: Border.all(width: 1.w, color: Colors.white)),
              ),
              SizedBox(
                width: (160 - 12 - 6).w,
                child: Text.rich(
                  TextSpan(children: [
                    // WidgetSpan(
                    //     child: Container(
                    //   width: 12.w,
                    //   height: 12.w,
                    //   decoration: BoxDecoration(
                    //       color: color,
                    //       borderRadius: BorderRadius.circular(6.w),
                    //       border: Border.all(width: 1.w, color: Colors.white)),
                    // )),
                    // WidgetSpan(child: gwb(6)),
                    TextSpan(
                      text: "${data["codeName"] ?? ""}",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.textBlack6,
                      ),
                    ),
                    WidgetSpan(child: gwb(5)),
                    WidgetSpan(
                        child: SizedBox(
                      // color: Colors.amber,
                      height: 16.5.w,
                      width: 1.w,
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: gline(1, 10, color: AppColor.textGrey4)),
                    )),
                    WidgetSpan(child: gwb(5)),
                    WidgetSpan(
                        child: UnconstrainedBox(
                      child: SizedBox(
                        height: 16.5.w,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: getSimpleText("${priceFormat(boundsN)}%  ", 11,
                              AppColor.textGrey4),
                        ),
                      ),
                    )),
                    WidgetSpan(
                        child: UnconstrainedBox(
                      child: SizedBox(
                        height: 16.5.w,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: getSimpleText(
                              priceFormat(data["tolBounsN"] ?? 0,
                                  tenThousand: true),
                              11,
                              AppColor.textBlack6),
                        ),
                      ),
                    )),
                  ]),
                  maxLines: 2,
                  textAlign: TextAlign.start,
                ),
              ),
            ], width: 160, crossAxisAlignment: CrossAxisAlignment.start),
          );

          // SizedBox(
          //     width: 160.w,
          //     // height: 20.w,
          //     child: Text.rich(
          //       TextSpan(children: [
          //         WidgetSpan(
          //             child: Container(
          //           width: 12.w,
          //           height: 12.w,
          //           decoration: BoxDecoration(
          //               color: color,
          //               borderRadius: BorderRadius.circular(6.w),
          //               border: Border.all(width: 1.w, color: Colors.white)),
          //         )),
          //         WidgetSpan(child: gwb(6)),
          //         TextSpan(
          //             text: "${data["codeName"] ?? ""}阿萨德卡加斯林科大十九大",
          //             style: TextStyle(
          //                 fontSize: 11.sp, color: AppColor.textBlack6)),
          //         WidgetSpan(child: gwb(5)),
          //         WidgetSpan(child: gline(1, 10, color: AppColor.textGrey4)),
          //         WidgetSpan(child: gwb(5)),
          //         TextSpan(
          //             text: "${priceFormat(boundsN)}%  ",
          //             style: TextStyle(
          //                 fontSize: 11.sp, color: AppColor.textGrey4)),
          //         TextSpan(
          //             text: priceFormat(data["tolBounsN"] ?? 0,
          //                 tenThousand: true),
          //             style: TextStyle(
          //                 fontSize: 11.sp, color: AppColor.textBlack6)),
          //       ]),
          //       maxLines: 2,
          //       textAlign: TextAlign.start,
          //     )

          // Row(
          //   children: [
          //     Container(
          //       width: 12.w,
          //       height: 12.w,
          //       decoration: BoxDecoration(
          //           color: color,
          //           borderRadius: BorderRadius.circular(6.w),
          //           border: Border.all(width: 1.w, color: Colors.white)),
          //     ),
          //     gwb(6),
          //     getSimpleText(data["codeName"] ?? "", 11, AppColor.textBlack6),
          //     gwb(5),
          //     gline(1, 10, color: AppColor.textGrey4),
          //     gwb(5),
          //     getSimpleText(
          //         "${priceFormat(boundsN)}%  ", 11, AppColor.textGrey4),
          //     getSimpleText(
          //         priceFormat(data["tolBounsN"] ?? 0, tenThousand: true),
          //         11,
          //         AppColor.textBlack6)
          //   ],
          // ),
          // );
        },
      ),
    );
  }

  Widget cartView() {
    return Column(
      children: [
        ghb(14),
        type == DataStandardDetailType.earn ? pieChartView() : barChartView(),
        CustomButton(
          onPressed: () {
            controller.showChart = !controller.showChart;
          },
          child: SizedBox(
            width: 343.w,
            height: 22.8.w,
            child: Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                assetsName("pay/earndetail/btn_arrow_up_closechart"),
                width: 16.w,
                height: 16.w,
                fit: BoxFit.fill,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget pieChartView() {
    controller.pieSections = [];

    int realIndex = 0;
    for (var i = 0; i < controller.chartDatas.length; i++) {
      Map item = controller.chartDatas[i];

      if ((item["show"] ?? true) && (item["tolBounsN"] ?? 0) > 0.0) {
        String cStr = controller.chartColors[i % controller.chartColors.length];
        bool isTouched = controller.pieSectionIndex == realIndex;
        controller.pieSections.add(PieChartSectionData(
            radius: isTouched ? 33.w : 30.w,
            // showTitle: false,
            // title: isTouched
            //     ? "${item["codeName"] ?? ""}\n${item["tolBounsN"] ?? 0}"
            //     : "",
            // title: isTouched
            //     ? "${item["codeName"] ?? ""}\n${item["tolBounsN"] ?? 0}"
            //     : "",
            // value: item["show"]
            //     ? ((item["tolBounsN"] ?? 0.1) == 0 ? 0.1 : item["tolBounsN"]) /
            //         controller.chartAllNum *
            //         100
            //     : 0,
            showTitle: false,
            badgeWidget: getSimpleText(
                isTouched
                    ? "${item["codeName"] ?? ""}\n${item["tolBounsN"] ?? 0}"
                    : "",
                10,
                AppColor.textBlack4,
                maxLines: 2),
            value: item["show"]
                ? (item["tolBounsN"] ?? 0.0) / controller.chartAllNum * 100
                : 0,
            color: Color(int.parse("0xFF${cStr.substring(1, cStr.length)}"))));
        realIndex++;
      }
    }

    if (controller.pieSections.isEmpty) {
      controller.pieSections.add(PieChartSectionData(
          radius: 30.w,
          showTitle: false,
          value: 1,
          color: Color(int.parse(
              "0xFF${controller.chartColors[0].substring(1, controller.chartColors[0].length)}"))));
    }

    return sbRow([
      SizedBox(
          width: 145.w,
          height: 145.w,
          child: Stack(
            children: [
              Positioned.fill(
                  child: Center(
                      child: centClm([
                getSimpleText("总收益（元）", 10, const Color(0xFF8A9199)),
                // getSimpleText(controller.chartDatas.isEmpty ? "" : "总收益（元）", 10,
                //     const Color(0xFF8A9199)),
                ghb(3),
                getSimpleText(
                    controller.chartDatas.isEmpty
                        ? "0.00"
                        : priceFormat(controller.chartAllNum,
                            tenThousand: true),
                    16,
                    const Color(0xD8000000)),
              ]))),
              Positioned.fill(
                  child: PieChart(
                      PieChartData(
                          sections: controller.pieSections,
                          sectionsSpace: 0,
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                if (controller.pieSectionIndex != -1) {
                                  controller.pieSectionIndex = -1;
                                  controller
                                      .update([controller.chartCellBuildId]);
                                }
                                return;
                              }

                              if (controller.pieSectionIndex !=
                                  pieTouchResponse
                                      .touchedSection!.touchedSectionIndex) {
                                controller.pieSectionIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                                controller
                                    .update([controller.chartCellBuildId]);
                              }
                            },
                          )),
                      swapAnimationDuration:
                          const Duration(milliseconds: 300))),
            ],
          )),
      SizedBox(
        height: 145.w,
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: List.generate(controller.chartDatas.length,
                  (index) => bCell(index, controller.chartDatas[index])),
            ),
          ),
        ),
      ),
    ], width: 343 - 13 * 2);
  }

  Widget barChartView() {
    // controller.dataList =
    //     controller.dataList.isNotEmpty ? controller.dataList.sublist(0, 7) : [];
    List<BarChartGroupData> barGroupData = [];
    int maxInt = getMaxCount(controller.maxNum);
    barGroupData = List.generate(
        controller.dataList.length,
        (index) => BarChartGroupData(x: index, barsSpace: 20.w, barRods: [
              BarChartRodData(
                  borderRadius: BorderRadius.zero,
                  toY: 4 * controller.dataList[index]["tolNum"] / maxInt,
                  color: const Color(0xFF437DF4),
                  width: 16.w),
            ], showingTooltipIndicators: [
              0
            ]));
    String tmpTitle = "";
    switch (controller.dateIndex) {
      case 0:
        tmpTitle = "2022/10/10";
        break;
      case 1:
        tmpTitle = "2022/10";
        break;
      case 2:
        tmpTitle = "2022";
        break;
      default:
    }

    Map scale = getChartScale(controller.maxNum);

    double leftWidth = calculateTextSize(scale[4], 11, FontWeight.normal,
            double.infinity, 1, Global.navigatorKey.currentContext!)
        .width;
    leftWidth += 6.w;

    double barWidth = calculateTextSize(tmpTitle, 10, FontWeight.normal,
                double.infinity, 1, Global.navigatorKey.currentContext!)
            .width +
        10.w;

    barWidth = barWidth + 5.w;

    double barRealWidth = controller.dataList.length * barWidth + leftWidth;

    if (barRealWidth < 301.w) {
      barRealWidth = 301.w;
    }

    return Column(
      children: [
        sbRow([
          getSimpleText(
              controller.pDropDownList[controller.dropIndex - 1]["barUnit"],
              12,
              const Color(0xFF606366))
        ], width: 301),
        ghb(10),
        SizedBox(
          width: 301.w,
          height: 200.w,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: barRealWidth,
              height: 200.w,
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
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                              controller.dropIndex - 1 == 2
                                  ? priceFormat(
                                      controller.dataList[groupIndex]
                                              ["tolNum"] ??
                                          0,
                                      tenThousand: true)
                                  : "${controller.dataList[groupIndex]["tolNum"] ?? 0}",
                              TextStyle(
                                  fontSize: 13.sp, color: AppColor.theme));
                        },
                      )),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          var style = TextStyle(
                            color: AppColor.textBlack,
                            fontSize: 11.sp,
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
                          Map data = controller.dataList[index];
                          String title = "";
                          switch (controller.dateIndex) {
                            case 0:
                              title =
                                  "${data["year"] ?? 0}/${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}/${(data["day"] ?? 0) < 10 ? "0${data["day"] ?? 0}" : "${data["day"] ?? 0}"}";
                              break;
                            case 1:
                              title =
                                  "${data["year"] ?? 0}/${(data["month"] ?? 0) < 10 ? "0${data["month"] ?? 0}" : "${data["month"] ?? 0}"}";
                              break;
                            case 2:
                              title = "${data["year"] ?? 0}";
                              break;
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 3.w,
                            child:
                                getSimpleText(title, 10, AppColor.textBlack4),
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
                          color: const Color(0x19437DF4), strokeWidth: 1.w);
                    },
                  ),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 4,
                  minY: 0,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
