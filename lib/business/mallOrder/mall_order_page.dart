/// 积分商城 我的售后页面

import 'package:cxhighversion2/business/mallOrder/mall_order_status.page.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MallOrderPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderPageController>(
        MallOrderPageController(datas: Get.arguments));
  }
}

class MallOrderPageController extends GetxController {
  final dynamic datas;

  MallOrderPageController({this.datas});

  bool isFirst = true;
  bool topAnimation = false; // top动画

  late PageController pageCtrl;
  // RefreshController allPullCtrl = RefreshController(); // 全部
  // RefreshController processingPullCtrl = RefreshController(); // 处理中
  // RefreshController completedPullCtrl = RefreshController(); // 已完成
  // RefreshController cancelledPullCtrl = RefreshController(); // 已取消
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  List<List> dataLists = [
    [],
    [],
    [],
    [],
  ];
  List<int> pageSizes = [
    20,
    20,
    20,
    20,
  ];
  List<int> pageNos = [
    1,
    1,
    1,
    1,
  ];
  List<int> counts = [
    0,
    0,
    0,
    0,
  ];

  toPayAction() {}
  cancelAction(Map data) {
    simpleRequest(
      url: Urls.userConfirmCancel,
      params: {"id": data["id"]},
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {},
    );
  }

  deletelAction(Map data) {
    simpleRequest(
      url: Urls.userDelOrder(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {},
    );
  }

  confirmAction(Map data) {
    simpleRequest(
      url: Urls.userOrderConfirm(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadList();
        }
      },
      after: () {},
    );
  }

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (!topAnimation) {
      _topIndex.value = v;
      changePage(topIndex);
      loadList(status: topIndex);
    }
  }

  String listBuildId = "MallOrderPageController_listBuildId_";

  loadList({bool isLoad = false, int? status}) {
    int myLoadIdx = status ?? topIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userOrderList,
      params: {
        "pageNo": pageNos[myLoadIdx],
        "pageSize": pageSizes[myLoadIdx],
        "shopType": 2,
        "orderState": myLoadIdx == 0
            ? -1
            : myLoadIdx == 1
                ? 1
                : myLoadIdx == 2
                    ? 2
                    : 3,
      },
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          counts[myLoadIdx] = data["count"] ?? 0;

          List tmpList = data["data"] ?? [];
          dataLists[myLoadIdx] =
              isLoad ? [...dataLists[myLoadIdx], ...tmpList] : tmpList;
          update(["$listBuildId$myLoadIdx"]);
        }
      },
      after: () {
        isLoading = false;
      },
    );
  }

  // 切换top-tabber
  changePage(int index) {
    if (isFirst) {
      return;
    }

    topAnimation = true;
    pageCtrl
        .animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.linear)
        .then((value) {
      topAnimation = false;
    });
  }

  @override
  void onInit() {
    pageCtrl = PageController(initialPage: (datas ?? {})["index"] ?? 0);
    topIndex = (datas ?? {})["index"] ?? 0;
    isFirst = false;
    super.onInit();
  }
}

