import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/income/income_page_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class IncomePageListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IncomePageListController>(
        IncomePageListController(datas: Get.arguments));
  }
}

class IncomePageListController extends GetxController {
  final dynamic datas;
  IncomePageListController({this.datas});

  final _selectDate = "".obs;
  String get selectDate => _selectDate.value;
  set selectDate(v) => _selectDate.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  FixedExtentScrollController? yearPickCtrl;
  FixedExtentScrollController? monthPickCtrl;

  final _scrollYearIndex = 0.obs;
  int get scrollYearIndex => _scrollYearIndex.value;
  set scrollYearIndex(v) => _scrollYearIndex.value = v;
  final _scrollMonthIndex = 0.obs;
  int get scrollMonthIndex => _scrollMonthIndex.value;
  set scrollMonthIndex(v) => _scrollMonthIndex.value = v;

  cancelPick() {
    Get.back();
  }

  confirmPick() {
    Get.back();
    selectDate = "${yearList[scrollYearIndex]}年${monthList[scrollMonthIndex]}月";
    loadData();
  }

  showPick(int year, int month) {
    scrollYearIndex = yearList.indexOf(year);
    scrollMonthIndex = monthList.indexOf(month);
    if (yearPickCtrl != null) {
      yearPickCtrl!.dispose();
    }
    if (monthPickCtrl != null) {
      monthPickCtrl!.dispose();
    }
    yearPickCtrl = FixedExtentScrollController(initialItem: scrollYearIndex);
    monthPickCtrl = FixedExtentScrollController(initialItem: scrollMonthIndex);
    // yearPickCtrl.animateToItem(scrollYearIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.linear);
    // monthPickCtrl.animateToItem(scrollMonthIndex,
    //     duration: Duration(milliseconds: 300), curve: Curves.linear);
  }

  ///当前累计收益
  double get tolAmontByCode => _tolAmontByCode.value;
  set tolAmontByCode(v) => _tolAmontByCode.value = v;
  final _tolAmontByCode = 0.0.obs;

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;
  List dataList = [];

  DateFormat tmpDateFormat = DateFormat("yyyy-MM-dd");
  DateFormat addTimeDateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      // "tNo": businessData["tNo"] ?? "",
      // "tcId": businessData["tId"] ?? "",
      "code": bounsData["code"]
    };

    if (selectDate.isNotEmpty) {
      DateTime date = dateFormat.parse(selectDate);
      params["startingTime"] =
          tmpDateFormat.format(DateTime(date.year, date.month, 1));
      params["end_Time"] =
          tmpDateFormat.format(DateTime(date.year, date.month + 1, 0));
    }

    if (dataList.isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userBounsByDayList,
      params: params,
      success: (success, json) {
        if (success) {
          mainData = json["data"] ?? {};
          count = mainData["count"] ?? 0;
          tolAmontByCode = mainData["tolAmontByCode"] ?? 0.0;
          List tmpList = mainData["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
          update();
        }
      },
      after: () {
        isFirstLoading = false;
        isLoading = false;
      },
    );

    // Future.delayed(const Duration(seconds: 1), () {
    //   count = 30;
    //   List tmpList = [{}, {}, {}, {}, {}, {}, {}, {}];
    //   dataList = isLoad ? [...dataList, ...tmpList] : tmpList;
    //   update();
    //   isFirstLoading = false;
    //   isLoading = false;
    // });
  }

  DateFormat dateFormat = DateFormat("yyyy年MM月");
  DateTime now = DateTime.now();

  /// 分润奖励主数据
  Map mainData = {};
  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  List yearList = [];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  Map bounsData = {};

  @override
  void onInit() {
    for (var i = 0; i < 50; i++) {
      yearList.add(DateTime.now().year - i);
    }
    selectDate = dateFormat.format(now);
    bounsData = (datas ?? {})["data"] ?? {};

    // List boundList = (AppDefault().publicHomeData["bounsNameList"] ?? [])
    //     .map((e) => {
    //           "name": e["codeName"] ?? "",
    //           "id": e["code"] ?? -1,
    //           ...e,
    //         })
    //     .toList();
    // earnTypes = [
    //   {"id": -1, "name": "全部"},
    //   ...boundList
    // ];

    super.onInit();
  }
}

