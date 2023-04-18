import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_project_pay.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IntegralCashOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralCashOrderListController>(IntegralCashOrderListController());
  }
}

class IntegralCashOrderListController extends GetxController {
  final dynamic datas;
  IntegralCashOrderListController({this.datas});

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (isPageAnimate) {
      return;
    }
    if (_topIndex.value != v) {
      _topIndex.value = v;
      loadData(loadIdx: topIndex);
      changePage(topIndex);
    }
  }

  bool isPageAnimate = false;

  changePage(int? toIdx) {
    if (isPageAnimate) {
      return;
    }
    isPageAnimate = true;
    int idx = toIdx ?? topIndex;
    pageCtrl
        .animateToPage(idx,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut)
        .then((value) {
      isPageAnimate = false;
    });
  }

  PageController pageCtrl = PageController();

  List<int> pageSizes = [
    20,
    20,
    20,
    20,
    20,
  ];
  List<int> pageNos = [1, 1, 1, 1, 1];
  List<int> counts = [0, 0, 0, 0, 0];
  List<RefreshController> pullCtrls = [
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController(),
    RefreshController(),
  ];
  List<List> dataLists = [
    [],
    [],
    [],
    [],
    [],
  ];

  onRefresh(int refreshIdx) {
    loadData(loadIdx: refreshIdx);
  }

  onLoad(int loadIdx) {
    loadData(isLoad: true, loadIdx: loadIdx);
  }

  String loadListBuildId = "StatisticsMachineMaintain_loadListBuildId_";

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }
    simpleRequest(
      url: Urls.userIntegralRepurchaseList,
      params: {
        "orderState": -1,
        "pageSize": pageSizes[myLoadIdx],
        "pageNo": pageNos[myLoadIdx],
        "orderType": 2,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;
          List tmpList = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...tmpList] : tmpList;
          isLoad
              ? pullCtrls[myLoadIdx].loadComplete()
              : pullCtrls[myLoadIdx].refreshCompleted();

          update(["$loadListBuildId$myLoadIdx"]);
        } else {
          isLoad
              ? pullCtrls[myLoadIdx].loadFailed()
              : pullCtrls[myLoadIdx].refreshFailed();
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  // backoutAction() {
  //   loadData();
  // }

  // agreeAction() {
  //   loadData();
  // }

  // rejectAction() {
  //   loadData();
  // }

  againAction() {}

  @override
  void onInit() {
    loadData();
    super.onInit();
  }

  @override
  void onClose() {
    for (var e in pullCtrls) {
      e.dispose();
    }
    pageCtrl.dispose();
    super.onClose();
  }
}

