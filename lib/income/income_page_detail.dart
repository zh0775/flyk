import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
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

class IncomePageDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IncomePageDetailController>(
        IncomePageDetailController(datas: Get.arguments));
  }
}

class IncomePageDetailController extends GetxController {
  final dynamic datas;
  IncomePageDetailController({this.datas});

  final _selectDate = "".obs;
  String get selectDate => _selectDate.value;
  set selectDate(v) => _selectDate.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List earnTypes = [];

  final _earnTypeIdx = 0.obs;
  set earnTypeIdx(v) {
    if (_earnTypeIdx.value != v) {
      _earnTypeIdx.value = v;
      loadData();
    }
  }

  get earnTypeIdx => _earnTypeIdx.value;

  FixedExtentScrollController? yearPickCtrl;
  FixedExtentScrollController? monthPickCtrl;

  final _scrollYearIndex = 0.obs;
  int get scrollYearIndex => _scrollYearIndex.value;
  set scrollYearIndex(v) => _scrollYearIndex.value = v;
  final _scrollMonthIndex = 0.obs;
  int get scrollMonthIndex => _scrollMonthIndex.value;
  set scrollMonthIndex(v) => _scrollMonthIndex.value = v;

  DateFormat dateFormat = DateFormat("yyyy年MM月dd日");
  String myPickDate = "";

  cancelPick() {
    Get.back();
  }