class IncomePageList extends GetView<IncomePageListController> {
  /// 收入- 奖励日列表
  ///
  /// 参数
  ///
  /// data 必传 奖励科目数据
  const IncomePageList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getDefaultAppBar(
            context, "${controller.bounsData["codeName"] ?? ""}明细"),
        body: Stack(clipBehavior: Clip.none, children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 193.w,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 345.w,
                        height: 129.w,
                        margin: EdgeInsets.only(top: 15.w),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.w),
                            gradient: const LinearGradient(
                                colors: [Color(0xFFFF3A3A), Color(0xFFFD573B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight)),
                        child: Stack(children: [
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Image.asset(
                                  assetsName("mine/wallet/icon_wallet1"),
                                  width: 70.w,
                                  fit: BoxFit.fitWidth)),
                          Positioned.fill(
                              child: Column(
                            children: [
                              ghb(25),
                              sbRow([
                                GetBuilder<IncomePageListController>(
                                    builder: (_) {
                                  return centClm([
                                    getSimpleText("累计收入(元)", 14, Colors.white),
                                    ghb(3),
                                    getSimpleText(
                                        priceFormat(controller
                                                .mainData["tolAmontByCode"] ??
                                            0),
                                        30,
                                        Colors.white,
                                        isBold: true)
                                  ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start);
                                })
                              ], width: 345 - 22 * 2)
                            ],
                          ))
                        ])),
                    sbhRow([
                      CustomButton(
                          onPressed: () {
                            int year = controller.dateFormat
                                .parse(controller.selectDate)
                                .year;
                            int month = controller.dateFormat
                                .parse(controller.selectDate)
                                .month;

                            controller.showPick(year, month);
                            showBottomDatePick(year, month);
                          },
                          child: centRow([
                            ghb(40),
                            // Image.asset(assetsName("common/icon_calendar"),
                            //     width: 15.w, fit: BoxFit.fitWidth),
                            gwb(3.5),
                            GetX<IncomePageListController>(builder: (_) {
                              return getSimpleText(
                                  controller.selectDate, 15, AppColor.textBlack,
                                  isBold: true);
                            }),
                            gwb(3),
                            Image.asset(
                                assetsName("mine/wallet/icon_down_arrow_black"),
                                width: 10.w,
                                fit: BoxFit.fitWidth)
                          ]))
                    ], width: 345, height: 45)
                  ])),
          Positioned.fill(
              top: 193.w,
              child: GetBuilder<IncomePageListController>(builder: (_) {
                return EasyRefresh.builder(
                    onLoad: controller.dataList.length >= controller.count
                        ? null
                        : () => controller.loadData(isLoad: true),
                    onRefresh: () => controller.loadData(),
                    childBuilder: (context, physics) {
                      return controller.dataList.isEmpty
                          ? GetX<IncomePageListController>(
                              builder: (_) {
                                return controller.isFirstLoading && !kIsWeb
                                    ? SkeletonListView(
                                        padding: EdgeInsets.all(15.w),
                                      )
                                    : CustomListEmptyView(
                                        physics: physics,
                                        isLoading: controller.isLoading);
                              },
                            )
                          : ListView.builder(
                              physics: physics,
                              padding: EdgeInsets.only(bottom: 20.w),
                              itemCount: controller.dataList.length,
                              itemBuilder: (context, index) {
                                Map data = controller.dataList[index];
                                return CustomButton(
                                  onPressed: () {
                                    push(const IncomePageDetail(), context,
                                        binding: IncomePageDetailBinding(),
                                        arguments: {
                                          "date":
                                              "${data["yesaD"] ?? 0}-${(data["monthD"] ?? 0) < 10 ? "0${data["monthD"] ?? 0}" : data["monthD"] ?? 0}-${(data["dayD"] ?? 0) < 10 ? "0${data["dayD"] ?? 0}" : data["dayD"] ?? 0}",
                                          "data": data
                                        });
                                  },
                                  child: Container(
                                    width: 375.w,
                                    height: 55.w,
                                    alignment: Alignment.center,
                                    color: Colors.white,
                                    child: sbhRow([
                                      getSimpleText(
                                          "${data["yesaD"] ?? 0}-${(data["monthD"] ?? 0) < 10 ? "0${data["monthD"] ?? 0}" : data["monthD"] ?? 0}-${(data["dayD"] ?? 0) < 10 ? "0${data["dayD"] ?? 0}" : data["dayD"] ?? 0}",
                                          16,
                                          AppColor.textBlack,
                                          isBold: true),
                                      centRow([
                                        getSimpleText(
                                            priceFormat(data["tolAmtD"] ?? 0),
                                            18,
                                            AppColor.textBlack,
                                            isBold: true),
                                        gwb(5),
                                        Image.asset(
                                            assetsName(
                                                "statistics/icon_arrow_right_gray"),
                                            width: 10.w,
                                            fit: BoxFit.fitWidth)
                                      ])
                                    ], width: 345, height: 55),
                                  ),
                                );
                              });
                    });
              }))
        ]));
  }

  showBottomDatePick(int year, int month) {
    Get.bottomSheet(
      Container(
        width: 375.w,
        height: 248.w,
        color: Colors.white,
        child: Column(
          children: [
            sbhRow([
              CustomButton(
                onPressed: () {
                  controller.cancelPick();
                },
                child: SizedBox(
                    width: 70.w,
                    height: 48.w,
                    child: Center(
                        child: getSimpleText("取消", 16, AppColor.textGrey))),
              ),
              CustomButton(
                onPressed: () {
                  controller.confirmPick();
                },
                child: SizedBox(
                    width: 70.w,
                    height: 48.w,
                    child: Center(
                        child: getSimpleText("确定", 16, AppColor.textBlack))),
              ),
            ], width: 375, height: 48),
            gline(375, 0.5),
            SizedBox(
                width: 375.w,
                height: (248 - 48 - 0.5).w,
                child: Center(
                  child: centRow([pick(true), pick(false)]),
                ))

            // CupertinoDatePicker(
            //   mode: CupertinoDatePickerMode.date,
            //   dateOrder: DatePickerDateOrder.ymd,
            //   initialDateTime: DateTime(year, month),
            //   onDateTimeChanged: (value) {},
            // ),
            // ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  Widget pick(bool isYear) {
    return SizedBox(
      height: (248 - 48 - 0.5).w,
      width: 123.w,
      child: Center(
        child: CupertinoPicker.builder(
          // key: isYear ? controller.yearPickKey : controller.monthPickKey,
          childCount:
              isYear ? controller.yearList.length : controller.monthList.length,
          scrollController:
              isYear ? controller.yearPickCtrl : controller.monthPickCtrl,
          itemExtent: 40.w,
          onSelectedItemChanged: (value) {
            isYear
                ? controller.scrollYearIndex = value
                : controller.scrollMonthIndex = value;
          },
          itemBuilder: (context, index) {
            return SizedBox(
                width: 123.w,
                height: 40.w,
                child: GetX<IncomePageListController>(
                  autoRemove: false,
                  init: controller,
                  builder: (_) {
                    return Center(
                      child: getSimpleText(
                        isYear
                            ? "${controller.yearList[index]}年"
                            : "${controller.monthList[index]}月",
                        isYear
                            ? (controller.scrollYearIndex == index ? 16 : 15)
                            : (controller.scrollMonthIndex == index ? 16 : 15),
                        isYear
                            ? (controller.scrollYearIndex == index
                                ? AppColor.textBlack
                                : AppColor.textBlack)
                            : (controller.scrollMonthIndex == index
                                ? AppColor.textBlack
                                : AppColor.textBlack),
                      ),
                    );
                  },
                ));
          },
        ),
      ),
    );
  }
}
