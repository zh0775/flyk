import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/home/home.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase.dart';
import 'package:cxhighversion2/home/integralRepurchase/integral_repurchase_order_detail.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IntegralRepurchaseOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralRepurchaseOrderController>(
        IntegralRepurchaseOrderController());
  }
}

class IntegralRepurchaseOrderController extends GetxController {
  final dynamic datas;
  IntegralRepurchaseOrderController({this.datas});

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

  cancelOrder(Map data) {
    simpleRequest(
      url: Urls.userIntegralRepurchaseRefuse(data["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          ShowToast.normal("订单成功取消");
          loadData();
        }
      },
      after: () {},
    );
  }

  payOrder(Map oData) {
    simpleRequest(
      url: Urls.userIntegralRepurchasePay(oData["id"]),
      params: {},
      success: (success, json) async {
        if (success) {
          Map data = json["data"] ?? {};
          if (data["aliData"] == null || data["aliData"].isEmpty) {
            ShowToast.normal("支付失败，请稍后再试");
            return;
          }
          Map aliData = await CustomAlipay().payAction(
            data["aliData"],
            payBack: () {
              Get.find<HomeController>().refreshHomeData();
              Get.offUntil(
                  GetPageRoute(
                      page: () => const IntegralRepurchaseOrder(),
                      binding: IntegralRepurchaseOrderBinding(),
                      settings: const RouteSettings(
                        name: "IntegralRepurchaseOrder",
                      )),
                  (route) => route is GetPageRoute
                      ? route.binding is MainPageBinding
                          ? true
                          : false
                      : false);
            },
          );

          if (!kIsWeb) {
            push(
                AppSuccessResult(
                  success: aliData["resultStatus"] == "9000",
                  title: "支付结果",
                  contentTitle:
                      aliData["resultStatus"] == "9000" ? "支付成功" : "支付失败",
                  buttonTitles: const ["查看订单", "继续购买"],
                  backPressed: () {
                    popToUntil();
                  },
                  onPressed: (index) {
                    if (index == 0) {
                      Get.offUntil(
                          GetPageRoute(
                              page: () => const IntegralRepurchaseOrder(),
                              binding: IntegralRepurchaseOrderBinding(),
                              settings: const RouteSettings(
                                name: "IntegralRepurchaseOrder",
                              )),
                          (route) => route is GetPageRoute
                              ? route.binding is MainPageBinding
                                  ? true
                                  : false
                              : false);
                    } else {
                      Get.offUntil(
                          GetPageRoute(
                              page: () => const IntegralRepurchase(),
                              binding: IntegralRepurchaseBinding(),
                              settings: const RouteSettings(
                                  name: "IntegralRepurchase",
                                  arguments: {
                                    "isRepurchase": true,
                                  })),
                          (route) => route is GetPageRoute
                              ? route.binding is MainPageBinding
                                  ? true
                                  : false
                              : false);
                    }
                  },
                ),
                Global.navigatorKey.currentContext!);
          }
        }
      },
      after: () {},
    );
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
  List<RefreshController> pullCtrls = [
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
  ];

  onRefresh(int refreshIdx) {
    loadData(loadIdx: refreshIdx);
  }

  onLoad(int loadIdx) {
    loadData(isLoad: true, loadIdx: loadIdx);
  }

  String loadListBuildId = "StatisticsMachineMaintain_loadListBuildId_";

  List topTabs = [
    {
      "id": -1,
      "name": "全部",
    },
    {
      "id": 0,
      "name": "待支付",
    },
    {
      "id": 1,
      "name": "已完成",
    },
    {
      "id": 2,
      "name": "已取消",
    }
  ];

  loadData({bool isLoad = false, int? loadIdx, String? searchText}) {
    int myLoadIdx = loadIdx ?? topIndex;
    if (dataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userIntegralRepurchaseList,
      params: {
        "orderState": topTabs[myLoadIdx]["id"],
        "pageSize": pageSizes[myLoadIdx],
        "pageNo": pageNos[myLoadIdx],
        "orderType": 1,
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

class IntegralRepurchaseOrder
    extends GetView<IntegralRepurchaseOrderController> {
  const IntegralRepurchaseOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "复购订单"),
      body: Stack(children: [
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 55.w,
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Positioned(
                      top: 20.w,
                      left: 0,
                      right: 0,
                      height: 20.w,
                      child: Row(
                        children:
                            List.generate(controller.topTabs.length, (index) {
                          return CustomButton(
                            onPressed: () {
                              controller.topIndex = index;
                            },
                            child: GetX<IntegralRepurchaseOrderController>(
                                builder: (_) {
                              return SizedBox(
                                width:
                                    375.w / controller.topTabs.length - 0.1.w,
                                child: Center(
                                  child: getSimpleText(
                                    controller.topTabs[index]["name"],
                                    15,
                                    controller.topIndex == index
                                        ? AppColor.theme
                                        : AppColor.text2,
                                    isBold: controller.topIndex == index,
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      )),
                  GetX<IntegralRepurchaseOrderController>(
                    builder: (_) {
                      return AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          top: 47.w,
                          width: 15.w,
                          left: controller.topIndex *
                                  (375.w / controller.topTabs.length - 0.1.w) +
                              ((375.w / controller.topTabs.length - 0.1.w) -
                                      15.w) /
                                  2,
                          height: 2.w,
                          child: Container(
                            color: AppColor.theme,
                          ));
                    },
                  )
                ],
              ),
            )),
        Positioned.fill(
            top: 55.w,
            child: PageView.builder(
              controller: controller.pageCtrl,
              itemCount: controller.topTabs.length,
              onPageChanged: (value) {
                controller.topIndex = value;
              },
              itemBuilder: (context, index) {
                return list(index);
              },
            ))
      ]),
    );
  }

  Widget list(int listIdx) {
    return GetBuilder<IntegralRepurchaseOrderController>(
      id: "${controller.loadListBuildId}$listIdx",
      builder: (_) {
        return SmartRefresher(
          controller: controller.pullCtrls[listIdx],
          onLoading: () => controller.onLoad(listIdx),
          onRefresh: () => controller.onRefresh(listIdx),
          enablePullUp:
              controller.counts[listIdx] > controller.dataLists[listIdx].length,
          child: controller.dataLists[listIdx].isEmpty
              ? GetX<IntegralRepurchaseOrderController>(
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
    int cellStatus = data["order_State"] ?? -1;

    return Align(
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        height: 165.w,
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
                          // getSimpleText(
                          //     "x${data["num"] ?? 1}", 12, AppColor.text3),
                        ], width: 315 - 20 - 60 - 10)
                      ],
                    ),
                  )
                ], width: 315 - 10 * 2),
              ),
            ),
            sbhRow([
              gwb(0),
              centRow(cellStatus == 0
                  ? [
                      getBtn(0, "取消订单", () {
                        showAlert(
                          Global.navigatorKey.currentContext!,
                          "是否要取消订单",
                          confirmOnPressed: () {
                            Get.back();
                            controller.cancelOrder(data);
                          },
                        );
                      }),
                      gwb(10),
                      getBtn(1, "继续支付", () {
                        controller.payOrder(data);
                      }),
                    ]
                  : [
                      getBtn(0, "查看详情", () {
                        push(const IntegralRepurchaserderDetail(), null,
                            binding: IntegralRepurchaserderDetailBinding(),
                            arguments: {
                              "data": data,
                            });
                      }),
                    ])
            ], width: 345 - 15 * 2, height: 50)
          ],
        ),
      ),
    );
  }

  getBtn(int type, String title, Function() onPressed) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
        width: 65.w,
        height: 25.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(
                width: 0.5.w,
                color: type == 0 ? AppColor.textGrey5 : AppColor.theme)),
        child: getSimpleText(
            title, 12, type == 0 ? AppColor.text2 : AppColor.theme),
      ),
    );
  }
}
