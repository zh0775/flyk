import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_empty_view.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/mine/mineStoreOrder/mine_store_order_detail.dart';
import 'package:cxhighversion2/product/product_pay_result_page.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

// enum StoreOrderType {
//   storeOrderTypeIntegral,
//   storeOrderTypePackage,
//   storeOrderTypeProduct,
// }

class MineStoreOrderListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MineStoreOrderListController>(MineStoreOrderListController());
  }
}

class MineStoreOrderListController extends GetxController {
  bool isFirst = true;
  // StoreOrderType? orderType;
  late PageController pageCtrl;
  RefreshController allPullCtrl = RefreshController();
  RefreshController payPullCtrl = RefreshController();
  RefreshController waitPullCtrl = RefreshController();
  RefreshController receiPullCtrl = RefreshController();
  RefreshController completePullCtrl = RefreshController();
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  late BottomPayPassword bottomPayPassword;

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

  int getStatus(int index) {
    int status = -1;
    switch (index) {
      case 0:
        status = -1;
        break;
      case 1:
        status = 0;
        break;
      case 2:
        status = 1;
        break;
      case 3:
        status = 2;
        break;
      case 4:
        status = 3;
        break;
    }
    return status;
  }

  bool topAnimation = false;
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

  int allPageNo = 1;
  int pageSize = 10;

  int payPageSize = 10;
  int payPageNo = 1;

  int waitPageSize = 10;
  int waitPageNo = 1;

  int receiPageNo = 1;
  int completePageNo = 1;

  int allCount = 0;
  int payPageCount = 0;
  int waitPageCount = 0;
  int receiPageCount = 0;
  int completePageCount = 0;

  String payListId = "MineStoreOrderList_payListId";
  String waitListId = "MineStoreOrderList_waitListId";
  String receiListId = "MineStoreOrderList_receiListId";
  String completeListId = "MineStoreOrderList_completeListId";
  String allListId = "MineStoreOrderList_allListId";

  final _allOrderList = Rx<List>([]);
  List get allOrderList => _allOrderList.value;
  set allOrderList(v) => _allOrderList.value = v;

  final _waitDataList = Rx<List>([]);
  List get waitDataList => _waitDataList.value;
  set waitDataList(v) => _waitDataList.value = v;

  final _payDataList = Rx<List>([
    // {
    //   "id": 0,
    //   "orderNo": "123123",
    //   "orderState": 0,
    //   "orderStateStr": "未支付",
    //   "totalPrice": 100,
    //   "totalScore": 1,
    //   "addTime": "2022/08/19 12:10:30",
    //   "processTime": "",
    //   "orderType": "",
    //   "productNum": "1",
    //   "recipient": "zzz",
    //   "recipientMobile": "159293809231",
    //   "recipientZip": "430000",
    //   "userAddress": "收货地址",
    //   "logisticsName": "顺丰快递",
    //   "courierNo": "sf12379823742839",
    //   "courierTime": null,
    //   "rownum": 0,
    //   "commodity": [
    //     {
    //       "num": 1,
    //       "shopName": "商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     }
    //   ]
    // },
    // {
    //   "id": 0,
    //   "orderNo": "123123",
    //   "orderState": 0,
    //   "orderStateStr": "未支付",
    //   "totalPrice": 100,
    //   "totalScore": 1,
    //   "addTime": "2022/08/19 12:10:30",
    //   "processTime": "",
    //   "orderType": "",
    //   "productNum": "1",
    //   "recipient": "zzz",
    //   "recipientMobile": "159293809231",
    //   "recipientZip": "430000",
    //   "userAddress": "收货地址",
    //   "logisticsName": "顺丰快递",
    //   "courierNo": "sf12379823742839",
    //   "courierTime": null,
    //   "rownum": 10,
    //   "commodity": [
    //     {
    //       "num": 1,
    //       "shopName": "商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     }
    //   ]
    // }
  ]);
  set payDataList(v) => _payDataList.value = v;

