import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_detail.dart';
import 'package:cxhighversion2/service/http.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MachineTransferOrderListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferOrderListController>(
        MachineTransferOrderListController());
  }
}

class MachineTransferOrderListController extends GetxController {
  final _topIndex = 0.obs;
  get topIndex => _topIndex.value;

  // List pageListData = [];
  // List pageNoList = [];
  // List pageSizeList = [];
  // List pageCountList = [];

  set topIndex(value) {
    if (isAnimateToPage) {
      return;
    }
    _topIndex.value = value;
    switch (value) {
      case 0:
        receptionRefresh();
        break;
      case 1:
        transferRefresh();
        break;
      case 2:
        completeRefresh();
        break;
    }
    if (!isFirst) {
      isAnimateToPage = true;
      pageViewCtrl
          .animateToPage(topIndex,
              duration: const Duration(milliseconds: 300), curve: Curves.linear)
          .then((value) {
        isAnimateToPage = false;
      });
    }
  }

  bool isAnimateToPage = false;

  late PageController pageViewCtrl;
  final receptionPullCtrl = RefreshController();
  final transferPullCtrl = RefreshController();
  final completePullCtrl = RefreshController();

  final _receptionDataList = Rx<List>([
    // {
    //   "id": 0,
    //   "applyTime": "2021年04月29日",
    //   "fuName": "大湾仔",
    //   "fuMobile": "186****7329",
    //   "applyTerminal": "盛付通大POS",
    //   "applyNum": 12,
    //   "applyType": 1
    //   //申请类型 1.积分 2.划拨
    // },
    // {
    //   "id": 0,
    //   "applyTime": "2021年04月29日",
    //   "fuName": "大湾仔",
    //   "fuMobile": "186****7329",
    //   "applyTerminal": "盛付通大POS",
    //   "applyNum": 12,
    //   "applyType": 2
    //   //申请类型 1.积分 2.划拨
    // }
  ]);
  set receptionDataList(value) => _receptionDataList.value = value;
  get receptionDataList => _receptionDataList.value;

  final _transferDataList = Rx<List>([]);
  set transferDataList(value) => _transferDataList.value = value;
  get transferDataList => _transferDataList.value;

  final _completeDataList = Rx<List>([]);
  set completeDataList(value) => _completeDataList.value = value;
  get completeDataList => _completeDataList.value;

  int pageSize = 10;

  String receptionListId = "receptionListId";
  String transferListId = "transferListId";
  String completeListId = "completeListId";

  int receptionPageNo = 1;
  int transferPageNo = 1;
  int completePageNo = 1;

  int completeCount = 0;
  int transferCount = 0;
  int receptionCount = 0;

  terminalTransferOrderRequest(Map<String, dynamic> params,
      Function(bool success, dynamic json) success) {
    Http().doPost(
      Urls.terminalTransferOrder,
      params,
      success: (json) async {
        if (json["success"]) {
          if (success != null) {
            success(true, json);
          }
        } else {
          if (success != null) {
            success(false, json);
          }
        }
      },
      fail: (reason, code, json) {
        if (success != null) {
          success(false, json);
        }
      },
    );
  }

