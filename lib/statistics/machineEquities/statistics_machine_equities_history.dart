import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class StatisticsMachineEquitiesHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<StatisticsMachineEquitiesHistoryController>(
        StatisticsMachineEquitiesHistoryController(datas: Get.arguments));
  }
}

class StatisticsMachineEquitiesHistoryController extends GetxController {
  final dynamic datas;
  StatisticsMachineEquitiesHistoryController({this.datas});

  RefreshController pullCtrl = RefreshController();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  List dataList = [];
  int pageSize = 20;
  int pageNo = 1;
  int count = 0;

  loadData({bool isLoad = false}) {
    isLoad ? pageNo++ : pageNo = 1;
    if (dataList.isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userTerminalAssociateLogsList,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpDatas = data["data"] ?? [];
          if (!isLoad && dataList.isEmpty && tmpDatas.isNotEmpty) {
            tmpDatas[0]["open"] = true;
          }
          dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;

          update();
          isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
    // Future.delayed(const Duration(seconds: 1), () {
    //   count = 100;
    //   List tmpDatas = [];
    //   for (var i = 0; i < pageSize; i++) {
    //     tmpDatas.add({
    //       "id": dataList.length + i,
    //       "name": i % 2 == 0 ? "李文斌" : "SDK",
    //       "img": "D0031/2023/1/202301311856422204X.png",
    //       "oldTNo": "O550006698$i",
    //       "newTNo": "T550006698$i",
    //       "useDay": 20 + i,
    //       "bName": "欢乐人",
    //       "bPhone": "13598901253",
    //       "bbName": "黄远熊",
    //       "newXh": i % 2 == 0 ? "盛电宝K300123" : "渝钱宝电签123",
    //       "oldXh": i % 2 == 0 ? "优POS大机" : "渝钱宝电签123",
    //       "addTime": "2020-01-23 13:26:09",
    //       "actTime": "2020-02-23 20:22:12",
    //       "open": !isLoad && i == 0
    //     });
    //   }
    //   dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;
    //   update();
    //   isLoad ? pullCtrl.loadComplete() : pullCtrl.refreshCompleted();
    //   isLoading = false;
    // });
  }

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    pullCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineEquitiesHistory
    extends GetView<StatisticsMachineEquitiesHistoryController> {
  const StatisticsMachineEquitiesHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "换机记录"),
      body: GetBuilder<StatisticsMachineEquitiesHistoryController>(
        builder: (_) {
          return SmartRefresher(
            onLoading: () => controller.loadData(isLoad: true),
            onRefresh: () => controller.loadData(),
            enablePullUp: controller.count > controller.dataList.length,
            controller: controller.pullCtrl,
            child: controller.dataList.isEmpty
                ? GetX<StatisticsMachineEquitiesHistoryController>(
                    builder: (_) {
                      return CustomEmptyView(
                        isLoading: controller.isLoading,
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: controller.dataList.length,
                    itemBuilder: (context, index) {
                      return historyCell(index, controller.dataList[index]);
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget historyCell(int index, Map data) {
    if (data["open"] == null) {
      data["open"] = false;
    }
    bool open = data["open"] ?? false;
    return Align(
      child: AnimatedContainer(
        margin: EdgeInsets.only(top: 15.w),
        duration: const Duration(milliseconds: 200),
        width: 345.w,
        height: open ? 285.w : 75.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4.w)),
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              CustomButton(
                onPressed: () {
                  data["open"] = !data["open"];
                  controller.update();
                },
                child: SizedBox(
                  height: 75.w,
                  child: Center(
                    child: sbRow([
                      centClm([
                        getSimpleText("申请时间：${data["addTime"] ?? ""}", 15,
                            AppColor.textBlack2,
                            isBold: true),
                        ghb(8),
                        getSimpleText(
                            "申请人：${data["name"] ?? ""}", 12, AppColor.text3),
                      ], crossAxisAlignment: CrossAxisAlignment.start),
                      AnimatedRotation(
                        turns: open ? 0.75 : 0.25,
                        duration: const Duration(milliseconds: 200),
                        child: Image.asset(
                          assetsName("statistics/icon_arrow_right_gray"),
                          width: 12.w,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                        width: 345 - 15 * 2),
                  ),
                ),
              ),
              gline(315, 0.5),
              SizedBox(
                height: 209.w,
                child: centClm(List.generate(8, (index) {
                  String t1 = "";
                  String t2 = "";

                  switch (index) {
                    case 0:
                      t1 = "商家";
                      t2 = data["merName"] ?? "";
                      break;
                    case 1:
                      t1 = "手机号";
                      t2 = data["merPhone"] ?? "";
                      break;
                    case 2:
                      t1 = "原设备型号";
                      t2 = data["modelName"] ?? "";
                      break;
                    case 3:
                      t1 = "原设备编号";
                      t2 = data["termNo"] ?? "";
                      break;
                    case 4:
                      t1 = "激活时间";
                      t2 = data["activTime"] ?? "";
                      break;
                    case 5:
                      t1 = "绑定商家";
                      t2 = data["brandNameNew"] ?? "";
                      break;
                    case 6:
                      t1 = "切换型号";
                      t2 = data["modelNameNew"] ?? "";
                      break;
                    case 7:
                      t1 = "切换编号";
                      t2 = data["productName"] ?? "";
                      break;
                  }

                  return infoCell(t1, t2);
                })),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget infoCell(String t1, String t2, {double height = 24}) {
    return sbhRow([
      getSimpleText(t1, 12, AppColor.text3),
      getSimpleText(t2, 12, AppColor.text2)
    ], width: 345 - 15 * 2, height: height);
  }
}
