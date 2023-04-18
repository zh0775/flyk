import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class IntegralRepurchaserderDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IntegralRepurchaserderDetailController>(
        IntegralRepurchaserderDetailController(datas: Get.arguments));
  }
}

class IntegralRepurchaserderDetailController extends GetxController {
  final dynamic datas;
  IntegralRepurchaserderDetailController({this.datas});

  Map orderData = {};

  @override
  void onInit() {
    orderData = (datas ?? {})["data"] ?? {};
    super.onInit();
  }
}

class IntegralRepurchaserderDetail
    extends GetView<IntegralRepurchaserderDetailController> {
  const IntegralRepurchaserderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "复购订单详情"),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              ghb(15),
              Container(
                width: 345.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  children: [
                    gwb(345),
                    ghb(15),
                    Container(
                      width: 315.w,
                      height: 75.w,
                      decoration: BoxDecoration(
                          color: AppColor.pageBackgroundColor,
                          borderRadius: BorderRadius.circular(4.w)),
                      child: Center(
                        child: sbRow([
                          CustomNetworkImage(
                            src: AppDefault().imageUrl +
                                (controller.orderData["images"] ?? ""),
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
                                getWidthText(
                                    controller.orderData["title"] ?? "",
                                    12,
                                    AppColor.text,
                                    315 - 20 - 60 - 10,
                                    2),
                                sbRow([
                                  getSimpleText(
                                      "￥${priceFormat(controller.orderData["price2"] ?? 0)}",
                                      12,
                                      AppColor.text3),
                                  // getSimpleText(
                                  //     "x${data["num"] ?? 1}", 12, AppColor.text3),
                                ], width: 315 - 20 - 60 - 10)
                              ],
                            ),
                          )
                        ], width: 315 - 10 * 2),
                      ),
                    ),
                    ghb(30),
                    infoCell("订单编号", controller.orderData["order_No"] ?? ""),
                    infoCell("订单状态", controller.orderData["managedStr"] ?? ""),
                    infoCell("支付方式", "支付宝"),
                    infoCell("商品名称", controller.orderData["title"] ?? ""),
                    infoCell("付款金额",
                        "￥${priceFormat(controller.orderData["price2"] ?? 0)}"),
                    infoCell("兑换时间", controller.orderData["addTime"] ?? ""),
                    ghb(20)
                  ],
                ),
              )
            ],
          )),
    );
  }

  Widget infoCell(String t1, String t2,
      {double width = 70, double height = 28}) {
    return SizedBox(
      height: height.w,
      width: 315.w,
      child: Center(
          child: Row(
        children: [
          getWidthText(t1, 14, AppColor.text3, width, 1, textHeight: 1.3),
          gwb(4.5),
          getWidthText(t2, 14, AppColor.text2, 315 - 14.5 * 2 - width - 0.1, 1,
              textHeight: 1.3),
        ],
      )),
    );
  }
}
