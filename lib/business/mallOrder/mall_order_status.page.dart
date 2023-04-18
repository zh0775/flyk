// 积分商城 下单成功后到订单状态页面

import 'dart:async';

import 'package:cxhighversion2/business/afterSale/after_sale_page.dart';
import 'package:cxhighversion2/business/mallOrder/after_sale/mall_order_aftersale.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MallOrderStatusPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MallOrderStatusPageController>(
        MallOrderStatusPageController(datas: Get.arguments));
  }
}

class MallOrderStatusPageController extends GetxController {
  final dynamic datas;
  MallOrderStatusPageController({this.datas});

  final _isLoading = true.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(v) => _isLoading.value = v;

  final _haveBtn = false.obs;
  bool get haveBtn => _haveBtn.value;
  set haveBtn(v) => _haveBtn.value = v;

  Timer? timer;
  String timebuildId = "MineStoreOrderDetail_timebuildId";
  String minutes = "30";
  String second = "00";
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  int status = -1;
  late DateTime addDateTime;
  void payCountDown() {
    if (orderData.isEmpty ||
        orderData["addTime"] == null ||
        orderData["addTime"].isEmpty ||
        orderData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
      }
      return;
    }
    DateTime now = DateTime.now();
    addDateTime =
        dateFormat.parse(orderData["addTime"]).add(const Duration(minutes: 30));
    Duration duration = addDateTime.difference(now);

    if (duration.inMilliseconds < 0 || orderData["orderState"] != 0) {
      if (timer != null) {
        timer?.cancel();
        timer = null;
        loadDetail();
      }
    } else {
      timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        DateTime currentTime = DateTime.now();
        Duration d = addDateTime.difference(currentTime);
        if (d.inMilliseconds < 0 || orderData["orderState"] != 0) {
          timer?.cancel();
          timer = null;
          // loadDetail();
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

  // loadPay(String pwd) {
  //   simpleRequest(url: Urls.userPayOrder(id), params: params, success: success, after: after)
  // }

  toPayAction() {}
  cancelAction() {
    simpleRequest(
      url: Urls.userConfirmCancel,
      params: {"id": orderData["id"]},
      success: (success, json) {
        if (success) {
          loadDetail();
        }
      },
      after: () {},
    );
  }

  deletelAction() {
    simpleRequest(
      url: Urls.userDelOrder(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadDetail();
        }
      },
      after: () {},
    );
  }

  confirmAction() {
    simpleRequest(
      url: Urls.userOrderConfirm(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          loadDetail();
        }
      },
      after: () {},
    );
  }

  // Map mData = {};
  Map orderData = {};
  CancelToken token = CancelToken();
  loadDetail() {
    isLoading = true;
    simpleRequest(
      url: Urls.userOrderShow(orderData["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          orderData = json["data"] ?? {};
          status = orderData["orderState"] ?? -1;
          payCountDown();
          update();
          update([timebuildId]);
          if (status == 1 || status == 3) {
            haveBtn = false;
          } else {
            haveBtn = true;
          }
        }
      },
      after: () {
        isLoading = false;
      },
      cancelToken: token,
    );
  }

  @override
  void onInit() {
    if (datas != null) {
      orderData = datas["data"] ?? {};
      status = orderData["orderState"] ?? -1;
    }
    payCountDown();
    loadDetail();

    // /api/Order/User_OrderShow/{id}
    super.onInit();
  }

  @override
  void onClose() {
    if (!token.isCancelled) {
      token.cancel();
    }
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    super.onClose();
  }
}