  receptionRefresh() async {
    terminalTransferOrderRequest(
        {"type": 2, "pageSize": pageSize, "pageNo": receptionPageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        receptionCount = data["count"] ?? 0;
        receptionDataList = data["data"] ?? [];
        receptionPullCtrl.refreshCompleted();
        update([receptionListId]);
      } else {
        receptionPullCtrl.refreshFailed();
      }
    });
  }

  receptionLoad() async {
    receptionPageNo++;
    terminalTransferOrderRequest(
        {"type": 2, "pageSize": pageSize, "pageNo": receptionPageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        receptionCount = data["count"] ?? 0;
        receptionDataList = [...receptionDataList, ...(data["data"] ?? [])];
        receptionPullCtrl.loadComplete();
        update([receptionListId]);
      } else {
        receptionPullCtrl.loadFailed();
      }
    });
  }

  transferRefresh() async {
    terminalTransferOrderRequest(
        {"type": 1, "pageSize": pageSize, "pageNo": transferPageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        transferCount = data["count"] ?? 0;
        transferDataList = data["data"] ?? [];
        transferPullCtrl.refreshCompleted();
        update([transferListId]);
      } else {
        transferPullCtrl.refreshFailed();
      }
    });
  }

  transferLoad() async {
    transferPageNo++;
    terminalTransferOrderRequest(
        {"type": 1, "pageSize": pageSize, "pageNo": transferPageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        transferCount = data["count"] ?? 0;
        transferDataList = [...transferDataList, ...(data["data"] ?? [])];
        transferPullCtrl.loadComplete();
        update([transferListId]);
      } else {
        transferPullCtrl.loadFailed();
      }
    });
  }

  completeRefresh() async {
    terminalTransferOrderRequest(
        {"type": 3, "pageSize": pageSize, "pageNo": completePageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        completeCount = data["count"] ?? 0;
        completeDataList = data["data"] ?? [];
        completePullCtrl.refreshCompleted();
        update([completeListId]);
      } else {
        completePullCtrl.refreshFailed();
      }
    });
  }

  completeLoad() async {
    completePageNo++;
    terminalTransferOrderRequest(
        {"type": 3, "pageSize": pageSize, "pageNo": completePageNo},
        (bool success, dynamic json) {
      if (success && json["data"] != null) {
        Map data = json["data"];
        completeCount = data["count"] ?? 0;
        completeDataList = [...completeDataList, ...(data["data"] ?? [])];
        completePullCtrl.loadComplete();
        update([completeListId]);
      } else {
        completePullCtrl.loadFailed();
      }
    });
  }

  bool isFirst = true;
  int defaultIndex = 0;
  dataInit(int index) {
    if (!isFirst) {
      return;
    }

    defaultIndex = index;
    topIndex = defaultIndex;
    pageViewCtrl = PageController(initialPage: defaultIndex);
    isFirst = false;
  }
}