  List get payDataList => _payDataList.value;
  final _receiDataList = Rx<List>([
    // {
    //   "id": 1,
    //   "orderNo": "123123",
    //   "orderState": 1,
    //   "orderStateStr": "已支付",
    //   "totalPrice": 100,
    //   "totalScore": 1,
    //   "addTime": "2022/08/19 12:10:30",
    //   "processTime": "",
    //   "orderType": "",
    //   "productNum": "1",
    //   "recipient": "zzz",
    //   "recipientMobile": "159293809231",
    //   "recipientZip": "430000",
    //   "userAddress": "收货地址",
    //   "logisticsName": "顺丰快递",
    //   "courierNo": "sf12379823742839",
    //   "courierTime": null,
    //   "rownum": 10,
    //   "commodity": [
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     }
    //   ]
    // }
  ]);
  set receiDataList(v) => _receiDataList.value = v;
  List get receiDataList => _receiDataList.value;
  final _completeDataList = Rx<List>([
    // {
    //   "id": 2,
    //   "orderNo": "123123",
    //   "orderState": 2,
    //   "orderStateStr": "已完成",
    //   "totalPrice": 100,
    //   "totalScore": 1,
    //   "addTime": "2022/08/19 12:10:30",
    //   "processTime": "",
    //   "orderType": "",
    //   "productNum": "1",
    //   "recipient": "zzz",
    //   "recipientMobile": "159293809231",
    //   "recipientZip": "430000",
    //   "userAddress": "收货地址",
    //   "logisticsName": "顺丰快递",
    //   "courierNo": "Avatar/1.png",
    //   "courierTime": null,
    //   "rownum": 10,
    //   "commodity": [
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     },
    //     {
    //       "num": 1,
    //       "shopName": "商品名",
    //       "shopMeta": "啊数据库打了可视对讲拉卡手机打立卡手机打",
    //       "nowPrice": 293.5,
    //       "shopImg": "Avatar/1.png",
    //       "cashModes": "",
    //       "shopModel": "商品型号",
    //     }
    //   ]
    // }
  ]);
  List get completeDataList => _completeDataList.value;
  set completeDataList(v) => _completeDataList.value = v;

  deleteOrderAction(int index, int status) {
    String urls = "";
    // if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    // } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
    // } else if (orderType == StoreOrderType.storeOrderTypePackage) {
    //   urls = Urls.userLevelGiftDelOrder(
    //       getOrderId(index: index, status: status, key: "id"));
    // }
    urls = Urls.userLevelGiftDelOrder(
        getOrderId(index: index, status: status, key: "id"));

    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要删除该订单吗",
      cancelOnPressed: () {
        Get.back();
      },
      confirmOnPressed: () {
        simpleRequest(
          url: urls,
          params: {},
          success: (success, json) {
            if (success) {
              loadList(status: status);
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  payOrderAction(int index, int status) {
    payOrder = getPayOrder(
      index: index,
      status: status,
    );
    if ((homeData["u_3rd_password"] == null ||
            homeData["u_3rd_password"].isEmpty) &&
        payOrder["paymentMethodType"] == 2) {
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
    int id = 0;
    // if (orderType == StoreOrderType.storeOrderTypeIntegral) {
    // } else if (orderType == StoreOrderType.storeOrderTypeProduct) {
    // } else if (orderType == StoreOrderType.storeOrderTypePackage) {

    // }
    urls = Urls.userPayGiftOrder(payOrder["id"]);
    simpleRequest(
      url: urls,
      params: {
        "orderId": payOrder["id"],
        "version_Origin": AppDefault().versionOriginForPay(),
        "u_3nd_Pad": pwd,
      },
      success: (success, json) async {
        // if (success) {
        //   // Map result = await tobias.aliPay(json["data"]["aliData"]);
        // }

        if (payOrder["paymentMethodType"] != null &&
            payOrder["paymentMethod"] != null) {
          if (payOrder["paymentMethodType"] == 1 &&
              payOrder["paymentMethod"] == 1) {
            if (json != null &&
                json["data"] != null &&
                json["data"]["aliData"] != null) {
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
              ShowToast.normal("支付失败，请稍后再试");
              return;
            }
          } else if (payOrder["paymentMethodType"] == 2) {
            toPayResult(orderData: payOrder, toOrderDetail: !success);
          }
        }
      },
      after: () {},
    );
  }

  cancelOrderAction(int index, int status) {
    String urls = "";

    urls = Urls.userLevelGiftOrderCancel(
        getOrderId(index: index, status: status, key: "id"));

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
              loadList(status: status);
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  int getOrderId(
      {required int index, required int status, required String key}) {
    int id = 0;
    switch (status) {
      case 0:
        id = allOrderList[index][key];
        break;
      case 1:
        id = payDataList[index][key];
        break;
      case 2:
        id = waitDataList[index][key];
        break;
      case 3:
        id = receiDataList[index][key];
        break;
      case 4:
        id = completeDataList[index][key];
        break;
      default:
    }
    return id;
  }

  Map getPayOrder({required int index, required int status}) {
    Map r = {};
    switch (status) {
      case 0:
        r = allOrderList[index];
        break;
      case 1:
        r = payDataList[index];
        break;
      case 2:
        r = waitDataList[index];
        break;
      case 3:
        r = receiDataList[index];
        break;
      case 4:
        r = completeDataList[index];
        break;
      default:
    }
    return r;
  }

  confirmOrderAction(int index, int status) {
    String urls = "";

    urls = Urls.userLevelGiftOrderConfirm(
        getOrderId(index: index, status: status, key: "id"));
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
              loadList(status: status);
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  loadList({bool isLoad = false, required int status}) {
    RefreshController pullCtrl;
    int pageNo = 1;
    String buildId = "";

    if (status == 0) {
      pullCtrl = allPullCtrl;
      isLoad ? allPageNo++ : allPageNo = 1;
      pageNo = allPageNo;
      buildId = allListId;
    } else if (status == 1) {
      pullCtrl = payPullCtrl;
      isLoad ? payPageNo++ : payPageNo = 1;
      pageNo = payPageNo;
      buildId = payListId;
    } else if (status == 2) {
      pullCtrl = waitPullCtrl;
      isLoad ? waitPageNo++ : waitPageNo = 1;
      pageNo = waitPageNo;
      buildId = waitListId;
    } else if (status == 3) {
      pullCtrl = receiPullCtrl;
      isLoad ? receiPageNo++ : receiPageNo = 1;
      pageNo = receiPageNo;
      buildId = receiListId;
    } else if (status == 4) {
      pullCtrl = completePullCtrl;
      isLoad ? completePageNo++ : completePageNo = 1;
      pageNo = completePageNo;
      buildId = completeListId;
    } else {
      pullCtrl = payPullCtrl;
    }
    // isLoad ? pageNo++ : pageNo = 1;

    Map<String, dynamic> params = {};

    params["orderState"] = getStatus(topIndex);
    params["pageSize"] = pageSize;
    params["pageNo"] = pageNo;

    simpleRequest(
      url: Urls.userLevelGiftOrderList,
      params: params,
      success: (success, json) {
        if (success) {
          Map data = json["data"] ?? {};
          List list = data["data"] ?? [];
          int dataCount = data["count"] ?? 0;
          if (isLoad) {
            switch (status) {
              case 0:
                allOrderList = [...allOrderList, ...list];
                allCount = dataCount;
                break;
              case 1:
                payDataList = [...payDataList, ...list];
                payPageCount = dataCount;
                break;
              case 2:
                waitDataList = [...waitDataList, ...list];
                waitPageCount = dataCount;
                break;
              case 3:
                receiDataList = [...receiDataList, ...list];
                receiPageCount = dataCount;
                break;
              case 4:
                completeDataList = [...completeDataList, ...list];
                completePageCount = dataCount;
                break;
              default:
            }
            pullCtrl.loadComplete();
          } else {
            switch (status) {
              case 0:
                allOrderList = list;
                allCount = dataCount;
                break;
              case 1:
                payDataList = list;
                payPageCount = dataCount;
                break;
              case 2:
                waitDataList = list;
                waitPageCount = dataCount;
                break;
              case 3:
                receiDataList = list;
                receiPageCount = dataCount;
                break;
              case 4:
                completeDataList = list;
                completePageCount = dataCount;
                break;
              default:
            }
            pullCtrl.refreshCompleted();
          }
          update([buildId]);
        } else {
          isLoad ? pullCtrl.loadFailed() : pullCtrl.refreshFailed();
        }
      },
      after: () {
        isLoading = false;
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
      useCache: true,
    );
  }

  onLoad(int status) {
    loadList(status: status, isLoad: true);
  }

  onRefresh(int status) {
    loadList(status: status);
  }

  dataInit(int index) {
    if (!isFirst) {
      return;
    }
    topIndex = index;
    pageCtrl = PageController(initialPage: topIndex);
    isFirst = false;
    loadList(status: topIndex);
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
    payPullCtrl.dispose();
    receiPullCtrl.dispose();
    completePullCtrl.dispose();
    bottomPayPassword.dispos();
    waitPullCtrl.dispose();
    allPullCtrl.dispose();
    super.onClose();
  }
}

class MineStoreOrderList extends GetView<MineStoreOrderListController> {
  // final StoreOrderType orderType;
  final int index;
  const MineStoreOrderList({Key? key, this.index = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(index);
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(
          context,
          // orderType == StoreOrderType.storeOrderTypeIntegral
          //     ? "商城订单"
          //     : orderType == StoreOrderType.storeOrderTypePackage
          //         ? "礼包订单"
          //         : "采购订单",
          "我的订单",
          white: true,
          blueBackground: true),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 40.w,
              child: SizedBox(
                width: 375.w,
                height: 40.w,
                child: Row(
                  children: ["全部", "待付款", "待发货", "待收货", "已完成"]
                      .asMap()
                      .entries
                      .map((e) => CustomButton(
                            onPressed: () {
                              controller.topIndex = e.key;
                              // controller.changePage(e.key);
                            },
                            child: SizedBox(
                              width: (375 / 5).w,
                              height: 44.w,
                              child: Center(
                                  child: GetX<MineStoreOrderListController>(
                                init: controller,
                                builder: (_) {
                                  return centClm([
                                    getSimpleText(
                                      e.value,
                                      16,
                                      controller.topIndex != e.key
                                          ? const Color(0xFFBCC0C9)
                                          : const Color(0xFF2469F2),
                                    ),
                                    ghb(controller.topIndex == e.key ? 3 : 0),
                                    controller.topIndex != e.key
                                        ? ghb(0)
                                        : Container(
                                            width: 30.w,
                                            height: 2.w,
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF2469F2),
                                                borderRadius:
                                                    BorderRadius.circular(2.w)),
                                          )
                                  ]);
                                },
                              )),
                            ),
                          ))
                      .toList(),
                ),
              )),
          Positioned(
            top: 40.w,
            left: 0,
            right: 0,
            bottom: 0,
            child: PageView(
              physics: const BouncingScrollPhysics(),
              controller: controller.pageCtrl,
              scrollDirection: Axis.horizontal,
              onPageChanged: (value) {
                controller.topIndex = value;
                //   controller.changePage(value);
              },
              children: [
                GetBuilder<MineStoreOrderListController>(
                  id: controller.allListId,
                  init: controller,
                  builder: (_) {
                    return orderList(
                        controller.allOrderList,
                        controller.allCount,
                        0,
                        controller.allPullCtrl, () async {
                      controller.onRefresh(0);
                    }, () async {
                      controller.onLoad(0);
                    });
                  },
                ),
                GetBuilder<MineStoreOrderListController>(
                  id: controller.payListId,
                  init: controller,
                  builder: (_) {
                    return orderList(
                        controller.payDataList,
                        controller.payPageCount,
                        1,
                        controller.payPullCtrl, () async {
                      controller.onRefresh(1);
                    }, () async {
                      controller.onLoad(1);
                    });
                  },
                ),
                GetBuilder<MineStoreOrderListController>(
                  id: controller.waitListId,
                  init: controller,
                  builder: (_) {
                    return orderList(
                        controller.waitDataList,
                        controller.waitPageCount,
                        2,
                        controller.waitPullCtrl, () async {
                      controller.onRefresh(2);
                    }, () async {
                      controller.onLoad(2);
                    });
                  },
                ),
                GetBuilder<MineStoreOrderListController>(
                  id: controller.receiListId,
                  init: controller,
                  builder: (_) {
                    return orderList(
                        controller.receiDataList,
                        controller.receiPageCount,
                        3,
                        controller.receiPullCtrl, () async {
                      controller.onRefresh(3);
                    }, () async {
                      controller.onLoad(3);
                    });
                  },
                ),
                GetBuilder<MineStoreOrderListController>(
                  id: controller.completeListId,
                  init: controller,
                  builder: (_) {
                    return orderList(
                        controller.completeDataList,
                        controller.completePageCount,
                        4,
                        controller.completePullCtrl, () async {
                      controller.onRefresh(4);
                    }, () async {
                      controller.onLoad(4);
                    });
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget orderList(
      List datas,
      int count,
      int listIndex,
      RefreshController pullCtrl,
      Function()? onRefresh,
      Function()? onLoading) {
    return SmartRefresher(
        controller: pullCtrl,
        onRefresh: onRefresh,
        onLoading: onLoading,
        physics: const BouncingScrollPhysics(),
        enablePullUp: datas.length < count ? true : false,
        child: datas.isEmpty
            ? GetX<MineStoreOrderListController>(
                init: controller,
                builder: (_) {
                  return CustomEmptyView(
                    isLoading: controller.isLoading,
                  );
                },
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                    bottom: 15.w +
                        paddingSizeBottom(Global.navigatorKey.currentContext!)),
                itemCount: datas.isEmpty ? 0 : datas.length,
                itemBuilder: (context, index) {
                  return orderCell(datas[index], index, context, listIndex);
                },
              ));
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
      switch (payMethod) {
        case 1:
          unit = "分润";
          break;
        case 2:
          unit = "返现";
          break;
        case 3:
          unit = "奖励金";
          break;
        case 4:
          unit = "积分";
          break;
        case 5:
          unit = "激活豆";
          break;
        default:
      }
    }
    return CustomButton(
      onPressed: () {
        push(
            MineStoreOrderDetail(
              data: data,
              // orderType: orderType,
              statusList: controller.stateDataList,
            ),
            context,
            binding: MineStoreOrderDetailBinding());
      },
      child: Container(
        margin: EdgeInsets.only(top: 12.w, left: 15.w, right: 15.w),
        width: 345.w,
        decoration: getDefaultWhiteDec2(),
        child: Column(
          children: [
            // sbhRow(
            //     orderType == StoreOrderType.storeOrderTypeIntegral
            //         ? [
            //             getSimpleText("积分商城", 16, AppColor.textBlack,
            //                 isBold: true),
            //           ]
            //         : orderType == StoreOrderType.storeOrderTypePackage
            //             ? [
            //                 centRow([
            //                   Container(
            //                     width: 35.w,
            //                     height: 35.w,
            //                     decoration: BoxDecoration(
            //                         color: const Color(0xFFF5F5F5),
            //                         borderRadius:
            //                             BorderRadius.circular(17.5.w)),
            //                     child: Center(
            //                       child: Image.asset(
            //                         assetsName(
            //                             "mine/order/icon_order_type${listIndex == 0 ? "1" : listIndex == 1 ? "2" : "3"}"),
            //                         height: 18.w,
            //                         fit: BoxFit.fitHeight,
            //                       ),
            //                     ),
            //                   ),
            //                   gwb(12),
            //                   getSimpleText(data["levelName"] ?? "", 16,
            //                       AppColor.textBlack,
            //                       isBold: true)
            //                 ])
            //               ]
            //             : [],
            //     width: 345 - 15 * 2,
            //     height: 67),
            // gline(345, 0.5),
            ghb(17.5),
            data["commodity"] != null && data["commodity"].isNotEmpty
                ? Column(
                    children: [
                      ...(data["commodity"] as List)
                          .map((e) => centClm([
                                sbRow([
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.w),
                                    child: CustomNetworkImage(
                                      src:
                                          "${AppDefault().imageUrl}${e["shopImg"] ?? ""}",
                                      width: 116.w,
                                      height: 116.w,
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 116.w,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        centClm([
                                          getWidthText(e["shopName"], 14,
                                              AppColor.textBlack3, 189, 2),
                                          ghb(5),
                                          getWidthText(e["shopName"], 14,
                                              AppColor.textBlack3, 189, 2),
                                        ]),
                                        getRichText(
                                            "￥",
                                            priceFormat(e["nowPrice"] ?? 0),
                                            13,
                                            const Color(0xFFFF5A5F),
                                            18,
                                            const Color(0xFFFF5A5F)),
                                      ],
                                    ),
                                  )
                                  // centClm([
                                  //   getContentText(e["shopName"] ?? "", 15,
                                  //       AppColor.textBlack, 189, 50, 2,
                                  //       textAlign: TextAlign.start),
                                  //   ghb(25),
                                  //   sbRow([
                                  //     getSimpleText("数量x${e["num"] ?? 1}", 12,
                                  //         AppColor.textGrey),
                                  //     Text.rich(TextSpan(
                                  //         text: isReal ? "" : unit,
                                  //         style: TextStyle(
                                  //             fontSize: 10.sp,
                                  //             color: AppColor.textBlack),
                                  //         children: [
                                  //           TextSpan(
                                  //               text:
                                  //                   "${e["nowPrice"] ?? 0}${isReal ? unit : ""}",
                                  //               style: TextStyle(
                                  //                   fontSize: 14.sp,
                                  //                   color: AppColor.textBlack)),
                                  //         ]))
                                  //   ], width: 193.5),
                                  // ])
                                ], width: 345 - 15 * 2),
                                ghb(17.5),
                              ]))
                          .toList()
                    ],
                  )
                : sbRow([
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.w),
                      child: CustomNetworkImage(
                        src: "${AppDefault().imageUrl}${data["levelGiftImg"]}",
                        width: 116.w,
                        height: 116.w,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(
                      height: 116.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          centClm([
                            getWidthText(data["levelName"] ?? "", 14,
                                AppColor.textBlack3, 189, 2),
                            // ghb(5),
                            // getWidthText(data["shopName"], 14,
                            //     AppColor.textBlack3, 189, 2),
                          ]),
                          sbRow([
                            getRichText(
                                "￥",
                                priceFormat(data["totalPrice"] ?? 0),
                                13,
                                const Color(0xFFFF5A5F),
                                18,
                                const Color(0xFFFF5A5F)),
                            data["orderState"] == 1 ||
                                    data["orderState"] == 2 ||
                                    data["orderState"] == 3
                                ? Text.rich(TextSpan(children: [
                                    TextSpan(
                                        text: "实付款",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColor.color40)),
                                    TextSpan(
                                        text: "￥",
                                        style: TextStyle(
                                            fontSize: 12.sp,
                                            color: AppColor.color20)),
                                    TextSpan(
                                        text: priceFormat(
                                            data["totalPrice"] ?? 0),
                                        style: TextStyle(
                                            fontSize: 18.sp,
                                            color: AppColor.color20)),
                                  ]))
                                : gwb(0)
                          ], width: 189)
                        ],
                      ),
                    )
                    // centClm([
                    //   getContentText(data["levelName"], 15, AppColor.textBlack,
                    //       193.5, 50, 2,
                    //       textAlign: TextAlign.start),
                    //   ghb(25),
                    //   sbRow([
                    //     getSimpleText(
                    //         "数量x${data["num"]}", 12, AppColor.textGrey),
                    //     Text.rich(TextSpan(
                    //         text: "",
                    //         style: TextStyle(
                    //             fontSize: 10.sp, color: AppColor.textBlack),
                    //         children: [
                    //           TextSpan(
                    //               text:
                    //                   "${isReal ? "" : unit} ${data["totalPrice"]}${isReal ? unit : ""}",
                    //               style: TextStyle(
                    //                   fontSize: 14.sp,
                    //                   color: AppColor.textBlack)),
                    //         ]))
                    //   ], width: 193.5),
                    // ])
                  ], width: 345 - 15 * 2),
            // ghb(10),
            // sbRow([
            //   gwb(0),
            //   centRow([
            //     // getSimpleText("运费：包邮", 13, AppColor.textBlack),
            //     // gwb(5),
            //     Text.rich(TextSpan(
            //         text: "总价：",
            //         style:
            //             TextStyle(fontSize: 13.sp, color: AppColor.textBlack),
            //         children: [
            //           TextSpan(
            //               text: isReal ? "" : unit,
            //               style: TextStyle(
            //                   color: const Color(0xFFF13030), fontSize: 13.sp)),
            //           TextSpan(
            //               text: "${data["totalPrice"]}${isReal ? unit : ""}",
            //               style: TextStyle(
            //                 fontSize: 17.sp,
            //                 color: const Color(0xFFF13030),
            //               ))
            //         ]))
            //   ]),
            // ], width: 345 - 15 * 2),
            // ghb(20),
            // haveBottom(data) ? gline(345, 0.5) : ghb(0),
            haveBottom(data)
                ? sbhRow([
                    bottomLeftView(data),
                    centRow([
                      ...statusButtons(data, context,
                          index: index, status: listIndex),
                    ])
                  ], width: 345 - 15 * 2, height: 56.5)
                : centClm([
                    ghb(10),
                    sbRow([
                      bottomLeftView(data),
                    ], width: 345 - 15 * 2),
                    ghb(12),
                  ])
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
        Duration duration = controller.dateFormat
            .parse(data["addTime"])
            .add(const Duration(minutes: 30))
            .difference(now);
        if (duration.inMilliseconds < 0) {
          title = "订单支付超时";
          break;
        } else {
          return centClm([
            getSimpleText("实付款", 12, AppColor.color40),
            ghb(2),
            getRichText("￥", priceFormat(data["totalPrice"] ?? 0), 12,
                AppColor.color40, 18, AppColor.color40),
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

  List<Widget> statusButtons(Map data, BuildContext context,
      {required int index, required int status}) {
    List<Widget> l = [];
    // if (controller.stateDataList.isEmpty) {
    //   return l;
    // }
    if (data["orderState"] == 0) {
      bool timeOut = false;
      if (data["orderState"] == 0) {
        DateTime now = DateTime.now();
        Duration duration = controller.dateFormat
            .parse(data["addTime"])
            .add(const Duration(minutes: 30))
            .difference(now);
        timeOut = (duration.inMilliseconds < 0);
      }
      l.addAll([
        statusButton(
          "取消订单",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            controller.cancelOrderAction(index, status);
          },
        ),
        gwb(timeOut ? 0 : 10),
        timeOut
            ? gwb(0)
            : statusButton(
                "立即支付",
                const Color(0xFFFD255C),
                const Color(0xFFFD255C),
                bgColor: Colors.white,
                onPressed: () {
                  controller.payOrderAction(index, status);
                },
              ),
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
          const Color(0xFFF2892D),
          const Color(0xFFF2892D),
          bgColor: Colors.white,
          onPressed: () {
            controller.confirmOrderAction(index, status);
          },
        ),
      ]);
    } else if (data["orderState"] == 3 ||
        data["orderState"] == 4 ||
        data["orderState"] == 5) {
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
    } else if (data["orderState"] == 6 ||
        data["orderState"] == 7 ||
        data["orderState"] == 8) {
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
        width: 90.w,
        height: 32.w,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(width: 1.w, color: borderColor)),
        child: Center(
          child: getSimpleText(t1, 14, textColor),
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
                    decoration: BoxDecoration(
                        color: AppColor.lineColor,
                        borderRadius: BorderRadius.circular(5.w)),
                    child: Column(
                      children: [
                        ghb(25),
                        getSimpleText("点击快递编号即可复制查询", 15, AppColor.textBlack,
                            isBold: true),
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
                            child: Center(
                                child: getSimpleText(
                                    expressNo, 20, AppColor.textBlack,
                                    isBold: true)),
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
}
