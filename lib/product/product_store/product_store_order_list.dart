import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_list_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_store/product_store_order_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:skeletons/skeletons.dart';

class ProductStoreOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreOrderListController>(ProductStoreOrderListController());
  }
}

class ProductStoreOrderListController extends GetxController {
  bool isFirst = true;

  late PageController pageCtrl;
  // RefreshController allPullCtrl = RefreshController();
  // RefreshController payPullCtrl = RefreshController();
  // RefreshController waitPullCtrl = RefreshController();
  // RefreshController receiPullCtrl = RefreshController();
  // RefreshController completePullCtrl = RefreshController();
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  final _naviIndex = 0.obs;
  int get naviIndex => _naviIndex.value;
  set naviIndex(v) {
    if (_naviIndex.value != v) {
      _naviIndex.value = v;
      _topIndex.value = 0;
      changeLevelType();
      changePage(topIndex);
      loadList(listIndex: _topIndex.value);
    }
  }

  late BottomPayPassword bottomPayPassword;

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _isFirstLoading = true.obs;
  bool get isFirstLoading => _isFirstLoading.value;
  set isFirstLoading(v) => _isFirstLoading.value = v;

  final _topIndex = 0.obs;
  int get topIndex => _topIndex.value;
  set topIndex(v) {
    if (!topAnimation) {
      _topIndex.value = v;
      changePage(topIndex);
      loadList(listIndex: topIndex);
    }
  }

