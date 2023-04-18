import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_dropdown_view.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/earn/earn_particulars.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyIntegralHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MyIntegralHistoryController>(
        MyIntegralHistoryController(datas: Get.arguments));
  }
}

class MyIntegralHistoryController extends GetxController {
  final dynamic datas;
  MyIntegralHistoryController({this.datas});

  GlobalKey stackKey = GlobalKey();
  GlobalKey headKey = GlobalKey();

  CustomDropDownController filterCtrl = CustomDropDownController();
  RefreshController pullCtrl = RefreshController();

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List typeFilterDatas = [];
  final _typeFilterIdx = 0.obs;
  int get typeFilterIdx => _typeFilterIdx.value;
  set typeFilterIdx(v) => _typeFilterIdx.value = v;
  int realTypeFilterIdx = 0;

  List dataList = [];
  int pageNo = 1;
  int pageSize = 20;
  int count = 0;

  loadData({bool isLoad = false, String? start, String? end}) {
    isLoad ? pageNo++ : pageNo = 1;
    Map<String, dynamic> params = {
      "a_No": typeFilterDatas[realTypeFilterIdx]["a_No"],
      "pageSize": pageSize,
      "pageNo": pageNo
    };

    if (start != null && start.isNotEmpty) {
      params["startingTime"] = start;
    }
    if (end != null && end.isNotEmpty) {
      params["end_Time"] = end;
    }

    simpleRequest(
      url: Urls.userFinanceIntegralList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"];
          count = data["count"];
          List tmpList = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpList] : tmpList;

          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
          update();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  filterConfirm() {
    realTypeFilterIdx = typeFilterIdx;
    showFilter();
    loadData();
  }

  filterReset() {
    typeFilterIdx = 0;
    realTypeFilterIdx = typeFilterIdx;
    startTimeStr = "";
    endTimeStr = "";
  }

  showFilter() {
    if (filterCtrl.isShow) {
      typeFilterIdx = realTypeFilterIdx;
      filterCtrl.hide();
    } else {
      filterCtrl.show(stackKey, headKey);
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateTime dateNow = DateTime.now();

  final _filterHeight = (0.0).obs;
  double get filterHeight => _filterHeight.value;
  set filterHeight(v) => _filterHeight.value = v;

  final _startTimeStr = "".obs;
  String get startTimeStr => _startTimeStr.value;
  set startTimeStr(v) => _startTimeStr.value = v;

  final _endTimeStr = "".obs;
  String get endTimeStr => _endTimeStr.value;
  set endTimeStr(v) => _endTimeStr.value = v;

  getFilterHeight() {
    int count = (typeFilterDatas.length / 3).ceil();
    filterHeight += 56.0;
    filterHeight += count * 40.0;
    filterHeight += count > 0 ? (count - 1) * 10.0 : 0;

    filterHeight += 56.0;
    filterHeight += 104.0;
    filterHeight += 1;
  }

  @override
  void onInit() {
    List accounts = AppDefault().homeData["u_Account"] ?? [];
    typeFilterDatas = [];
    for (var e in accounts) {
      if (e["a_No"] >= 4) {
        typeFilterDatas.add(e);
      }
    }
    loadData();
    getFilterHeight();
    super.onInit();
  }

  @override
  void onClose() {
    filterCtrl.dispose();
    pullCtrl.dispose();
    super.onClose();
  }
}

class MyIntegralHistory extends GetView<MyIntegralHistoryController> {
  const MyIntegralHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "积分明细", action: [
        CustomButton(
            onPressed: () {
              controller.showFilter();
            },
            child: SizedBox(
              width: 65.w,
              height: kToolbarHeight,
              child: Center(child: getSimpleText("筛选", 14, AppColor.text2)),
            )),
      ]),
      body: Stack(key: controller.stackKey, children: [
        Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: 0,
            key: controller.headKey,
            child: gemp()),
        Positioned.fill(child: GetBuilder<MyIntegralHistoryController>(
          builder: (_) {
            return SmartRefresher(
              controller: controller.pullCtrl,
              onLoading: () => controller.loadData(isLoad: true),
              onRefresh: () => controller.loadData(),
              enablePullUp: controller.count > controller.dataList.length,
              child: controller.dataList.isEmpty
                  ? GetX<MyIntegralHistoryController>(
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: controller.dataList.length,
                      padding: EdgeInsets.only(bottom: 20.w),
                      itemBuilder: (context, index) {
                        return jfCell(index, controller.dataList[index]);
                      },
                    ),
            );
          },
        )),
        GetX<MyIntegralHistoryController>(
          builder: (_) {
            return CustomDropDownView(
                height: controller.filterHeight.w,
                dropDownCtrl: controller.filterCtrl,
                dropWidget: Container(
                  width: 375.w,
                  height: controller.filterHeight.w,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SizedBox(
                      height: controller.filterHeight.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          centClm([
                            gline(375, 1),
                            sbhRow([
                              getSimpleText("积分类型", 15, AppColor.text,
                                  isBold: true),
                            ], width: 375 - 15 * 2, height: 56),
                            SizedBox(
                              width: 345.w,
                              child: Wrap(
                                  runSpacing: 10.w,
                                  spacing: 10.w,
                                  children: List.generate(
                                      controller.typeFilterDatas.length,
                                      (index) {
                                    return CustomButton(
                                      onPressed: () {
                                        if (controller.typeFilterIdx != index) {
                                          controller.typeFilterIdx = index;
                                        } else {
                                          // controller.typeFilterIdx = -1;
                                        }
                                      },
                                      child: GetX<MyIntegralHistoryController>(
                                        builder: (_) {
                                          return Container(
                                            width: (345 - 20).w / 3 - 0.1.w,
                                            height: 30.w,
                                            decoration: BoxDecoration(
                                                color:
                                                    controller.typeFilterIdx ==
                                                            index
                                                        ? AppColor.theme
                                                        : AppColor.theme
                                                            .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(4.w)),
                                            child: Center(
                                              child: getSimpleText(
                                                  controller.typeFilterDatas[
                                                          index]["name"] ??
                                                      "",
                                                  12,
                                                  controller.typeFilterIdx ==
                                                          index
                                                      ? Colors.white
                                                      : AppColor.text2),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  })),
                            ),
                            sbhRow([
                              getSimpleText("起止时间", 15, AppColor.text,
                                  isBold: true),
                            ], width: 375 - 15 * 2, height: 56),
                            sbRow(
                                List.generate(3, (index) {
                                  if (index == 1) {
                                    return getSimpleText(
                                        "至", 12, AppColor.text2);
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
                                                width: 0.5.w,
                                                color: AppColor.lineColor)),
                                        child: Center(
                                          child: sbRow([
                                            gwb(8),
                                            GetX<MyIntegralHistoryController>(
                                              builder: (_) {
                                                String text = index == 0
                                                    ? controller.startTimeStr
                                                    : controller.endTimeStr;
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
                                              assetsName(
                                                  "statistics/icon_date"),
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
                          ]),
                          Row(
                            children: List.generate(
                                2,
                                (index) => CustomButton(
                                      onPressed: () {
                                        if (index == 0) {
                                          controller.filterReset();
                                        } else {
                                          controller.filterConfirm();
                                        }
                                      },
                                      child: Container(
                                        width: 375.w / 2 - 0.1.w,
                                        height: 55.w,
                                        color: index == 0
                                            ? AppColor.theme.withOpacity(0.1)
                                            : AppColor.theme,
                                        child: Center(
                                          child: getSimpleText(
                                              index == 0 ? "重置" : "确定",
                                              15,
                                              index == 0
                                                  ? AppColor.theme
                                                  : Colors.white),
                                        ),
                                      ),
                                    )),
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          },
        )
      ]),
    );
  }

  Widget jfCell(int index, Map data) {
    return CustomButton(
      onPressed: () {
        push(
            EarnParticulars(
              earnData: data,
              title: "积分明细",
            ),
            null,
            binding: EarnParticularsBinding());
      },
      child: Container(
        width: 375.w,
        height: 75.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
                top: BorderSide(width: 0.5.w, color: AppColor.lineColor))),
        child: sbhRow([
          centClm([
            sbRow([
              getSimpleText(data["codeName"] ?? "", 15, AppColor.text2,
                  isBold: true),
              getSimpleText(
                  "${(data["bType"] ?? -1) == 0 ? "-" : "+"}${priceFormat(data["amount"] ?? 0, savePoint: 0)}",
                  18,
                  AppColor.text,
                  isBold: true)
            ], width: 345),
            ghb(8),
            getSimpleText(data["addTime"] ?? "", 12, AppColor.text3),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ], width: 345, height: 75),
      ),
    );
  }

  showDatePick({bool isStart = true}) async {
    String str = isStart ? controller.startTimeStr : controller.endTimeStr;
    if (str.isEmpty) {
      str = controller.dateFormat.format(controller.dateNow);
    }
    DateTime initialDate = controller.dateFormat.parse(str);
    DateTime? select = await showDatePicker(
        context: Global.navigatorKey.currentContext!,
        initialDate: initialDate,
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now());
    if (select != null) {
      if (isStart) {
        controller.startTimeStr = controller.dateFormat.format(select);
      } else {
        var start = controller.dateFormat.parse(controller.startTimeStr);
        if (select.isBefore(start)) {
          ShowToast.normal("结束日期不能早于开始日期，请重新选择");
        } else {
          controller.endTimeStr = controller.dateFormat.format(select);
        }
      }
    }
  }
}
