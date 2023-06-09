import 'dart:async';

import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/product_store/product_store_order_list.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProductStoreOrderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreOrderDetailController>(
        ProductStoreOrderDetailController());
  }
}

class ProductStoreOrderDetailController extends GetxController {
  bool isFirst = true;

  Timer? timer;
  String timebuildId = "MineStoreOrderDetail_timebuildId";
  String minutes = "30";
  String second = "00";
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");

  late DateTime addDateTime;
  void payCountDown() {
    if (myData.isEmpty ||
        myData["addTime"] == null ||
        myData["addTime"].isEmpty ||
        myData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      return;
    }
    DateTime now = DateTime.now();
    addDateTime =
        dateFormat.parse(myData["addTime"]).add(const Duration(minutes: 30));
    Duration duration = addDateTime.difference(now);

    if (duration.inMilliseconds < 0 || myData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
        loadDetail();
      }
    } else {
      timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        DateTime currentTime = DateTime.now();
        Duration d = addDateTime.difference(currentTime);
        if (d.inMilliseconds < 0 || myData["orderState"] != 0) {
          timer?.cancel();
          timer = null;
          loadDetail();
        }
        int realSeconds = d.inSeconds - d.inMinutes * 60;
        minutes = d.inMinutes < 10 ? "0${d.inMinutes}" : "${d.inMinutes}";
        second = realSeconds < 10 ? "0$realSeconds" : "$realSeconds";
        update([timebuildId]);
        loadDetail();
        print("second == $second");
      });
    }
  }

  RefreshController pullCtrl = RefreshController();

  final _haveSecond = 0.obs;
  get haveSecond => _haveSecond.value;
  set haveSecond(v) => _haveSecond.value = v;

  final _haveMinute = 0.obs;
  get haveMinute => _haveMinute.value;
  set haveMinute(v) => _haveMinute.value = v;

  late BottomPayPassword bottomPayPassword;

  payOrderAction() {
    if ((homeData["u_3rd_password"] == null ||
            homeData["u_3rd_password"].isEmpty) &&
        myData["paymentMethodType"] == 2) {
      showPayPwdWarn(
          haveClose: true,
          popToRoot: false,
          untilToRoot: false,
          setSuccess: () {});
      return;
    }
    if (myData["paymentMethodType"] == 1) {
      payAction("");
      // } else if (myData["paymentMethodType"] == 2) {
    } else {
      bottomPayPassword.show();
    }
  }

  payAction(String pwd) {
    String urls = "";
    urls = Urls.userPayGiftOrder(myData["id"]);
    simpleRequest(
      url: urls,
      params: {
        "orderId": myData["id"],
        "version_Origin": AppDefault().versionOriginForPay(),
        "u_3nd_Pad": pwd,
      },
      success: (success, json) async {
        if (myData["paymentMethod"] != null &&
            myData["paymentMethodType"] != null) {
          if (myData["paymentMethodType"] == 1) {
            if (myData["paymentMethod"] == 1) {
              if (json != null &&
                  json["data"] != null &&
                  json["data"]["aliData"] != null) {
                Map result = await CustomAlipay()
                    .payAction(json["data"]["aliData"], payBack: () {
                  alipayH5payBack(url: urls, params: {
                    "orderId": myData["id"],
                    "version_Origin": AppDefault().versionOriginForPay(),
                    "u_3nd_Pad": pwd
                  });
                });
                if (!kIsWeb) {
                  if (result["resultStatus"] == "6001") {
                  } else if (result["resultStatus"] == "9000") {
                    toPayResult(orderData: myData);
                  }
                }
              } else {
                ShowToast.normal("支付失败，请稍后再试");
                return;
              }
            }
          } else if (myData["paymentMethodType"] == 2) {
            if (success) {
              toPayResult(orderData: myData);
            }
          }
        }
      },
      after: () {},
    );
  }

  deleteOrderAction() {
    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要删除该订单吗",
      cancelOnPressed: () {
        Get.back();
      },
      confirmOnPressed: () {
        simpleRequest(
          url: Urls.userLevelGiftDelOrder(myData["id"]),
          params: {},
          success: (success, json) {
            if (success) {
              loadDetail();
              Get.find<ProductStoreOrderListController>().loadList();
              ShowToast.normal("删除成功");
              Future.delayed(const Duration(seconds: 1), () {
                Get.back();
              });
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  cancelOrderAction() {
    String urls = "";

    urls = Urls.userLevelGiftOrderCancel(myData["id"]);
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
              loadDetail();
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  confirmOrderAction() {
    String url = "";
    url = Urls.userLevelGiftOrderConfirm(myData["id"]);
    showAlert(
      Global.navigatorKey.currentContext!,
      "确定要确认收货吗",
      cancelOnPressed: () {
        Get.back();
      },
      confirmOnPressed: () {
        simpleRequest(
          url: url,
          params: {},
          success: (success, json) {
            if (success) {
              loadDetail();
            }
          },
          after: () {},
        );
        Get.back();
      },
    );
  }

  Map myData = {};

  dataInit(Map data, List statusList) {
    if (!isFirst) {
      return;
    }
    myData = data;
    if (statusList.isNotEmpty) {
      stateDataList = statusList;
    } else {
      // loadState();
    }
    // payCountDown();
    update();

    isFirst = false;
    loadDetail();
  }

  List stateDataList = [];
  loadState() {
    simpleRequest(
      url: Urls.getOrderStatusList,
      params: {},
      success: (success, json) {
        if (success) {
          stateDataList = json["data"];
          // update([timebuildId]);
        }
      },
      after: () {},
    );
  }

  CancelToken token = CancelToken();
  loadDetail({bool isPull = false}) {
    if (myData["id"] == null) {
      ShowToast.normal("订单信息错误，请前往个人中心查看订单");
      pullCtrl.refreshFailed();
      return;
    }
    String url = "";

    url = Urls.userLevelGiftOrderShow(myData["id"]);
    simpleRequest(
      url: url,
      params: {},
      cancelToken: token,
      success: (success, json) {
        if (success) {
          myData = json["data"] ?? {};

          update();
          if (isPull) {
            pullCtrl.refreshCompleted();
          }
        } else {
          if (isPull) {
            pullCtrl.refreshFailed();
          }
        }
      },
      after: () {},
    );
  }

  Map homeData = {};
  @override
  void onInit() {
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
    if (!token.isCancelled) {
      token.cancel();
    }
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    pullCtrl.dispose();
    super.onClose();
  }
}

class ProductStoreOrderDetail
    extends GetView<ProductStoreOrderDetailController> {
  final Map data;
  final List statusList;
  const ProductStoreOrderDetail(
      {Key? key, required this.data, this.statusList = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(data, statusList);
    return WillPopScope(
      onWillPop: () async {
        if (controller.timer != null) {
          controller.timer!.cancel();
          controller.timer = null;
        }
        return true;
      },
      child: Scaffold(
        appBar: getDefaultAppBar(context, "订单详情", backPressed: () {
          if (controller.timer != null) {
            // if (!controller.token.isCancelled) {
            //   controller.token.cancel();
            // }
            controller.timer!.cancel();
            controller.timer = null;
          }
          Get.back();
        }),
        body: GetBuilder<ProductStoreOrderDetailController>(
            init: controller,
            builder: (_) {
              bool isReal = true;
              String unit = "";
              int payType = controller.myData["paymentMethodType"] ?? 1;
              int payMethod = controller.myData["paymentMethod"] ?? 1;
              if (payType == 1) {
                isReal = true;
                unit = "元";
              } else if (payType == 2) {
                isReal = false;
                isReal = false;
                List walletList = AppDefault().homeData["u_Account"] ?? [];
                for (var e in walletList) {
                  if (payMethod == (e["a_No"] ?? 0)) {
                    unit = e["name"] ?? "";
                    break;
                  }
                }
              }
              return getInputBodyNoBtn(context,
                  contentColor: AppColor.pageBackgroundColor,
                  build: (boxHeight, context) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      GetBuilder<ProductStoreOrderDetailController>(
                        id: controller.timebuildId,
                        builder: (_) {
                          return topStatus();
                        },
                      ),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(8.w)),
                        child: Container(
                          width: 345.w,
                          // height: 100.w,
                          color: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  ghb(5),
                                  sbRow([
                                    centRow([
                                      getSimpleText(
                                          controller.myData["recipient"] ?? "",
                                          14,
                                          AppColor.textBlack,
                                          isBold: true),
                                      gwb(10),
                                      getSimpleText(
                                          controller
                                                  .myData["recipientMobile"] ??
                                              "",
                                          14,
                                          AppColor.textBlack,
                                          isBold: true),
                                    ])
                                  ], width: 305),
                                  ghb(8),
                                  getWidthText(
                                      controller.myData["userAddress"] ?? "",
                                      12,
                                      AppColor.textGrey,
                                      305,
                                      3),
                                  ghb(18)
                                ],
                              ),
                              Image.asset(
                                assetsName("common/line2"),
                                width: 345.w,
                                height: 2.w,
                                fit: BoxFit.fill,
                              ),
                            ],
                          ),
                        ),
                      ),
                      ghb(10),
                      GetBuilder<ProductStoreOrderDetailController>(
                        init: controller,
                        builder: (_) {
                          return Container(
                            width: 345.w,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.w)),
                            child: Column(
                              children: [
                                ghb(10),
                                sbRow([
                                  centRow([
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5.w),
                                      child: CustomNetworkImage(
                                        src:
                                            "${AppDefault().imageUrl}${controller.myData["levelGiftImg"] ?? ""}",
                                        width: 105.w,
                                        height: 105.w,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    gwb(11),
                                    sbClm([
                                      getWidthText(
                                          controller.myData["levelName"] ?? "",
                                          16,
                                          AppColor.textBlack,
                                          315 - 105 - 11,
                                          3,
                                          isBold: true),
                                      sbRow([
                                        getSimpleText(
                                            "${isReal ? "￥" : ""}${priceFormat(controller.myData["totalPrice"] ?? 0, savePoint: isReal ? 2 : 0)}${isReal ? "" : unit}",
                                            14,
                                            AppColor.textBlack),
                                        getSimpleText(
                                            "x${controller.myData["num"] ?? 1}",
                                            12,
                                            AppColor.textGrey),
                                      ], width: 193.5)
                                    ], height: 98),
                                  ]),
                                ], width: 345 - 15 * 2),
                                ghb(20),
                                gline(313, 0.5),
                                ghb(15),
                                sbRow([
                                  getSimpleText("商品总额", 14, AppColor.textGrey),
                                  getSimpleText(
                                    "${isReal ? "￥" : ""}${priceFormat(controller.myData["totalPrice"] ?? 0, savePoint: isReal ? 2 : 0)}${isReal ? "" : unit}",
                                    14,
                                    AppColor.color40,
                                  ),
                                ], width: 345 - 15 * 2),
                                ghb(15),
                                // sbRow([
                                //   getSimpleText("运费", 14, AppColor.textBlack),
                                //   getSimpleText(
                                //       controller.myData["rownum"] != 0
                                //           ? "${controller.myData["rownum"]}"
                                //           : "包邮",
                                //       14,
                                //       AppColor.color40,
                                //       ),
                                // ], width: 345 - 15 * 2),
                                // ghb(15),
                                sbRow([
                                  getSimpleText("总计", 14, AppColor.textGrey),
                                  getSimpleText(
                                      "${isReal ? "￥" : ""}${priceFormat(controller.myData["totalPrice"] ?? 0, savePoint: isReal ? 2 : 0)}${isReal ? "" : unit}",
                                      14,
                                      AppColor.textBlack,
                                      isBold: true),
                                ], width: 345 - 15 * 2),
                                ghb(20),
                                gline(315, 1),

                                ghb(20),

                                sbRow([
                                  centRow([
                                    getWidthText(
                                      "订单编号",
                                      14,
                                      const Color(0xFF8A9199),
                                      70,
                                      1,
                                    ),
                                    CustomButton(
                                      onPressed: () {
                                        copyClipboard(
                                            controller.myData["orderNo"] ?? "",
                                            toastText: "订单编号已复制");
                                      },
                                      child: centRow([
                                        getSimpleText(
                                          "${controller.myData["orderNo"] ?? ""}",
                                          14,
                                          AppColor.textBlack,
                                        ),
                                        gwb(3),
                                        Image.asset(
                                          assetsName(
                                              "mine/order/btn_orderno_copy"),
                                          width: 12.w,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      ]),
                                    )
                                  ])
                                ], width: 345 - 15 * 2),
                                ghb(11),
                                sbRow([
                                  centRow([
                                    getWidthText("创建时间", 14,
                                        const Color(0xFF8A9199), 70, 1),
                                    getSimpleText(
                                      "${controller.myData["addTime"] ?? ""}",
                                      14,
                                      AppColor.textBlack,
                                    ),
                                  ]),
                                ], width: 345 - 15 * 2),
                                ghb(11),
                                sbRow([
                                  centRow([
                                    getWidthText("订单状态", 14,
                                        const Color(0xFF8A9199), 70, 1),
                                    getSimpleText(
                                      "${controller.myData["orderStateStr"] ?? ""}",
                                      14,
                                      AppColor.textBlack,
                                    ),
                                  ]),
                                ], width: 345 - 15 * 2),
                                ghb(19),
                              ],
                            ),
                          );
                        },
                      ),
                      ghb(55.5)
                    ],
                  ),
                );
              },
                  submitBtn: haveBottom()
                      ? Container(
                          padding: EdgeInsets.only(
                              bottom: paddingSizeBottom(context)),
                          color: Colors.white,
                          width: 375.w,
                          height: 50.w + paddingSizeBottom(context),
                          child: Center(
                            child: sbRow([
                              gwb(0),
                              centRow([
                                ...statusButtons(controller.myData, context)
                              ])
                            ], width: 375 - 20 * 2),
                          ),
                        )
                      : null,
                  buttonHeight:
                      haveBottom() ? 50.w + paddingSizeBottom(context) : 0);
            }),
      ),
    );
  }

  bool haveBottom() {
    if (controller.myData == null || controller.myData["orderState"] == null) {
      return false;
    } else {
      if (controller.myData["orderState"] == 1 ||
          controller.myData["orderState"] == 6 ||
          controller.myData["orderState"] == 7 ||
          controller.myData["orderState"] == 8) {
        return false;
      } else {
        return true;
      }
    }
  }

  // controller.myData["orderState"] == 0
  //             ? Container()
  //             : controller.myData["orderState"] == 1
  //                 ? Container()
  //                 : Container()

  Widget topStatus() {
    bool timeOut = false;
    DateTime now = DateTime.now();
    String autoConfirmDay = "";
    String autoConfirmHour = "";
    if (controller.myData["orderState"] == 0) {
      // Duration duration = controller.dateFormat
      //     .parse(controller.myData["addTime"])
      //     .add(const Duration(minutes: 30))
      //     .difference(now);
      // timeOut = (duration.inMilliseconds < 0);
    } else if (controller.myData["orderState"] == 2) {
      Duration duration = controller.dateFormat
          .parse(controller.myData["addTime"])
          .add(const Duration(days: 7))
          .difference(now);
      autoConfirmDay = "${duration.inDays}";
      int hour = duration.inHours - duration.inDays * 24;
      autoConfirmHour = "$hour";
    }

    String orderStatusTitle = "";
    String orderStatusSubTitle = "";

    switch (controller.myData["orderState"]) {
      case 0:
        // orderStatusTitle = "等待支付订单";
        // orderStatusSubTitle =
        //     "请在${controller.minutes}分${controller.second}秒内完成支付";
        orderStatusTitle = "未支付订单";
        orderStatusSubTitle = "";
        break;
      case 1:
        orderStatusTitle = "已付款成功";
        orderStatusSubTitle = "请耐心等待发货，发货后可查询快递单号";
        break;
      case 2:
        orderStatusTitle = "已发货";
        orderStatusSubTitle = "还剩$autoConfirmDay天$autoConfirmHour小时自动确认收货";
        break;
      case 3:
        orderStatusTitle = "已完成";
        orderStatusSubTitle = "订单已确认收货";
        break;
      case 4:
        orderStatusTitle = "退货中";
        orderStatusSubTitle = "";
        break;
      case 5:
        orderStatusTitle = "退货完成";
        orderStatusSubTitle = "";
        break;
      case 6:
        orderStatusTitle = "支付超时";
        orderStatusSubTitle = "";
        break;
      case 7:
      case 8:
        orderStatusTitle = "已取消";
        orderStatusSubTitle = "";
        break;
      default:
    }

    return Container(
      height: 120.w,
      width: 375.w,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [
        Color(0xFFFD573B),
        Color(0xFFFF3A3A),
      ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: sbhRow([
              centRow(
                [
                  gwb(21),
                  centClm([
                    getWidthText(
                        orderStatusTitle, 18, Colors.white, 375 - 21 - 10, 1,
                        isBold: true),
                    ghb(9),
                    getWidthText(orderStatusSubTitle, 12, Colors.white,
                        375 - 21 - 10, 5),
                  ], crossAxisAlignment: CrossAxisAlignment.start),
                ],
              ),
            ], width: 375 - 5 * 2, height: 100),
          ),
          Positioned(
              left: 15.w,
              right: 15.w,
              height: 20.w,
              bottom: -1.w,
              child: Container(
                height: 21.w,
                width: 345.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8.w))),
              ))
        ],
      ),
    );
  }

  showExpressNoModel(BuildContext context, String expressNo) {
    showGeneralDialog(
        context: context,
        pageBuilder: (ctx, animation, secondaryAnimation) {
          return Align(
              child: SizedBox(
                  width: 345.w,
                  height: 165.w,
                  child: Column(children: [
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                      },
                      child: Icon(
                        Icons.highlight_off,
                        size: 36.w,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      width: 1.5.w,
                      height: 19.w,
                      color: Colors.white,
                    ),
                    Container(
                        width: 345.w,
                        height: 110.w,
                        decoration: BoxDecoration(
                            color: AppColor.lineColor,
                            borderRadius: BorderRadius.circular(5.w)),
                        child: Column(children: [
                          ghb(25),
                          getSimpleText("点击快递编号即可复制查询", 15, AppColor.textBlack,
                              isBold: true),
                          ghb(13.5),
                          CustomButton(
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: expressNo));
                                ShowToast.normal("已复制");
                              },
                              child: Container(
                                  width: 270.w,
                                  height: 35.w,
                                  decoration: getDefaultWhiteDec(),
                                  child: Center(
                                      child: getSimpleText(
                                          expressNo, 20, AppColor.textBlack,
                                          isBold: true))))
                        ]))
                  ])));
        });
  }

  List<Widget> statusButtons(
    Map data,
    BuildContext context,
  ) {
    List<Widget> l = [];
    // if (controller.stateDataList.isEmpty) {
    //   return l;
    // }

    if (data["orderState"] == 0) {
      // bool timeOut = false;
      // DateTime now = DateTime.now();
      // Duration duration = controller.dateFormat
      //     .parse(data["addTime"])
      //     .add(const Duration(minutes: 30))
      //     .difference(now);
      // timeOut = (duration.inMilliseconds < 0);
      l.addAll([
        // statusButton(
        //   "取消订单",
        //   const Color(0xFF7B8A99),
        //   const Color(0xFF8A9199),
        //   onPressed: () {
        //     controller.cancelOrderAction();
        //   },
        // ),
        statusButton("删除订单", AppColor.textBlack, const Color(0xFFB3B3B3),
            onPressed: () {
          controller.deleteOrderAction();
          // controller.checkLogisticsAction(index, status);
        }),
        // gwb(timeOut ? 0 : 13.5),
        // timeOut
        //     ? gwb(0)
        //     : statusButton(
        //         "立即支付",
        //         AppColor.theme,
        //         AppColor.theme,
        //         bgColor: Colors.white,
        //         onPressed: () {
        //           controller.payOrderAction();
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
        //     controller.checkLogisticsAction();
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
        //     controller.confirmOrderAction();
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
            controller.confirmOrderAction();
          },
        ),
      ]);
    } else if ((data["orderState"] == 3 ||
            data["orderState"] == 4 ||
            data["orderState"] == 5) ||
        data["courierNo"] != null && data["courierNo"].isNotEmpty) {
      l.addAll([
        // statusButton(
        //   "删除订单",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction();
        //   },
        // ),
        // gwb(13.5),
        statusButton(
          "查看物流",
          const Color(0xFF7B8A99),
          const Color(0xFF8A9199),
          onPressed: () {
            // controller.confirmOrderAction();
            if (data["courierNo"] != null) {
              showExpressNoModel(context, data["courierNo"] ?? "");
            } else {
              ShowToast.normal("暂无物流信息，请稍后再试");
            }
          },
        ),
      ]);
    } else if (data["orderState"] == 6 ||
        data["orderState"] == 7 ||
        data["orderState"] == 8) {
      l.addAll([
        // statusButton(
        //   "删除订单",
        //   AppColor.textBlack,
        //   const Color(0xFFB3B3B3),
        //   onPressed: () {
        //     controller.checkLogisticsAction();
        //   },
        // ),
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
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4.w),
            border: Border.all(width: 0.5.w, color: borderColor)),
        child: Center(
          child: getSimpleText(t1, 12, textColor),
        ),
      ),
    );
  }
}