  confirmPick() {
    Get.back();
    selectDate = myPickDate;
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

  int pageNo = 1;
  int pageSize = 20;
  int count = 0;
  List dataList = [];

  ///当前累计收益
  double get tolAmontByCode => _tolAmontByCode.value;
  set tolAmontByCode(v) => _tolAmontByCode.value = v;
  final _tolAmontByCode = 0.0.obs;

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;

    DateTime reqDate = dateFormat.parse(selectDate);
    String reqDay = DateFormat("yyyy-MM-dd")
        .format(DateTime(reqDate.year, reqDate.month, reqDate.day));

    Map<String, dynamic> params = {
      "pageSize": pageSize,
      "pageNo": pageNo,
      "code": earnTypes[earnTypeIdx]["id"],

      // "tNo": businessData["tNo"] ?? "",
      // "tcId": businessData["tId"] ?? "",
      "startingTime": "$reqDay 00:00:00",
      "end_Time": "$reqDay 23:59:59",
    };

    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userFinanceList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          tolAmontByCode = data["tolAmontByCode"] ?? 0.0;
          List tmpList = data["data"] ?? [];
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

  // DateFormat dateFormat = DateFormat("yyyy年MM月");
  DateTime now = DateTime.now();

  @override
  void onReady() {
    loadData();
    super.onReady();
  }

  List yearList = [];
  List monthList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  Map fromData = {};

  @override
  void onInit() {
    for (var i = 0; i < 50; i++) {
      yearList.add(DateTime.now().year - i);
    }
    fromData = (datas ?? {})["data"] ?? {};

    String d = (datas ?? {})["date"] ?? "";
    if (d.isNotEmpty) {
      selectDate = dateFormat.format(DateFormat("yyyy-MM-dd").parse(d));
    } else {
      selectDate = dateFormat.format(now);
    }
    myPickDate = selectDate;

    List boundList = (AppDefault().publicHomeData["bounsNameList"] ?? [])
        .map((e) => {"name": e["codeName"] ?? "", "id": e["code"] ?? -1, ...e})
        .toList();
    earnTypes = [
      {"id": -1, "name": "全部"},
      ...boundList
    ];

    super.onInit();
  }
}

class IncomePageDetail extends GetView<IncomePageDetailController> {
  /// 乐享分 参数
  /// date 时间（yyyy-MM-dd）默认当前时间
  /// data 收益列表数据 默认{}
  const IncomePageDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.white,
        appBar: getDefaultAppBar(context, "日明细"),
        body: Stack(clipBehavior: Clip.none, children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40.w,
              child: Center(
                  child: sbRow([
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
                      GetX<IncomePageDetailController>(builder: (_) {
                        return getSimpleText(
                            controller.selectDate, 12, AppColor.textBlack);
                      }),
                      gwb(3),
                      Image.asset(assetsName("income/btn_down_arrow"),
                          width: 10.w, fit: BoxFit.fitWidth)
                    ])),
                GetX<IncomePageDetailController>(
                  builder: (controller) {
                    return getSimpleText(
                        "当日总收入 ￥${priceFormat(controller.tolAmontByCode)}",
                        12,
                        AppColor.textGrey5);
                  },
                )
              ], width: 345))),
          Positioned.fill(
              top: 40.w,
              child: GetBuilder<IncomePageDetailController>(builder: (_) {
                return EasyRefresh.builder(
                    onLoad: controller.dataList.length >= controller.count
                        ? null
                        : () => controller.loadData(isLoad: true),
                    onRefresh: () => controller.loadData(),
                    childBuilder: (context, physics) {
                      return controller.dataList.isEmpty
                          ? GetX<IncomePageDetailController>(builder: (_) {
                              return controller.isFirstLoading && !kIsWeb
                                  ? SkeletonListView(
                                      padding: EdgeInsets.all(15.w),
                                    )
                                  : CustomListEmptyView(
                                      physics: physics,
                                      isLoading: controller.isLoading);
                            })
                          : ListView.builder(
                              physics: physics,
                              padding: EdgeInsets.only(bottom: 20.w),
                              itemCount: controller.dataList.length,
                              itemBuilder: (context, index) {
                                Map data = controller.dataList[index];
                                return Container(
                                  color: Colors.white,
                                  child: Center(
                                      child: sbhRow([
                                    centClm([
                                      getSimpleText(data["codeName"] ?? "", 15,
                                          AppColor.textBlack),
                                      ghb(10),
                                      getSimpleText(data["addTime"] ?? "", 12,
                                          AppColor.textGrey5)
                                    ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start),
                                    Padding(
                                        padding: EdgeInsets.only(bottom: 22.w),
                                        child: getSimpleText(
                                            "+${priceFormat(data["amount"] ?? 0)}",
                                            18,
                                            AppColor.textBlack,
                                            isBold: true))
                                  ], width: 345, height: 75)),
                                );
                              });
                    });
              }))
        ]));
  }

  showEarnTypeSelect() {
    Get.bottomSheet(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 345.w,
              padding: EdgeInsets.symmetric(vertical: 10.w),
              decoration: getDefaultWhiteDec(radius: 8),
              child:
                  centClm(List.generate(controller.earnTypes.length, (index) {
                return GetX<IncomePageDetailController>(builder: (_) {
                  return getSubmitBtn(controller.earnTypes[index]["name"], () {
                    controller.earnTypeIdx = index;
                    Get.back();
                  },
                      width: 330,
                      height: 45,
                      fontSize: 15,
                      textColor: AppColor.textBlack,
                      radius: 8,
                      color: controller.earnTypeIdx == index
                          ? const Color(0xFFEFEFEF)
                          : Colors.white);
                });
              })),
            ),
            ghb(5),
            getSubmitBtn("取消", () {
              Get.back();
            },
                width: 345,
                height: 45,
                radius: 6,
                color: Colors.white,
                textColor: AppColor.textGrey5,
                fontSize: 15),
            SizedBox(
                height: paddingSizeBottom(Global.navigatorKey.currentContext!) +
                    5.w)
          ],
        ),
        isScrollControlled: true);
  }

  showBottomDatePick(int year, int month) {
    Get.bottomSheet(
        Container(
            width: 375.w,
            height: 248.w,
            color: Colors.white,
            child: Column(children: [
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
                    // child: centRow([pick(true), pick(false)]),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      dateOrder: DatePickerDateOrder.ymd,
                      initialDateTime:
                          controller.dateFormat.parse(controller.selectDate),
                      onDateTimeChanged: (value) {
                        controller.myPickDate =
                            controller.dateFormat.format(value);
                      },
                    ),
                  ))
              // CupertinoDatePicker(
              //   mode: CupertinoDatePickerMode.date,
              //   dateOrder: DatePickerDateOrder.ymd,
              //   initialDateTime: DateTime(year, month),
              //   onDateTimeChanged: (value) {},
              // ),
              // )
            ])),
        isDismissible: true,
        enableDrag: true,
        isScrollControlled: true);
  }

  Widget pick(bool isYear) {
    return SizedBox(
        height: (248 - 48 - 0.5).w,
        width: 123.w,
        child: Center(
            child: CupertinoPicker.builder(
                // key: isYear ? controller.yearPickKey : controller.monthPickKey,
                childCount: isYear
                    ? controller.yearList.length
                    : controller.monthList.length,
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
                      child: GetX<IncomePageDetailController>(
                          autoRemove: false,
                          init: controller,
                          builder: (_) {
                            return Center(
                                child: getSimpleText(
                                    isYear
                                        ? "${controller.yearList[index]}年"
                                        : "${controller.monthList[index]}月",
                                    isYear
                                        ? (controller.scrollYearIndex == index
                                            ? 16
                                            : 15)
                                        : (controller.scrollMonthIndex == index
                                            ? 16
                                            : 15),
                                    isYear
                                        ? (controller.scrollYearIndex == index
                                            ? AppColor.textBlack
                                            : AppColor.textBlack)
                                        : (controller.scrollMonthIndex == index
                                            ? AppColor.textBlack
                                            : AppColor.textBlack)));
                          }));
                })));
  }
}