class MallOrderStatusPage extends GetView<MallOrderStatusPageController> {
  const MallOrderStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, '订单详情'),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              child: orderStatusTopBox(),
            ),
            Positioned(
              top: 100.w - 15.w, // 下面的margin引起的
              bottom: 50.w,
              child: addressDefaultBox(),
            ),

            GetX<MallOrderStatusPageController>(
              builder: (controller) {
                return Positioned(
                  left: 15.w,
                  top: 220.w, // 下面的margin引起的
                  bottom: controller.haveBtn ? 50.w : 0,
                  child: GetBuilder<MallOrderStatusPageController>(
                    builder: (controller) {
                      return shopOrderBox();
                    },
                  ),
                );
              },
            ),

            GetX<MallOrderStatusPageController>(builder: (_) {
              return controller.haveBtn
                  ? Positioned(bottom: 0, child: orderStatusBottom())
                  : gemp();
            })
            // Positioned(child: shopOrderBox())
          ],
        ),
      ),
    );
  }

  // 订单发货状态类型
  Widget orderStatusTopBox() {
    return Container(
      width: 375.w,
      height: 120.w,
      color: const Color(0xFFFF6231),
      padding: EdgeInsets.only(bottom: 10.w),
      child: GetBuilder<MallOrderStatusPageController>(
        id: controller.timebuildId,
        builder: (_) {
          String orderStatusTitle = "";
          String orderStatusSubTitle = "";
          Duration duration = controller.dateFormat
              .parse(controller.orderData["addTime"])
              .add(const Duration(days: 7))
              .difference(DateTime.now());
          String autoConfirmDay = "${duration.inDays}";
          int hour = duration.inHours - duration.inDays * 24;
          String autoConfirmHour = "$hour";
          switch (controller.status) {
            case 0:
              orderStatusTitle = "等待支付订单";
              orderStatusSubTitle =
                  "请在${controller.minutes}分${controller.second}秒内完成支付";
              break;
            case 1:
              orderStatusTitle = "已付款成功";
              orderStatusSubTitle = "请耐心等待发货";
              break;
            case 2:
              orderStatusTitle = "已发货";
              orderStatusSubTitle =
                  "还剩$autoConfirmDay天$autoConfirmHour小时自动确认收货\n物流公司：${controller.orderData["logisticsName"] ?? ""}\n物流单号：${controller.orderData["courierNo"] ?? ""}";
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
          return Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getWidthText(orderStatusTitle, 18, Colors.white, 375 - 30 * 2, 2),
              CustomButton(
                onPressed: () {
                  if (controller.status == 2) {
                    copyClipboard(controller.orderData["courierNo"] ?? "",
                        toastText: "已复制物流单号");
                  }
                },
                child: getWidthText(
                  orderStatusSubTitle,
                  12,
                  Colors.white,
                  375 - 30 * 2,
                  10,
                ),
              ),
              // getSimpleText(orderStatusTitle, 18, Colors.white),
              // getSimpleText(orderStatusSubTitle, 12, Colors.white),
            ],
          );
        },
      ),
    );
  }

  Widget addressDefaultBox() {
    return Container(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 375.w - 15.w * 2,
                height: 120.w,
                margin: EdgeInsets.all(15.w),
                padding: EdgeInsets.only(left: 18.5.w, top: 24.w),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.0.w),
                      topRight: Radius.circular(8.0.w),
                    )),
                child: SizedBox(
                  child:
                      GetBuilder<MallOrderStatusPageController>(builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Container(
                            //   padding: EdgeInsets.only(left: 5.w, right: 5.w),
                            //   decoration: BoxDecoration(
                            //     color: const Color(0xFFFF6231),
                            //     borderRadius: BorderRadius.circular(2.w),
                            //   ),
                            //   child: getSimpleText("默认", 12, Colors.white),
                            // ),
                            // gwb(10.5),
                            getSimpleText(
                                controller.orderData["recipient"] ?? "",
                                15,
                                const Color(0xFF000000)),
                            gwb(14.5),
                            getSimpleText(
                                controller.orderData["recipientMobile"] ?? "",
                                15,
                                const Color(0xFF000000)),
                          ],
                        ),
                        ghb(15.w),
                        SizedBox(
                          width: 242.w,
                          child: Text(
                            controller.orderData["userAddress"] ?? "",
                            style: TextStyle(
                                color: const Color(0xFF999999),
                                fontSize: 12.w,
                                height: 1.5),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
              Positioned(
                top: 133.w,
                left: 15.w,
                width: 345.w,
                height: 3.w,
                child: Image.asset(
                  assetsName("business/address_line"),
                  width: 345.w,
                  height: 3.w,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
          // SingleChildScrollView(
          //   child: shopOrderBox(),
          // ),
        ],
      ),
    );
  }

  Widget shopOrderBox() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        width: 345.w,
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.w),
        ),
        margin: EdgeInsets.only(top: 15.w, bottom: 38.w),
        child: Column(
          children: [
            ...List.generate((controller.orderData["commodity"] ?? []).length,
                (index) {
              return Padding(
                  padding: EdgeInsets.only(top: index != 0 ? 10.w : 0),
                  child: shopItem(
                      (controller.orderData["commodity"] ?? [])[index]));
            }),
            ghb(25.w),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getWidthText("留言", 14, AppColor.textGrey5, 50, 1),
                getWidthText("", 14, AppColor.text3, 315 - 50, 3),

                // CustomInput(
                //   placeholder: '留言50字以内）',
                //   width: 345 - 15 * 2 - 30,
                //   heigth: 40,
                //   maxLines: 2,
                //   maxLength: 50,
                //   placeholderStyle: TextStyle(
                //       fontSize: 14.sp,
                //       color: AppColor.assisText,
                //       height: 1.3),
                //   style: TextStyle(
                //       fontSize: 14.sp, color: AppColor.text2, height: 1.3),
                // )
              ],
            ),
            ghb(15),
            gline(345 - 15 * 2, 1),
            ghb(11),
            Column(
              children: [
                SizedBox(
                  height: 30.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      nSimpleText('商品总价', 14, color: const Color(0xFF999999)),
                      nSimpleText(
                          '${priceFormat(controller.orderData["totalPrice"] ?? 0, savePoint: 0)}积分',
                          14,
                          color: const Color(0xFF999999)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      nSimpleText('运费', 14, color: const Color(0xFF999999)),
                      nSimpleText(
                          (controller.orderData["freightAmount"] ?? 0) <= 0
                              ? "包邮"
                              : '${priceFormat(controller.orderData["freightAmount"] ?? 0, savePoint: 0)}积分',
                          14,
                          color: const Color(0xFF999999)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      nSimpleText('总计', 14, color: const Color(0xFF999999)),
                      nSimpleText(
                          '${priceFormat(controller.orderData["totalPrice"] ?? 0, savePoint: 0)}积分',
                          15,
                          color: const Color(0xFF333333)),
                    ],
                  ),
                ),
                ghb(10),
              ],
            ),
            gline(345 - 15 * 2, 1),
            ghb(11),
            Column(
              children: [
                SizedBox(
                  height: 30.w,
                  child: Row(
                    children: [
                      nSimpleText('订单编号', 14, color: const Color(0xFF999999)),
                      gwb(14.5),
                      nSimpleText(controller.orderData["orderNo"] ?? "", 14,
                          color: const Color(0xFF333333)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.w,
                  child: Row(
                    children: [
                      nSimpleText('兑换时间', 14, color: const Color(0xFF999999)),
                      gwb(14.5),
                      nSimpleText(controller.orderData["addTime"] ?? "", 14,
                          color: const Color(0xFF333333)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30.w,
                  child: Row(
                    children: [
                      nSimpleText('订单状态', 14, color: const Color(0xFF999999)),
                      gwb(14.5),
                      nSimpleText(
                          controller.orderData["orderStateStr"] ?? "", 15,
                          color: const Color(0xFF333333)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget shopItem(Map data) {
    return SizedBox(
      width: 345.w,
      // height: 105.w,
      // padding: EdgeInsets.fromLTRB(10.w, 7.5.w, 10.w, 7.5.w),
      child: Column(
        children: [
          sbRow([
            CustomNetworkImage(
              src: AppDefault().imageUrl + (data["shopImg"] ?? ""),
              width: 105.w,
              height: 105.w,
              fit: BoxFit.cover,
            ),
            gwb(15),
            SizedBox(
              width: 345.w - 105.w - 15.w * 2 - 15.w,
              height: 105.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data["shopName"] ?? "",
                    style: TextStyle(
                      fontSize: 15.w,
                      color: AppColor.textBlack,
                    ),
                    maxLines: 2,
                  ),
                  getSimpleText("已选：${data["shopModel"] ?? ""}", 12,
                      const Color(0xFF999999)),
                  sbRow([
                    getSimpleText(
                        "${priceFormat(data["nowPrice"] ?? 0, savePoint: 0)}积分",
                        15,
                        const Color(0xFF333333)),
                    getSimpleText(
                        "X${data["num"] ?? 1}", 12, const Color(0xFF999999)),
                  ]),
                ],
              ),
            ),
          ]),
          controller.status == 1 ||
                  controller.status == 2 ||
                  controller.status == 3
              ? sbhRow([
                  gwb(0),
                  CustomButton(
                    onPressed: () {
                      // push(AfterSalePage(), null,
                      //     binding: AfterSalePageBinding());
                      push(
                          MallOrderAftersale(
                            orderData: controller.orderData,
                            product: data,
                          ),
                          Global.navigatorKey.currentContext!);
                    },
                    child: Container(
                      width: 65.w,
                      height: 25.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.w),
                          border: Border.all(
                              width: 0.5.w, color: AppColor.textGrey5)),
                      child: getSimpleText("申请售后", 12, AppColor.textBlack),
                    ),
                  )
                ], width: 345, height: 40)
              : ghb(0),
        ],
      ),
    );
  }

  Widget orderStatusBottom() {
    return Container(
      width: 375.w,
      height: 50.w + paddingSizeBottom(Global.navigatorKey.currentContext!),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(
          width: 1.0.w,
          color: Colors.white,
        )),
        boxShadow: [
          BoxShadow(
              color: Colors.white,
              offset: Offset.zero,
              blurRadius: 2.w,
              spreadRadius: 2.w,
              blurStyle: BlurStyle.solid)
        ],
      ),
      padding: EdgeInsets.only(top: 6.w, left: 8.w, bottom: 6.w, right: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [buttons(controller.orderData)],
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
            controller.cancelAction();
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
            controller.confirmAction();
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
