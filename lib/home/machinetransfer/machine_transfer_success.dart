import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_history.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum MachineTransferSuccessType {
  receiveSuccess,
  transferSuccess,
}

class MachineTransferSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferSuccessController>(
        MachineTransferSuccessController());
  }
}

class MachineTransferSuccessController extends GetxController {
  bool isFirst = true;
  MachineTransferSuccessType? myType;

  String successTitle = "";
  String subSuccessTitle = "";
  bool isLock = false;

  dataInit(MachineTransferSuccessType type, bool lock) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    myType = type;
    isLock = lock;
    switch (myType) {
      case MachineTransferSuccessType.receiveSuccess:
        successTitle = "接收成功";
        subSuccessTitle = "对方向您划拨的机具，已入库";
        break;
      case MachineTransferSuccessType.transferSuccess:
        successTitle = "划拨完成";
        subSuccessTitle = isLock ? "已发送订单给对方，等待对方接收" : "已将设备划拨给对方";
        break;
      default:
    }
  }

  @override
  void onInit() {
    super.onInit();
  }
}

class MachineTransferSuccess extends GetView<MachineTransferSuccessController> {
  final MachineTransferSuccessType? successType;
  final bool isLock;
  const MachineTransferSuccess(
      {Key? key,
      this.successType = MachineTransferSuccessType.transferSuccess,
      this.isLock = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(successType!, isLock);

    return Scaffold(
        appBar: getDefaultAppBar(
          context,
          "划拨结果",
          backPressed: () {
            Get.offUntil(
                GetPageRoute(
                    page: () => const MachineTransfer(),
                    binding: MachineTransferBinding(),
                    settings: const RouteSettings(name: "MachineTransfer")),
                (route) => route is GetPageRoute
                    ? route.binding is MainPageBinding
                        ? true
                        : false
                    : false);
          },
        ),
        backgroundColor: AppColor.pageBackgroundColor,
        body: SingleChildScrollView(
            child: Column(children: [
          gwb(375),
          ghb(130),
          Image.asset(
            assetsName("home/machinetransfer/bg_hb_success"),
            width: 129.w,
            height: 137.w,
            fit: BoxFit.fill,
          ),
          ghb(25),
          getSimpleText("划拨成功", 22, AppColor.textBlack, isBold: true),
          ghb(45),
          getSubmitBtn("继续划拨", () {
            Get.offUntil(
                GetPageRoute(
                    page: () => const MachineTransfer(),
                    binding: MachineTransferBinding(),
                    settings: const RouteSettings(name: "MachineTransfer")),
                (route) => route is GetPageRoute
                    ? route.binding is MainPageBinding
                        ? true
                        : false
                    : false);
          },
              color: AppColor.theme,
              height: 45,
              width: 300,
              fontSize: 15,
              textColor: Colors.white),
          CustomButton(
              onPressed: () {
                Get.offUntil(
                    GetPageRoute(
                        page: () => const MachineTransferHistory(),
                        binding: MachineTransferHistoryBinding(),
                        settings: const RouteSettings(
                            name: "MachineTransferHistory")),
                    (route) => route is GetPageRoute
                        ? route.binding is MainPageBinding
                            ? true
                            : false
                        : false);
              },
              child: Container(
                  margin: EdgeInsets.only(top: 15.w),
                  width: 300.w,
                  height: 45.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(45.w / 2),
                      border: Border.all(width: 0.5.w, color: AppColor.theme)),
                  child: getSimpleText("查看记录", 15, AppColor.theme)))
        ])));
  }
}