class MallOrderPage extends GetView<MallOrderPageController> {
  const MallOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "我的订单"),
      body: Stack(
        children: [
          // topBar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 51.w,
            child: topBar(),
          ),

          Positioned(
            top: 51.w,
            left: 0,
            right: 0,
            bottom: 0,
            child: mallOrderPageView(),
          )
        ],
      ),
    );
  }

  // topBar
  Widget topBar() {
    return Container(
      width: 375.w,
      height: 51.w,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        children: ["全部", "待发货", "待收货", "已完成"]
            .asMap()
            .entries
            .map(
              (item) => CustomButton(
                onPressed: () {
                  controller.topIndex = item.key;
                },
                child: Center(
                  child: GetX<MallOrderPageController>(
                    init: controller,
                    initState: (_) {},
                    builder: (_) {
                      return SizedBox(
                        width: (375 / 4).w,
                        height: 55.w,
                        child: centClm([
                          getSimpleText(
                            item.value,
                            15,
                            controller.topIndex != item.key
                                ? const Color(0xFFBCC0C9)
                                : const Color(0xFFFF6231),
                          ),
                          ghb(controller.topIndex == item.key ? 3 : 0),
                          controller.topIndex != item.key
                              ? ghb(0)
                              : Container(
                                  width: 30.w,
                                  height: 2.w,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFFF6231),
                                      borderRadius: BorderRadius.circular(2.w)),
                                )
                        ]),
                      );
                    },
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // 积分商城我的订单
  Widget mallOrderPageView() {
    return PageView(
      physics: const BouncingScrollPhysics(),
      controller: controller.pageCtrl,
      scrollDirection: Axis.horizontal,
      onPageChanged: (value) {
        controller.topIndex = value;
      },
      children: [
        mallOrderList(0),
        mallOrderList(1),
        mallOrderList(2),
        mallOrderList(3),
      ],
    );
  }

  // 积分商城我的订单列表
  Widget mallOrderList(
    int listIndex,
  ) {
    return GetBuilder<MallOrderPageController>(
      id: "${controller.listBuildId}$listIndex",
      builder: (_) {
        return EasyRefresh(
          // controller: pullCtrl,
          onRefresh: () => controller.loadList(status: listIndex),
          onLoad: controller.dataLists[listIndex].length >=
                  controller.counts[listIndex]
              ? null
              : () => controller.loadList(isLoad: true, status: listIndex),
          child: controller.dataLists[listIndex].isEmpty
              ? SingleChildScrollView(
                  child: Center(
                    child: GetX<MallOrderPageController>(
                      init: controller,
                      builder: (_) {
                        return CustomEmptyView(
                          isLoading: controller.isLoading,
                          bottomSpace: 200.w,
                        );
                      },
                    ),
                  ),
                )
              : ListView.builder(
                  // physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                      bottom: 15.w +
                          paddingSizeBottom(
                              Global.navigatorKey.currentContext!)),
                  itemCount: controller.dataLists[listIndex].length,
                  itemBuilder: (context, index) {
                    return mallOrderItem(controller.dataLists[listIndex][index],
                        index, listIndex);
                  },
                ),
        );
      },
    );
  }

  //
  Widget mallOrderItem(Map data, int index, int listIndex) {
    return Container(
      width: 375.w - 15.w * 2,
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          SizedBox(
            child: sbRow([
              getSimpleText(
                  "订单编号：${data['orderNo'] ?? ""}", 10, const Color(0xFF999999)),
              getSimpleText(
                  "${data['orderStateStr'] ?? ""}", 12, AppColor.text2),
            ], width: 345.w),
          ),
          ghb(14),
          GestureDetector(
            onTap: () {
              push(const MallOrderStatusPage(), null,
                  binding: MallOrderStatusPageBinding(),
                  arguments: {"data": data});
            },
            child: Container(
                width: 345.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
                child: Column(
                  children:
                      List.generate((data["commodity"] ?? []).length, (cIdx) {
                    Map cData = (data["commodity"] ?? [])[cIdx];
                    return Padding(
                      padding: EdgeInsets.only(top: cIdx == 0 ? 0 : 10.w),
                      child: sbRow([
                        CustomNetworkImage(
                          src: AppDefault().imageUrl + (cData['shopImg'] ?? ""),
                          width: 60.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                        ),
                        gwb(11),
                        SizedBox(
                          width: 345.w - 60.w - 30.w * 2 - 11.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              getWidthText(cData["shopName"] ?? "", 12,
                                  AppColor.text, 218, 1),
                              getSimpleText("已选：${cData['shopModel'] ?? ""}",
                                  10, AppColor.textGrey5),
                              sbRow([
                                getSimpleText(
                                    "${priceFormat(cData['nowPrice'] ?? 0, savePoint: 0)}积分",
                                    10,
                                    const Color(0xFF333333)),
                                getSimpleText("x${cData['num']}", 12,
                                    const Color(0xFF999999)),
                              ])
                            ],
                          ),
                        ),
                      ]),
                    );
                  }),
                )),
          ),
          ghb(15.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              getSimpleText("总计：", 10.w, const Color(0xFF333333)),
              getSimpleText(
                  "${priceFormat(data['totalPrice'] ?? 0, savePoint: 0)}积分",
                  12.w,
                  const Color(0xFFFF6231)),
            ],
          ),
          ghb(13),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buttons(data)
              // borderButton('查看物流', const Color.fromARGB(255, 164, 151, 151),
              //     data['logisticsId'] ?? 0, '1')
            ],
          )
        ],
      ),
    );
  }

  Widget buttons(Map data) {
    int status = (data["orderState"] ?? -1);
    List<Widget> widgets = [];

    if (status == 0) {
      widgets.add(borderButton(
        "取消订单",
        onPressed: () {
          myAlert("是否确认取消订单", () {
            controller.cancelAction(data);
          });
        },
      ));
    } else if (status == 1) {
      widgets.add(borderButton(
        "查看详情",
        onPressed: () {
          push(const MallOrderStatusPage(), null,
              binding: MallOrderStatusPageBinding(), arguments: {"data": data});
        },
      ));
    } else if (status == 2) {
      widgets.add(borderButton(
        "确认收货",
        onPressed: () {
          myAlert("是否确认收货", () {
            controller.confirmAction(data);
          });
        },
      ));
    }
    return centRow(widgets);
  }

  myAlert(String title, Function() confirm) {
    showAlert(
      Global.navigatorKey.currentContext!,
      title,
      confirmOnPressed: () {
        Get.back();
        confirm();
      },
    );
  }

  Widget borderButton(String buttonTitle,
      {Function()? onPressed, int type = 0}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
        // print("button对应的事件");
        // push(const RefundProgressPage(), null,
        //     binding: RefundProgressPageBinding());
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(8.5.w, 7.w, 8.5.w, 7.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4.w),
          border: Border.all(
            width: 0.5.w,
            color: type == 0 ? AppColor.textGrey5 : AppColor.themeOrange,
          ),
        ),
        child: getSimpleText(
            buttonTitle, 12.w, type == 0 ? AppColor.text : AppColor.themeOrange,
            textHeight: 1.1),
      ),
    );
  }
}
