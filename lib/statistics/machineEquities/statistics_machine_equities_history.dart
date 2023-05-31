import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/statistics/machineEquities/statistics_machine_equities_history_detail.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:skeletons/skeletons.dart';

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

  // RefreshController pullCtrl = RefreshController();
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;
  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

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
      url: Urls.userTerminalAssociateLogs,
      params: {
        "pageNo": pageNo,
        "pageSize": pageSize,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          count = data["count"] ?? 0;
          List tmpDatas = data["data"] ?? [];
          dataList = isLoad ? [...dataList, ...tmpDatas] : tmpDatas;
          update();
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
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
    // pullCtrl.dispose();
    super.onClose();
  }
}

class StatisticsMachineEquitiesHistory
    extends GetView<StatisticsMachineEquitiesHistoryController> {
  const StatisticsMachineEquitiesHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "操作记录"),
      body: GetBuilder<StatisticsMachineEquitiesHistoryController>(
        builder: (_) {
          return EasyRefresh.builder(
            onLoad: () => controller.dataList.length >= controller.count
                ? null
                : controller.loadData(isLoad: true),
            onRefresh: () => controller.loadData(),
            // controller: controller.pullCtrl,
            childBuilder: (context, physics) {
              return controller.dataList.isEmpty
                  ? GetX<StatisticsMachineEquitiesHistoryController>(
                      builder: (_) {
                        return controller.isFirstLoading && !kIsWeb
                            ? SkeletonListView(
                                item: SkeletonItem(
                                    child: Column(
                                  children: [
                                    ghb(15),
                                    SkeletonParagraph(
                                      style: SkeletonParagraphStyle(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.w, horizontal: 15.w),
                                          lines: 1,
                                          spacing: 10.w,
                                          lineStyle: SkeletonLineStyle(
                                            // randomLength: true,
                                            height: 15.w,
                                            width: 315.w,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            // minLength: 150.w,
                                            // maxLength: 160.w,
                                          )),
                                    ),
                                    SkeletonAvatar(
                                      style: SkeletonAvatarStyle(
                                        shape: BoxShape.rectangle,
                                        width: 315.w,
                                        height: 80.w,
                                      ),
                                    ),
                                    SkeletonParagraph(
                                      style: SkeletonParagraphStyle(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.w, horizontal: 15.w),
                                          lines: 1,
                                          spacing: 10.w,
                                          lineStyle: SkeletonLineStyle(
                                            // randomLength: true,
                                            height: 15.w,
                                            width: 315.w,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            // minLength: 150.w,
                                            // maxLength: 160.w,
                                          )),
                                    ),
                                  ],
                                )),
                              )
                            : CustomListEmptyView(
                                physics: physics,
                                isLoading: controller.isLoading,
                              );
                      },
                    )
                  : ListView.builder(
                      physics: physics,
                      padding: EdgeInsets.only(bottom: 20.w),
                      itemCount: controller.dataList.length,
                      itemBuilder: (context, index) {
                        return historyCell(index, controller.dataList[index]);
                      },
                    );
            },
          );
        },
      ),
    );
  }

  Widget historyCell(int index, Map data) {
    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        height: 180.w,
        decoration: getDefaultWhiteDec(radius: 4),
        child: Column(
          children: [
            sbhRow([
              centRow([
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.5.w),
                  child:
                      // CustomNetworkImage(
                      //   src: AppDefault().imageUrl + (data["img"] ?? ""),
                      //   width: 21.w,
                      //   height: 21.w,
                      //   fit: BoxFit.cover,
                      // ),
                      Image.asset(
                    assetsName("common/default_head"),
                    width: 21.w,
                    height: 21.w,
                    fit: BoxFit.cover,
                  ),
                ),
                gwb(8),
                getSimpleText(
                    "分配给${data["suName"] ?? ""}的权益设备", 14, AppColor.text2,
                    isBold: true),
              ])
            ], width: 315, height: 50),
            Container(
              width: 315.w,
              height: 80.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(4.w)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    3,
                    (index) => sbhRow([
                          getWidthText(
                              index == 0
                                  ? "接收人"
                                  : index == 1
                                      ? "设备台数"
                                      : "操作时间",
                              12,
                              AppColor.text3,
                              77,
                              1,
                              textHeight: 1.3),
                          getWidthText(
                              index == 0
                                  ? data["suName"] ?? ""
                                  : index == 1
                                      ? "${data["applyNum"] ?? 1}"
                                      : data["applyTime"] ?? "",
                              12,
                              AppColor.text3,
                              315 - 15 * 2 - 77,
                              1,
                              textHeight: 1.3),
                        ], width: 315 - 15 * 2, height: 22)),
              ),
            ),
            ghb(5),
            sbhRow([
              getSimpleText("共${data["applyNum"] ?? 1}台", 12, AppColor.text2),
              CustomButton(
                onPressed: () {
                  push(const StatisticsMachineEquitiesHistoryDetail(), null,
                      binding: StatisticsMachineEquitiesHistoryDetailBinding(),
                      arguments: {"data": data});
                },
                child: Container(
                  width: 65.w,
                  height: 25.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      color: Colors.white,
                      border: Border.all(width: 0.5.w, color: AppColor.text3)),
                  child: getSimpleText("设备列表", 12, AppColor.text2),
                ),
              ),
            ], width: 315, height: 45),
            // CustomButton(
            //   onPressed: () {},
            //   child: SizedBox(
            //     height: 75.w,
            //     child: Center(
            //       child: sbRow([
            //         centClm([
            //           getSimpleText("申请时间：${data["addTime"] ?? ""}", 15,
            //               AppColor.textBlack2,
            //               isBold: true),
            //           ghb(8),
            //           getSimpleText(
            //               "申请人：${data["name"] ?? ""}", 12, AppColor.text3),
            //         ], crossAxisAlignment: CrossAxisAlignment.start),
            //         AnimatedRotation(
            //           turns: 0.25,
            //           duration: const Duration(milliseconds: 200),
            //           child: Image.asset(
            //             assetsName("statistics/icon_arrow_right_gray"),
            //             width: 12.w,
            //             fit: BoxFit.fitWidth,
            //           ),
            //         )
            //       ],
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           width: 345 - 15 * 2),
            //     ),
            //   ),
            // ),
            // gline(315, 0.5),
            // SizedBox(
            //   height: 209.w,
            //   child: centClm(List.generate(8, (index) {
            //     String t1 = "";
            //     String t2 = "";

            //     switch (index) {
            //       case 0:
            //         t1 = "商家";
            //         t2 = data["merName"] ?? "";
            //         break;
            //       case 1:
            //         t1 = "手机号";
            //         t2 = data["merPhone"] ?? "";
            //         break;
            //       case 2:
            //         t1 = "原设备型号";
            //         t2 = data["modelName"] ?? "";
            //         break;
            //       case 3:
            //         t1 = "原设备编号";
            //         t2 = data["termNo"] ?? "";
            //         break;
            //       case 4:
            //         t1 = "激活时间";
            //         t2 = data["activTime"] ?? "";
            //         break;
            //       case 5:
            //         t1 = "绑定商家";
            //         t2 = data["brandNameNew"] ?? "";
            //         break;
            //       case 6:
            //         t1 = "切换型号";
            //         t2 = data["modelNameNew"] ?? "";
            //         break;
            //       case 7:
            //         t1 = "切换编号";
            //         t2 = data["productName"] ?? "";
            //         break;
            //     }

            //     return infoCell(t1, t2);
            //   })),
            // )
          ],
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