class MachineTransferOrderList
    extends GetView<MachineTransferOrderListController> {
  final int defaultIndex;
  const MachineTransferOrderList({Key? key, this.defaultIndex = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(defaultIndex);
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "待办订单"),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 44.w,
              child: Container(
                  width: 375.w,
                  height: 44.w,
                  color: Colors.white,
                  child: GetX<MachineTransferOrderListController>(
                    init: controller,
                    builder: (_) {
                      return sbhRow([
                        topButtons(0, "待接收"),
                        topButtons(1, "待划拨"),
                        topButtons(2, "完成"),
                      ], width: 375.w, height: 44.w);
                    },
                  ))),
          Positioned(
            top: 44.w,
            left: 0,
            right: 0,
            bottom: 0,
            child: PageView(
              physics: const BouncingScrollPhysics(),
              controller: controller.pageViewCtrl,
              onPageChanged: (value) {
                controller.topIndex = value;
              },
              children: [
                GetBuilder<MachineTransferOrderListController>(
                  id: controller.receptionListId,
                  init: controller,
                  builder: (_) {
                    return pullListView(
                        controller.receptionPullCtrl,
                        controller.receptionRefresh,
                        controller.receptionLoad,
                        controller.receptionCount >
                            controller.receptionDataList.length,
                        controller.receptionDataList);
                  },
                ),
                GetBuilder<MachineTransferOrderListController>(
                  id: controller.transferListId,
                  init: controller,
                  builder: (_) {
                    return pullListView(
                        controller.transferPullCtrl,
                        controller.transferRefresh,
                        controller.transferLoad,
                        controller.transferCount >
                            controller.transferDataList.length,
                        controller.transferDataList);
                  },
                ),
                GetBuilder<MachineTransferOrderListController>(
                  id: controller.completeListId,
                  init: controller,
                  builder: (_) {
                    return pullListView(
                        controller.completePullCtrl,
                        controller.completeRefresh,
                        controller.completeLoad,
                        controller.completeCount >
                            controller.completeDataList.length,
                        controller.completeDataList);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget topButtons(int idx, String t1) {
    return CustomButton(
      onPressed: () {
        controller.topIndex = idx;
      },
      child: SizedBox(
        width: (375 / 3).w,
        height: 44.w,
        child: Center(
          child: getSimpleText(
              t1,
              16,
              controller.topIndex == idx
                  ? AppColor.buttonTextBlue
                  : AppColor.textGrey,
              isBold: true),
        ),
      ),
    );
  }

  Widget pullListView(
    RefreshController pullCtrl,
    Function() refresh,
    Function() load,
    bool enablePullUp,
    List datas,
  ) {
    return SmartRefresher(
      physics: const BouncingScrollPhysics(),
      controller: pullCtrl,
      onLoading: load,
      onRefresh: refresh,
      enablePullDown: true,
      enablePullUp: enablePullUp,
      child: datas.isNotEmpty
          ? ListView.builder(
              itemCount: datas.isNotEmpty ? datas.length : 0,
              itemBuilder: (context, index) {
                return orderCell(index, datas[index]);
              },
            )
          : const CustomEmptyView(),
    );
  }

  // {
  //     "id": 0,
  //     "applyTime": "2021年04月29日",
  //     "fuName": "大湾仔",
  //     "fuMobile": "186****7329",
  //     "applyTerminal": "盛付通大POS",
  //     "applyNum": 12,
  //     "applyType": 1
  //     //申请类型 1.积分兑换 2.划拨
  //   }

  Widget orderCell(int idx, Map data) {
    return Align(
      child: GestureDetector(
        onTap: () {
          Get.to(
              () => MachineTransferOrderDetail(
                    orderData: data,
                    type: controller.topIndex,
                  ),
              binding: MachineTransferOrderDetailBinding());
        },
        child: Container(
          margin: EdgeInsets.only(top: 10.w),
          width: 345.w,
          decoration: getDefaultWhiteDec(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.w),
            child: Stack(
              children: [
                SizedBox(
                  width: 345.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ghb(19),
                      sbRow([
                        Text.rich(TextSpan(
                            text: "发起人：",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColor.textGrey,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      "${data["fuName"]}(${data["fuMobile"]})",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColor.textBlack,
                                      fontWeight: AppDefault.fontBold))
                            ]))
                      ], width: 345 - 20.5 * 2),
                      ghb(19),
                      sbRow([
                        Text.rich(TextSpan(
                            text: "${data["applyType"] == 1 ? "兑换" : "划拨"}台数：",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColor.textGrey,
                            ),
                            children: [
                              TextSpan(
                                  text: "${data["applyNum"]}台",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColor.textBlack,
                                      fontWeight: AppDefault.fontBold))
                            ]))
                      ], width: 345 - 20.5 * 2),
                      ghb(19),
                      data["applyType"] == 1
                          ? sbRow([
                              Text.rich(TextSpan(
                                  text: "兑换产品：",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColor.textGrey,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: "${data["applyTerminal"]}",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            color: AppColor.textBlack,
                                            fontWeight: AppDefault.fontBold))
                                  ]))
                            ], width: 345 - 20.5 * 2)
                          : const SizedBox(),
                      ghb(data["applyType"] == 1 ? 19 : 0),
                      sbRow([
                        getSimpleText(data["applyTime"], 16, AppColor.textBlack,
                            isBold: true),
                        CustomButton(
                          onPressed: () {},
                          child: centRow([
                            getSimpleText("查看详情", 16, const Color(0xFFA20606)),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18.w,
                              color: const Color(0xFFA20606),
                            ),
                          ]),
                        )
                      ], width: 345 - 20.5 * 2),
                      ghb(19),
                    ],
                  ),
                ),
                Positioned(
                    top: -24.w,
                    right: -24.w,
                    width: 60.w,
                    height: 50.w,
                    child: Transform.rotate(
                      angle: math.pi / 2 * 0.45,
                      child: Container(
                        width: 60.w,
                        height: 50.w,
                        color: data["applyType"] == 1
                            ? const Color(0xFFEB6100)
                            : const Color(0xFF72C36C),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: getSimpleText(
                              data["applyType"] == 1 ? "兑换" : "划拨",
                              12,
                              Colors.white,
                              isBold: true),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