  List normalStatusList = [
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "待付款"},
    {"id": 1, "name": "待发货"},
    {"id": 2, "name": "待收货"},
    {"id": 3, "name": "已完成"}
  ];
  List integralStatusList = [
    // {"id": -1, "name": "全部"},
    // {"id": 1, "name": "待发货"},
    // {"id": 2, "name": "待收货"},
    // {"id": 3, "name": "已完成"}
    {"id": -1, "name": "全部"},
    {"id": 0, "name": "待付款"},
    {"id": 1, "name": "待发货"},
    {"id": 2, "name": "待收货"},
    {"id": 3, "name": "已完成"}
  ];

  final _statusList = Rx<List>([]);
  List get statusList => _statusList.value;
  set statusList(v) => _statusList.value = v;

  bool topAnimation = false;
  changePage(int index) {
    if (isFirst) {
      return;
    }
    topAnimation = true;
    pageCtrl.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.linear).then((value) {
      topAnimation = false;
    });
  }

  List pageNos = [];
  List counts = [];
  List pageSizes = [];
  List dataLists = [];
  List normalDataLists = [[], [], [], [], []];
  List integralDataLists = [[], [], [], [], []];

  changeLevelType() {
    if (naviIndex == 0) {
      pageNos = [1, 1, 1, 1, 1];
      counts = [0, 0, 0, 0, 0];
      pageSizes = [20, 20, 20, 20, 20];
      dataLists = normalDataLists;
      statusList = normalStatusList;
    } else {
      pageNos = [1, 1, 1, 1, 1];
      counts = [0, 0, 0, 0, 1];
      pageSizes = [20, 20, 20, 20, 20];
      dataLists = integralDataLists;
      statusList = integralStatusList;
    }
  }

  // int allPageNo = 1;
  // int pageSize = 10;

  // int payPageSize = 10;
  // int payPageNo = 1;

  // int waitPageSize = 10;
  // int waitPageNo = 1;

  // int receiPageNo = 1;
  // int completePageNo = 1;

  // int allCount = 0;
  // int payPageCount = 0;
  // int waitPageCount = 0;
  // int receiPageCount = 0;
  // int completePageCount = 0;

  // String payListId = "MineStoreOrderList_payListId";
  // String waitListId = "MineStoreOrderList_waitListId";
  // String receiListId = "MineStoreOrderList_receiListId";
  // String completeListId = "MineStoreOrderList_completeListId";
  // String allListId = "MineStoreOrderList_allListId";

  String listBuildId = "MineStoreOrderList_buildid_";
  // 普通订单事件
  deleteOrderAction(int index, int status) {
    String urls = "";

    urls = Urls.userLevelGiftDelOrder(getOrderId(index: index, status: status, key: "id"));

    showAlert(Global.navigatorKey.currentContext!, "确定要删除该订单吗", cancelOnPressed: () {
      Get.back();
    }, confirmOnPressed: () {
      simpleRequest(
        url: urls,
        params: {},
        success: (success, json) {
          if (success) {
            loadList(listIndex: status);
          }
        },
        after: () {},
      );
      Get.back();
    });
  }

  payOrderAction(int index, int status) {
    payOrder = getPayOrder(
      index: index,
      status: status,
    );
    if ((homeData["u_3rd_password"] == null || homeData["u_3rd_password"].isEmpty) && payOrder["paymentMethodType"] == 2) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    if (payOrder["paymentMethodType"] == 1) {
      payAction("");
    } else if (payOrder["paymentMethodType"] == 2) {
      bottomPayPassword.show();
    }
  }

  Map payOrder = {};
  payAction(String pwd) {
    String urls = "";
    urls = Urls.userPayGiftOrder(payOrder["id"]);
    simpleRequest(
      url: urls,
      params: {
        "orderId": payOrder["id"],
        "version_Origin": AppDefault().versionOriginForPay(),
        "u_3nd_Pad": pwd,
      },
      success: (success, json) async {
        if (json != null && json["data"] != null && json["data"]["aliData"] != null) {
          Map result = await CustomAlipay().payAction(
            json["data"]["aliData"],
            payBack: () {
              alipayH5payBack(
                url: Urls.userLevelGiftOrderShow(payOrder["id"]),
                params: {},
              );
            },
          );
          if (!kIsWeb) {
            if (result["resultStatus"] == "6001") {
              toPayResult(orderData: payOrder, toOrderDetail: true);
            } else if (result["resultStatus"] == "9000") {
              toPayResult(orderData: payOrder);
            }
          }
        } else {
          toPayResult(orderData: payOrder, toOrderDetail: !success);
        }
      },
      after: () {},
    );
  }

  cancelOrderAction(int index, int status) {
    String urls = "";
    urls = Urls.userLevelGiftOrderCancel(getOrderId(index: index, status: status, key: "id"));

    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要取消该订单吗",
      cancelOnPressed: () {
        Get.back();
      },
      confirmOnPressed: () {
        simpleRequest(
          url: urls,
          params: {},
          success: (success, json) {
            if (success) {
              loadList(listIndex: status);
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  int getOrderId({required int index, required int status, required String key}) {
    // int id = 0;
    return dataLists[status][index][key];
  }

  Map getPayOrder({required int index, required int status}) {
    // Map r = {};
    return dataLists[status][index];
  }

  confirmOrderAction(int index, int status) {
    String urls = "";

    urls = Urls.userLevelGiftOrderConfirm(getOrderId(index: index, status: status, key: "id"));
    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要确认收货吗",
      cancelOnPressed: () {
        Get.back();
      },
      confirmOnPressed: () {
        simpleRequest(
          url: urls,
          params: {},
          success: (success, json) {
            if (success) {
              loadList(listIndex: status);
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  // 兑换订单事件

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

  prolongAction(Map data) {
    simpleRequest(
      url: Urls.orderProlongConfirm(data["id"]),
      params: {},
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

  // 请求列表
  loadList({bool isLoad = false, int? listIndex, int? listLevelType}) {
    int myLoadIdx = listIndex ?? topIndex;
    int myLevelIdx = listLevelType ?? naviIndex;
    isLoad ? pageNos[myLoadIdx]++ : pageNos[myLoadIdx] = 1;
    Map<String, dynamic> params = {
      "orderType": isBuyAndVip
          ? myLevelIdx == 0
              ? 2
              : 1
          : levelType
    };
    params["orderState"] = statusList[myLoadIdx]["id"];
    params["pageSize"] = pageSizes[myLoadIdx];
    params["pageNo"] = pageNos[myLoadIdx];

    // if (myLevelIdx == 1) {
    //   params["shopType"] == 2;
    // }
    if (myLevelIdx == 0 && normalDataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    } else if (myLevelIdx == 1 && integralDataLists[myLoadIdx].isEmpty) {
      isLoading = true;
    }

    simpleRequest(
      url: Urls.userLevelGiftOrderList,
      // url: myLevelIdx == 0 ? Urls.userLevelGiftOrderList : Urls.userOrderList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List list = data["data"] ?? [];
          counts[myLoadIdx] = data["count"] ?? 0;
          if (myLevelIdx == 0) {
            normalDataLists[myLoadIdx] = isLoad ? [...normalDataLists[myLoadIdx], ...list] : list;
            dataLists = normalDataLists;
          } else {
            integralDataLists[myLoadIdx] = isLoad ? [...integralDataLists[myLoadIdx], ...list] : list;
            dataLists = integralDataLists;
          }
          update(["$listBuildId${myLevelIdx}_$myLoadIdx"]);
        }
      },
      after: () {
        isLoading = false;
        isFirstLoading = false;
      },
    );
  }

  List stateDataList = [];
  // String statusBuildId = "MineStoreOrderList_statusBuildId";
  loadState() {
    simpleRequest(
        url: Urls.getOrderStatusList,
        params: {},
        success: (success, json) {
          if (success) {
            stateDataList = json["data"];
          }
        },
        after: () {},
        useCache: true);
  }

  bool isBuyAndVip = false;
  int levelType = 1;

  dataInit(int index, int level, bool buyAndVip) {
    if (!isFirst) {
      return;
    }
    isBuyAndVip = buyAndVip;
    levelType = level;
    _naviIndex.value = 0;
    _topIndex.value = naviIndex == 1 && index > 0
        ? index -= 1
        : index < 0
            ? 0
            : index;
    pageCtrl = PageController(initialPage: topIndex);
    isFirst = false;
    changeLevelType();
    loadList(listIndex: topIndex);
  }

  Map homeData = {};
  @override
  void onInit() {
    loadState();
    homeData = AppDefault().homeData;
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        payAction(payPwd);
      },
    );
    super.onInit();
  }

  getHomeDataNotify(arg) {
    homeData = AppDefault().homeData;
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    pageCtrl.dispose();
    bottomPayPassword.dispos();
    super.onClose();
  }
}

class ProductStoreOrderList extends GetView<ProductStoreOrderListController> {
  final int index;
  final int levelType;
  final bool isBuyAndVip;
  const ProductStoreOrderList({Key? key, this.index = 0, this.levelType = 0, this.isBuyAndVip = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(index, levelType, isBuyAndVip);
    return Scaffold(
      appBar: getDefaultAppBar(
          context,
          isBuyAndVip
              ? ""
              : levelType == 1
                  ? "礼包订单"
                  : levelType == 2
                      ? "采购商城订单"
                      : "机具兑换订单",
          flexibleSpace: !isBuyAndVip
              ? null
              : !AppDefault().checkDay
                  ? null
                  : Align(
                      alignment: Alignment.bottomCenter,
                      child: sbhRow(
                          List.generate(
                              2,
                              (index) => CustomButton(
                                    onPressed: () {
                                      controller.naviIndex = index;
                                    },
                                    child: GetX<ProductStoreOrderListController>(builder: (_) {
                                      return SizedBox(
                                        height: kToolbarHeight,
                                        child: Center(
                                          child: getSimpleText(index == 0 ? "采购订单" : "礼包订单", 18,
                                              controller.naviIndex == index ? AppColor.textBlack : AppColor.textGrey,
                                              isBold: controller.naviIndex == index),
                                        ),
                                      );
                                    }),
                                  )),
                          width: 170,
                          height: kToolbarHeight / 1.w),

                      // Container(
                      //   width: 200.w,
                      //   height: kToolbarHeight,
                      //   color: Colors.amber,
                      // ),
                    )),
      body: Stack(
        children: [
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
                        child: GetX<ProductStoreOrderListController>(builder: (_) {
                          return Row(
                            children: List.generate(controller.statusList.length, (index) {
                              return CustomButton(
                                onPressed: () {
                                  controller.topIndex = index;
                                },
                                child: SizedBox(
                                  width: 375.w / controller.statusList.length - 0.1.w,
                                  child: Center(
                                    child: getSimpleText(
                                      controller.statusList[index]["name"],
                                      15,
                                      controller.topIndex == index ? AppColor.theme : AppColor.textBlack,
                                      isBold: controller.topIndex == index,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        })),
                    GetX<ProductStoreOrderListController>(
                      builder: (_) {
                        return AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            top: 53.w,
                            width: 15.w,
                            left: controller.topIndex * (375.w / controller.statusList.length - 0.1.w) +
                                ((375.w / controller.statusList.length - 0.1.w) - 15.w) / 2,
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
            child: GetX<ProductStoreOrderListController>(builder: (_) {
              return PageView.builder(
                physics: const BouncingScrollPhysics(),
                controller: controller.pageCtrl,
                scrollDirection: Axis.horizontal,
                itemCount: controller.statusList.length,
                onPageChanged: (value) {
                  controller.topIndex = value;
                  //   controller.changePage(value);
                },
                itemBuilder: (context, index) {
                  return orderList(index, controller.naviIndex);
                },
              );
            }),
          )
        ],
      ),
    );
  }

  Widget orderList(int listIndex, int levelIdx) {
    return GetBuilder<ProductStoreOrderListController>(
        id: "${controller.listBuildId}${levelIdx}_$listIndex",
        builder: (_) {
          return EasyRefresh(
              onRefresh: () => controller.loadList(listIndex: listIndex, listLevelType: levelIdx),
              onLoad: controller.dataLists[listIndex].length >= controller.counts[listIndex]
                  ? null
                  : () => controller.loadList(isLoad: true, listIndex: listIndex, listLevelType: levelIdx),
              child: controller.dataLists[listIndex].isEmpty
                  ? controller.isFirstLoading && !kIsWeb
                      ? SkeletonListView(
                          item: Column(
                            children: [
                              ghb(15),
                              SkeletonParagraph(
                                style: SkeletonParagraphStyle(
                                    padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 15.w),
                                    lines: 1,
                                    spacing: 10.w,
                                    lineStyle: SkeletonLineStyle(
                                      randomLength: true,
                                      height: 8.w,
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                              ),
                              SkeletonAvatar(
                                style: SkeletonAvatarStyle(shape: BoxShape.rectangle, width: 315.w, height: 75.w),
                              ),
                              SkeletonParagraph(
                                style: SkeletonParagraphStyle(
                                    padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 15.w),
                                    lines: 2,
                                    spacing: 10.w,
                                    lineStyle: SkeletonLineStyle(
                                      randomLength: true,
                                      height: 8.w,
                                      borderRadius: BorderRadius.circular(8),
                                      // minLength: 150.w,
                                      // maxLength: 160.w,
                                    )),
                              ),
                            ],
                          ),
                        )
                      : GetX<ProductStoreOrderListController>(
                          init: controller,
                          builder: (_) {
                            return CustomListEmptyView(
                              isLoading: controller.isLoading,
                            );
                          },
                        )
                  : ListView.builder(
                      padding: EdgeInsets.only(bottom: 15.w + paddingSizeBottom(Global.navigatorKey.currentContext!)),
                      itemCount: controller.dataLists[listIndex].length,
                      itemBuilder: (context, index) {
                        return orderCell(controller.dataLists[listIndex][index], index, context, listIndex);

                        // levelIdx == 0
                        //     ? orderCell(controller.dataLists[listIndex][index],
                        //         index, context, listIndex)
                        //     : integralCell(
                        //         controller.dataLists[listIndex][index],
                        //         index,
                        //         listIndex);
                      },
                    ));
        });
  }

  bool haveBottom(Map data) {
    if (data == null || data["orderState"] == null) {
      return false;
    } else {
      if (data["orderState"] == 1) {
        return false;
      } else {
        return true;
      }
    }
  }

  Widget orderCell(Map data, int index, BuildContext context, int listIndex) {
    bool isReal = true;
    String unit = "";
    int payType = data["paymentMethodType"] ?? 1;
    int payMethod = data["paymentMethod"] ?? 1;

    if (payType == 1) {
      isReal = true;
      unit = "元";
    } else if (payType == 2) {
      isReal = false;
      List walletList = AppDefault().homeData["u_Account"] ?? [];
      for (var e in walletList) {
        if (payMethod == (e["a_No"] ?? 0)) {
          unit = e["name"] ?? "";
          break;
        }
      }
    }
    return CustomButton(
      onPressed: () {
        push(
            ProductStoreOrderDetail(data: data
                // statusList: controller.stateDataList,
                ),
            context,
            binding: ProductStoreOrderDetailBinding());
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.w),
        width: 345.w,
        // height: 165.w,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.w), color: Colors.white),
        // decoration: getDefaultWhiteDec2(),
        child: Column(
          children: [
            sbhRow([
              getSimpleText("订单编号：${data["orderNo"] ?? ""}", 10, AppColor.textGrey),
              getSimpleText(data["orderStateStr"] ?? getOrderStatustStr(data["orderState"] ?? -1), 12, AppColor.textBlack)
            ], height: 40, width: 315),
            Container(
              width: 315.w,
              height: 75.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.w),
                color: AppColor.pageBackgroundColor,
              ),
              child: sbRow([
                centRow([
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5.w),
                    child: CustomNetworkImage(
                      src: "${AppDefault().imageUrl}${data["levelGiftImg"]}",
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  gwb(11),
                  sbClm([
                    getWidthText(data["levelName"] ?? "", 12, AppColor.textBlack, 218, 2, isBold: true),
                    sbRow([
                      getSimpleText("${isReal ? "￥" : ""}${priceFormat(data["totalPrice"] ?? 0, savePoint: isReal ? 2 : 0)}${isReal ? "" : unit}", 12,
                          AppColor.textBlack),
                      getSimpleText("x${data["num"] ?? 1}", 12, AppColor.textGrey)
                    ], width: 295 - 60 - 11)
                  ], height: 55, crossAxisAlignment: CrossAxisAlignment.start)
                ])
              ], width: 295),
            ),
            sbhRow([
              gwb(0),
              getRichText("总计：", "${isReal ? "￥" : ""}${priceFormat(data["totalPrice"] ?? 0, savePoint: isReal ? 2 : 0)}${isReal ? "" : unit}", 12,
                  AppColor.textBlack, 12, const Color(0xFFFFB540))
            ], height: 40, width: 315),
            haveBottom(data)
                ? centClm([
                    sbhRow([
                      gwb(0),
                      // bottomLeftView(data),
                      centRow([
                        ...statusButtons(data, context, index: index, status: listIndex),
                      ])
                    ], width: 345 - 15 * 2, height: 25),
                    ghb(15),
                  ])
                : ghb(10),
          ],
        ),
      ),
    );
  }

  Widget bottomLeftView(Map data) {
    String title = "";
    switch ((data["orderState"] ?? -1)) {
      case 0:
        DateTime now = DateTime.now();
        Duration duration = controller.dateFormat.parse(data["addTime"]).add(const Duration(minutes: 30)).difference(now);
        if (duration.inMilliseconds < 0) {
          title = "订单支付超时";
          break;
        } else {
          return centClm([
            getSimpleText("实付款", 12, AppColor.color40),
            ghb(2),
            getRichText("￥", priceFormat(data["totalPrice"] ?? 0), 12, AppColor.color40, 18, AppColor.color40),
          ], crossAxisAlignment: CrossAxisAlignment.start);
        }
      case 1:
        title = "订单待发货";
        break;
      case 2:
        title = "订单待收货";
        break;
      case 3:
        title = "订单已完成";
        break;
      case 4:
        title = "订单退货中";
        break;
      case 5:
        title = "退货完成";
        break;
      case 6:
        title = "订单支付超时";
        break;
      case 7:
        title = "订单已取消";
        break;
      case 8:
        title = "订单已取消";
        break;
    }
    if (title.isNotEmpty) {
      return getSimpleText(title, 15, AppColor.color40);
    }
    return gwb(0);
  }

  List<Widget> statusButtons(Map data, BuildContext context, {required int index, required int status}) {
    List<Widget> l = [];
    // if (controller.stateDataList.isEmpty) {
    //   return l;
    // }
    if (data["orderState"] == 0) {
      // bool timeOut = false;
      // if (data["orderState"] == 0) {
      //   DateTime now = DateTime.now();
      //   Duration duration = controller.dateFormat
      //       .parse(data["addTime"])
      //       .add(const Duration(minutes: 30))
      //       .difference(now);
      //   timeOut = (duration.inMilliseconds < 0);
      // }
      l.addAll([
        // statusButton(
        //   "取消订单",
        //   const Color(0xFF7B8A99),
        //   const Color(0xFF8A9199),
        //   onPressed: () {
        //     controller.cancelOrderAction(index, status);
        //   },
        // ),
        statusButton("删除订单", AppColor.textBlack, const Color(0xFFB3B3B3), onPressed: () {
          controller.deleteOrderAction(index, status);
          // controller.checkLogisticsAction(index, status);
        }),
        // gwb(timeOut ? 0 : 10),
        // timeOut
        //     ? gwb(0)
        //     : statusButton(
        //         "立即支付",
        //         AppColor.theme,
        //         AppColor.theme,
        //         bgColor: Colors.white,
        //         onPressed: () {
        //           controller.payOrderAction(index, status);
        //         },
        //       ),
      ]);
    } else if (data["orderState"] == 1) {
      l.addAll([
        // statusButton(
        //   "查看物流",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction(index, status);
        //     showExpressNoModel(context, data["courierNo"]);
        //   },
        // ),
        // gwb(13.5),
        // statusButton(
        //   "确认收货",
        //   const Color(0xFFF2892D),
        //   const Color(0xFFF2892D),
        //   bgColor: Colors.white,
        //   onPressed: () {
        //     controller.confirmOrderAction(index, status);
        //   },
        // ),
      ]);
    } else if (data["orderState"] == 2) {
      l.addAll([
        statusButton(
          "查看物流",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            // controller.confirmOrderAction(index, status);
            if (data["courierNo"] != null) {
              showExpressNoModel(context, data["courierNo"] ?? "");
            } else {
              ShowToast.normal("暂无物流信息，请稍后再试");
            }
          },
        ),
        gwb(13.5),
        statusButton(
          "确认收货",
          AppColor.theme,
          AppColor.theme,
          bgColor: Colors.white,
          onPressed: () {
            controller.confirmOrderAction(index, status);
          },
        ),
      ]);
    } else if (data["orderState"] == 3 || data["orderState"] == 4 || data["orderState"] == 5) {
      l.addAll([
        // statusButton(
        //   "删除订单",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction(index, status);
        //   },
        // ),
        // gwb(13.5),
      ]);
    } else if (data["orderState"] == 6 || data["orderState"] == 7 || data["orderState"] == 8) {
      l.addAll([
        statusButton(
          "删除订单",
          AppColor.textBlack,
          const Color(0xFFB3B3B3),
          onPressed: () {
            controller.deleteOrderAction(index, status);
            // controller.checkLogisticsAction(index, status);
          },
        ),
      ]);
    }
    return l;
  }

  Widget statusButton(
    String t1,
    Color textColor,
    Color borderColor, {
    Function()? onPressed,
    Color? bgColor = Colors.transparent,
  }) {
    return CustomButton(
      onPressed: onPressed,
      child: Container(
        width: 65.w,
        height: 25.w,
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4.w), border: Border.all(width: 1.w, color: borderColor)),
        child: Center(
          child: getSimpleText(t1, 12, textColor),
        ),
      ),
    );
  }

  showExpressNoModel(BuildContext context, String expressNo) {
    showGeneralDialog(
      context: context,
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return Align(
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 345.w,
              height: 172.5.w,
              child: Column(
                children: [
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: Image.asset(
                      assetsName(
                        "common/btn_model_close",
                      ),
                      width: 37.w,
                      height: 56.5.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                    width: 345.w,
                    height: 116.w,
                    decoration: BoxDecoration(color: AppColor.lineColor, borderRadius: BorderRadius.circular(5.w)),
                    child: Column(
                      children: [
                        ghb(25),
                        getSimpleText("点击快递编号即可复制查询", 15, AppColor.textBlack, isBold: true),
                        ghb(13.5),
                        CustomButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: expressNo));
                            ShowToast.normal("已复制");
                          },
                          child: Container(
                            width: 270.w,
                            height: 35.w,
                            decoration: getDefaultWhiteDec(),
                            child: Center(child: getSimpleText(expressNo, 20, AppColor.textBlack, isBold: true)),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget integralCell(Map data, int index, int listIndex) {
    return Container(
      width: 375.w - 15.w * 2,
      margin: EdgeInsets.all(15.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      padding: EdgeInsets.all(15.w),
      child: Column(
        children: [
          SizedBox(
            child: sbRow([
              getSimpleText("订单编号：${data['orderNo'] ?? ""}", 10, const Color(0xFF999999)),
              getSimpleText("${data['orderStateStr'] ?? ""}", 12, AppColor.textBlack),
            ], width: 345.w),
          ),
          ghb(14),
          GestureDetector(
            onTap: () {
              // push(const IntegralStoreOrderDetail(), null,
              //     binding: IntegralStoreOrderDetailBinding(),
              //     arguments: {"data": data});
            },
            child: Container(
                width: 345.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(8.w),
                ),
                padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
                child: Column(
                  children: List.generate((data["commodity"] ?? []).length, (cIdx) {
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
                              getWidthText(cData["shopName"] ?? "", 12, AppColor.textBlack, 218, 1),
                              getSimpleText("已选：${cData['shopModel'] ?? ""}", 10, AppColor.textGrey5),
                              sbRow([
                                getSimpleText("${priceFormat(cData['nowPrice'] ?? 0, savePoint: 0)}积分", 10, const Color(0xFF333333)),
                                getSimpleText("x${cData['num']}", 12, const Color(0xFF999999)),
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
              getSimpleText("${priceFormat(data['totalPrice'] ?? 0, savePoint: 0)}积分", 12.w, const Color(0xFFFF6231)),
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
          // push(const IntegralstoreDetail(), null,
          //     binding: IntegralstoreDetailBinding(), arguments: {"data": data});
          // push(const IntegralStoreOrderDetail(), null,
          //     binding: IntegralStoreOrderDetailBinding(),
          //     arguments: {"data": data});
        },
      ));
    } else if (status == 2) {
      widgets.add(borderButton("延长收货", onPressed: () {
        myAlert("每笔订单仅可延长收货一次", () {
          controller.prolongAction(data);
        });
      }, type: 1));
      widgets.add(gwb(10));
      widgets.add(borderButton("确认收货", onPressed: () {
        myAlert("是否确认收货", () {
          controller.confirmAction(data);
        });
      }, type: 1));
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

  Widget borderButton(String buttonTitle, {Function()? onPressed, int type = 0}) {
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
            color: type == 0 ? AppColor.textGrey5 : AppColor.theme,
          ),
        ),
        child: getSimpleText(buttonTitle, 12.w, type == 0 ? AppColor.textBlack : AppColor.theme, textHeight: 1.1),
      ),
    );
  }
}
