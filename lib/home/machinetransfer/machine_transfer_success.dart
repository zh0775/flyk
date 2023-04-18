import 'package:cxhighversion2/app_binding.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_history.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_list.dart';
import 'package:cxhighversion2/home/my_machine.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';

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
      backgroundColor: AppColor.pageBackgroundColor,
      body: Stack(
        children: [
          Positioned(
              top: paddingSizeTop(context),
              left: 0,
              height: kToolbarHeight,
              child: defaultBackButton(
                context,
                backPressed: () {
                  popToUntil();
                },
              )),
          Positioned(
              left: 0,
              right: 0,
              top: paddingSizeTop(context) + kToolbarHeight + 80,
              height: 252.w,
              child: Column(
                children: [
                  Image.asset(
                    assetsName("home/machinetransfer/bg_hb_success"),
                    width: 169.w,
                    height: 60.w,
                    fit: BoxFit.fill,
                  ),
                  ghb(40),
                  getSimpleText(controller.successTitle, 22, AppColor.textBlack,
                      isBold: true),
                  ghb(15),
                  getSimpleText(
                      controller.subSuccessTitle, 14, AppColor.textGrey),
                ],
              )),
          Positioned(
              bottom: 85.w + paddingSizeBottom(context),
              left: 0,
              right: 0,
              height: 107.5.w,
              child: Column(
                children: [
                  // controller.myType ==
                  //             MachineTransferSuccessType.receiveSuccess ||
                  //         !isLock
                  //     ?

                  //     getSubmitBtn("查看我的机具", () {
                  //         Get.offUntil(
                  //             GetPageRoute(
                  //               page: () => const MyMachine(),
                  //               binding: MyMachineBinding(),
                  //             ), (route) {
                  //           if ((route as GetPageRoute).binding is AppBinding) {
                  //             return true;
                  //           }
                  //           return false;
                  //         });
                  //       })
                  //     :
                  // getSubmitBtn("立即去发货", () {
                  //     Get.find<MachineTransferController>().resetData();
                  //     Get.offUntil(
                  //         GetPageRoute(
                  //           page: () => const MachineTransferOrderList(),
                  //           binding: MachineTransferOrderListBinding(),
                  //         ), (route) {
                  //       if (route is GetPageRoute) {
                  //         if (route.binding is MachineTransferBinding) {
                  //           return true;
                  //         } else {
                  //           return false;
                  //         }
                  //       } else {
                  //         return false;
                  //       }
                  //     });
                  //   }),
                  getSubmitBtn("查看订单", () {
                    Get.find<MachineTransferController>().resetData();
                    Get.offUntil(
                        GetPageRoute(
                          page: () => const MachineTransferHistory(
                              // defaultIndex: 1,
                              ),
                          binding: MachineTransferHistoryBinding(),
                        )
                        // GetPageRoute(
                        //   page: () => const MachineTransferOrderList(
                        //       // defaultIndex: 1,
                        //       ),
                        //   binding: MachineTransferOrderListBinding(),
                        // )
                        , (route) {
                      if (route is GetPageRoute) {
                        if (route.binding is MachineTransferBinding) {
                          return true;
                        } else {
                          return false;
                        }
                      } else {
                        return false;
                      }
                    });
                  }),
                  ghb(7.5),
                  controller.myType == MachineTransferSuccessType.receiveSuccess
                      ? CustomButton(
                          onPressed: () {
                            Get.until((route) {
                              if ((route as GetPageRoute).binding
                                  is MainPageBinding) {
                                return true;
                              }
                              return false;
                            });
                          },
                          child: Container(
                            width: 345.w,
                            height: 50.w,
                            decoration: getDefaultWhiteDec(),
                            child: Center(
                              child: getSimpleText(
                                  "返回首页", 15, AppColor.textBlack,
                                  isBold: true),
                            ),
                          ),
                        )
                      : ghb(50)
                ],
              )),
        ],
      ),
    );
  }
}
