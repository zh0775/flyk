import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_detail.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MachineTransferExpressDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferExpressDetailController>(
        MachineTransferExpressDetailController());
  }
}

class MachineTransferExpressDetailController extends GetxController {
  Map publicHomeData = {};

  changeStatusAction(int id) {
    simpleRequest(
      url: Urls.userTerminalTransferStatus(id, 2),
      params: {},
      success: (success, json) {
        if (success) {
          Get.find<MachineTransferOrderDetailController>().loadDetail();
          ShowToast.normal("确认收货成功");
          Future.delayed(const Duration(seconds: 1), () {
            Get.back();
          });
        }
      },
      after: () {},
    );
  }

  @override
  void onInit() {
    publicHomeData = AppDefault().publicHomeData;
    super.onInit();
  }
}

class MachineTransferExpressDetail
    extends GetView<MachineTransferExpressDetailController> {
  final Map orderData;
  final int type;
  const MachineTransferExpressDetail(
      {Key? key, this.orderData = const {}, this.type = 1})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.pageBackgroundColor,
      appBar: getDefaultAppBar(context, "订单详情"),
      body: Stack(
        children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 80.w + paddingSizeBottom(context),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ghb(40),
                    getSimpleText("您兑换的机具，伙伴已发货", 18, AppColor.textBlack,
                        isBold: true),
                    ghb(15),
                    getSimpleText(
                        "可复制快递单号进行查询，未收到货前请勿确认收货", 12, AppColor.textGrey),
                    ghb(26),
                    sbRow([
                      CustomButton(
                        onPressed: () {
                          callPhone(controller.publicHomeData["webSiteInfo"]
                              ["System_ServiceHotline"]);
                        },
                        child: centClm([
                          Image.asset(
                            assetsName("home/machinetransfer/btn_contact_kf"),
                            width: 105.w,
                            height: 105.w,
                            fit: BoxFit.fill,
                          ),
                          ghb(5),
                          getSimpleText("联系客服", 14, AppColor.textBlack),
                        ]),
                      ),
                      CustomButton(
                        onPressed: () {
                          if (type == 0) {
                            callPhone(orderData["fuMobile"] ?? "");
                          } else if (type == 1) {
                            callPhone(orderData["suMobile"] ?? "");
                          }
                        },
                        child: centClm([
                          Image.asset(
                            assetsName("home/machinetransfer/btn_contact_hb"),
                            width: 105.w,
                            height: 105.w,
                            fit: BoxFit.fill,
                          ),
                          ghb(5),
                          getSimpleText("联系伙伴", 14, AppColor.textBlack),
                        ]),
                      ),
                    ], width: 375 - 62 * 2),
                    ghb(40),
                    getSimpleText("快递单号", 18, AppColor.textBlack, isBold: true),
                    ghb(12),
                    CustomButton(
                      onPressed: () {
                        Clipboard.setData(
                            ClipboardData(text: orderData["courierNo"] ?? ""));
                        ShowToast.normal("已复制");
                      },
                      child: Container(
                        width: 343.w,
                        height: 45.w,
                        decoration: getDefaultWhiteDec(),
                        child: Center(
                          child: getSimpleText(orderData["courierNo"] ?? "", 16,
                              AppColor.textBlack,
                              isBold: true),
                        ),
                      ),
                    ),
                    ghb(5),
                    getSimpleText("点击白色处可复制", 12, AppColor.textGrey)
                  ],
                ),
              )),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 80.w + paddingSizeBottom(context),
              child: Container(
                padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
                color: Colors.white,
                child: Center(
                  child: getSubmitBtn("确定收货", () {
                    showAlert(
                      context,
                      "是否确认收货",
                      confirmOnPressed: () {
                        controller.changeStatusAction(orderData["id"]);
                        Get.back();
                      },
                    );
                  }),
                ),
              ))
        ],
      ),
    );
  }
}