class IntegralCashOrderList extends GetView<IntegralCashOrderListController> {
  const IntegralCashOrderList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "积分兑现订单"),
      body: Stack(
        children: [
          // Positioned(
          //     top: 0,
          //     left: 0,
          //     right: 0,
          //     height: 55.w,
          //     child: Container(
          //       color: Colors.white,
          //       child: Stack(
          //         children: [
          //           Positioned(
          //               top: 20.w,
          //               left: 0,
          //               right: 0,
          //               height: 20.w,
          //               child: Row(
          //                 children: List.generate(5, (index) {
          //                   String title = "";
          //                   switch (index) {
          //                     case 0:
          //                       title = "全部";
          //                       break;
          //                     case 1:
          //                       title = "未开始";
          //                       break;
          //                     case 2:
          //                       title = "已开始";
          //                       break;
          //                     case 3:
          //                       title = "未完成";
          //                       break;
          //                     case 4:
          //                       title = "已完成";
          //                       break;
          //                   }
          //                   return CustomButton(
          //                     onPressed: () {
          //                       controller.topIndex = index;
          //                     },
          //                     child: GetX<IntegralCashOrderListController>(
          //                         builder: (_) {
          //                       return SizedBox(
          //                         width: 375.w / 5 - 0.1.w,
          //                         child: Center(
          //                           child: getSimpleText(
          //                             title,
          //                             15,
          //                             controller.topIndex == index
          //                                 ? AppColor.theme
          //                                 : AppColor.text2,
          //                             isBold: controller.topIndex == index,
          //                           ),
          //                         ),
          //                       );
          //                     }),
          //                   );
          //                 }),
          //               )),
          //           GetX<IntegralCashOrderListController>(
          //             builder: (_) {
          //               return AnimatedPositioned(
          //                   duration: const Duration(milliseconds: 300),
          //                   curve: Curves.easeInOut,
          //                   top: 47.w,
          //                   width: 15.w,
          //                   left: controller.topIndex * (375.w / 5 - 0.1.w) +
          //                       ((375.w / 5 - 0.1.w) - 15.w) / 2,
          //                   height: 2.w,
          //                   child: Container(
          //                     color: AppColor.theme,
          //                   ));
          //             },
          //           )
          //         ],
          //       ),
          //     )),
          Positioned.fill(
              // top: 55.w,
              child: PageView.builder(
            controller: controller.pageCtrl,
            itemCount: 1,
            onPageChanged: (value) {
              controller.topIndex = value;
            },
            itemBuilder: (context, index) {
              return list(index);
            },
          ))
        ],
      ),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<IntegralCashOrderListController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<IntegralCashOrderListController>(
                  builder: (_) {
                    return CustomEmptyView(
                      isLoading: controller.isLoading,
                    );
                  },
                )
              : ListView.builder(
                  itemCount: controller.dataLists[listIdx].length,
                  padding: EdgeInsets.only(bottom: 20.w),
                  itemBuilder: (context, index) {
                    return cell(index, controller.dataLists[listIdx][index]);
                  },
                ),
        );
      },
    );
  }

  Widget cell(int index, Map data) {
    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        height: 225.w,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
        child: Column(
          children: [
            sbhRow([
              getSimpleText(
                "订单编号：${data["order_No"] ?? ""}",
                10,
                AppColor.text3,
              ),
              getSimpleText(data["managedStr"] ?? "", 12, AppColor.text2)
            ], width: 345 - 15 * 2, height: 40),
            Container(
              width: 315.w,
              height: 75.w,
              decoration: BoxDecoration(
                  color: AppColor.pageBackgroundColor,
                  borderRadius: BorderRadius.circular(4.w)),
              child: Center(
                child: sbRow([
                  CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["images"] ?? ""),
                    width: 60.w,
                    height: 60.w,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(
                    height: 60.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        getWidthText(data["title"] ?? "", 12, AppColor.text,
                            315 - 20 - 60 - 10, 2),
                        sbRow([
                          getSimpleText("￥${priceFormat(data["price2"] ?? 0)}",
                              12, AppColor.text3),
                          getSimpleText(
                              "x${data["num"] ?? 1}", 12, AppColor.text3),
                        ], width: 315 - 20 - 60 - 10)
                      ],
                    ),
                  )
                ], width: 315 - 10 * 2),
              ),
            ),
            SizedBox(
              height: 75.w,
              width: 315.w,
              child: centClm([
                infoCell("兑换时间", data["passTime"] ?? ""),
                infoCell("消耗积分", priceFormat(data["price"] ?? 0, savePoint: 0)),
                infoCell(
                    "兑换金额", "￥${(data["price2"] ?? 0) * (data["num"] ?? 1)}"),
              ], crossAxisAlignment: CrossAxisAlignment.start),
            ),
            sbRow([
              gwb(0),
              CustomButton(
                onPressed: () {
                  push(const IntegralProjectPay(), null,
                      binding: IntegralProjectPayBinding(),
                      arguments: {"data": data, "isRepurchase": false});
                },
                child: Container(
                  width: 65.w,
                  height: 25.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.w),
                      border: Border.all(width: 0.5.w, color: AppColor.theme)),
                  child: getSimpleText("再次兑换", 12, AppColor.theme),
                ),
              )
            ], width: 345 - 15 * 2)
          ],
        ),
      ),
    );
  }

  Widget infoCell(String t1, String t2,
      {double width = 62, double width2 = 180, double height = 20}) {
    return SizedBox(
      height: height.w,
      child: Center(
          child: Row(
        children: [
          getWidthText(t1, 12, AppColor.text3, width, 1, textHeight: 1.3),
          gwb(4.5),
          getWidthText(t2, 12, AppColor.text2, width2, 1, textHeight: 1.3),
        ],
      )),
    );
  }
}
