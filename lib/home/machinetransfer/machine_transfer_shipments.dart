import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/home/machinetransfer/machine_transfer_order_detail.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_screenutil/src/size_extension.dart';
import 'package:get/get.dart';

class MachineTransferShipmentsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachineTransferShipmentsController>(
        MachineTransferShipmentsController());
  }
}

class MachineTransferShipmentsController extends GetxController {
  TextEditingController dhInputCtrl = TextEditingController();

  bool isFirst = true;
  Map orderData = {};

  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) {
    _address.value = v;
    update();
  }

  final _addressType = 0.obs;
  int get addressType => _addressType.value;
  set addressType(v) {
    _addressType.value = v;
    if (addressType == 0) {
      _address.value = addressLocation;
    } else if (addressType == 1) {
      _address.value = branchLocation;
    }
    update();
  }

  dataInit(Map data) {
    if (!isFirst) {
      return;
    }
    isFirst = true;
    orderData = data;
  }

  Map addressLocation = {};
  Map branchLocation = {};
  selectAddress(Map data) {
    if (addressType == 0) {
      addressLocation = data;
      address = addressLocation;
    } else if (addressType == 1) {
      branchLocation = data;
      address = branchLocation;
    }
  }

  sendPkgAction() {
    if (addressType == 0 && dhInputCtrl.text.isEmpty) {
      ShowToast.normal("选择快递送货时，快递单号不能为空");
      return;
    }
    simpleRequest(
      url: Urls.userTerminalTransferSend,
      params: {
        "id": orderData["id"],
        "contactType": addressType + 1,
        "contactId": address["id"],
        "expressNo": dhInputCtrl.text,
      },
      success: (success, json) {
        if (success) {
          ShowToast.normal("发货成功");
          Get.find<MachineTransferOrderDetailController>().loadDetail();
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
    simpleRequest(
        url: Urls.userContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List aList = json["data"];
            if (aList.isNotEmpty) {
              if (aList.length == 1) {
                addressLocation = aList[0];
              } else {
                for (var item in aList) {
                  if (item["isDefault"] == 1) {
                    addressLocation = item;
                    break;
                  }
                }
              }
              if (address.isEmpty) {
                addressLocation = aList[0];
              }
            }
            if (addressType == 0) {
              address = addressLocation;
            }
          }
        },
        after: () {});

    simpleRequest(
        url: Urls.userNetworkContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List bList = json["data"];
            if (bList.isNotEmpty) {
              branchLocation = bList[0];
            }
            if (addressType == 1) {
              address = branchLocation;
            }
          }
        },
        after: () {});
    super.onInit();
  }

  @override
  void dispose() {
    dhInputCtrl.dispose();
    super.dispose();
  }
}

class MachineTransferShipments
    extends GetView<MachineTransferShipmentsController> {
  final Map orderData;
  const MachineTransferShipments({Key? key, this.orderData = const {}})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(orderData);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
          backgroundColor: AppColor.pageBackgroundColor,
          appBar: getDefaultAppBar(context, "立即发货"),
          body: getInputSubmitBody(context, "确定", onPressed: () {
            controller.sendPkgAction();
          }, children: [
            ghb(20),
            sbRow([
              getSimpleText(
                  "${orderData["suName"] ?? ""}${orderData["fuMobile"] != null ? "(${orderData["fuMobile"]})" : ""}收货地址",
                  16,
                  AppColor.textBlack,
                  isBold: true),
            ], width: 375 - 34.5 * 2),
            ghb(10),
            Container(
              width: 345.w,
              decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(5.w))),
              child: GetX<MachineTransferShipmentsController>(
                init: controller,
                initState: (_) {},
                builder: (_) {
                  return Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                            3,
                            (index) => CustomButton(
                                  onPressed: () {
                                    controller.addressType = index;
                                  },
                                  child: SizedBox(
                                    width: (345 / 3).w - 12.w,
                                    height: 50.w,
                                    child: Center(
                                      child: centRow([
                                        getSimpleText(
                                            index == 0
                                                ? "快递送货"
                                                : index == 1
                                                    ? "网点自提"
                                                    : "当面提货",
                                            16,
                                            AppColor.textBlack,
                                            isBold: true),
                                        gwb(4),
                                        Icon(
                                          Icons.check_circle,
                                          size: 12.5.w,
                                          color: index == controller.addressType
                                              ? const Color(0xFF3DC453)
                                              : const Color(0xFFF0F0F0),
                                        ),
                                      ]),
                                    ),
                                  ),
                                )),
                      ],
                    ),
                  );
                },
              ),
            ),
            gline(322, 0.4, color: AppColor.textGrey),
            GetBuilder<MachineTransferShipmentsController>(
              init: controller,
              initState: (_) {},
              builder: (_) {
                return CustomButton(
                  onPressed: () {
                    Get.to(
                        MineAddressManager(
                          addressCallBack: (address) {
                            controller.selectAddress(address);
                          },
                          addressType: controller.addressType == 0
                              ? AddressType.address
                              : AddressType.branch,
                        ),
                        binding: MineAddressManagerBinding());
                  },
                  child: controller.addressType == 2
                      ? ghb(0)
                      : Container(
                          width: 345.w,
                          padding: EdgeInsets.only(top: 19.5.w, bottom: 15.5.w),
                          decoration: BoxDecoration(
                              color: const Color(0xFFEBEBEB),
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(5.w))),
                          child: Column(
                            children: [
                              sbRow([
                                getSimpleText(
                                    controller.address.isNotEmpty
                                        ? "${controller.address["recipient"] ?? ""}  ${controller.address["recipientMobile"] ?? ""}"
                                        : "点击添加收货地址",
                                    16,
                                    controller.address.isEmpty
                                        ? AppColor.textGrey
                                        : AppColor.textBlack,
                                    isBold: true),
                                controller.address.isEmpty
                                    ? gwb(0)
                                    : CustomButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text:
                                                  "${controller.address["recipient"] ?? ""}  ${controller.address["recipientMobile"] ?? ""}\n${controller.address["provinceName"] ?? ""}${controller.address["cityName"] ?? ""}${controller.address["areaName"] ?? ""}${controller.address["address"] ?? ""}"));

                                          ShowToast.normal("已复制");
                                        },
                                        child: Container(
                                          width: 74.5.w,
                                          height: 22.w,
                                          decoration: BoxDecoration(
                                              color: AppColor.textBlack,
                                              borderRadius:
                                                  BorderRadius.circular(5.w)),
                                          child: Center(
                                            child: getSimpleText(
                                                "一键复制", 12, Colors.white),
                                          ),
                                        ),
                                      )
                              ], width: 345 - 18.5 * 2),
                              ghb(16),
                              getWidthText(
                                  "${controller.address["provinceName"] ?? ""}${controller.address["cityName"] ?? ""}${controller.address["areaName"] ?? ""}${controller.address["address"] ?? ""}",
                                  14,
                                  AppColor.textGrey2,
                                  345 - 18.5 * 2,
                                  5,
                                  textAlign: TextAlign.start),
                              ghb(20),
                              Image.asset(
                                assetsName("common/line"),
                                width: 345.w,
                                height: 2.w,
                                fit: BoxFit.fill,
                              )
                            ],
                          ),
                        ),
                );
              },
            ),
            GetX<MachineTransferShipmentsController>(
              builder: (controller) {
                return Visibility(
                    visible: controller.addressType != 2,
                    child: centClm([
                      ghb(23),
                      sbRow([
                        getSimpleText("填写快递单号", 16, AppColor.textBlack,
                            isBold: true)
                      ], width: 375 - 35.5 * 2),
                      ghb(15),
                      Container(
                        width: 345.w,
                        height: 50.w,
                        decoration: getDefaultWhiteDec(),
                        child: Center(
                          child: CustomInput(
                            textEditCtrl: controller.dhInputCtrl,
                            placeholder: "在此处填写快递单号",
                            width: (345 - 21 * 2).w,
                            heigth: 50.w,
                            placeholderStyle: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFFCCCCCC)),
                            style: TextStyle(
                                fontSize: 15.sp, color: AppColor.textBlack),
                          ),
                        ),
                      ),
                      ghb(10),
                      sbRow([
                        getSimpleText(
                            "*接收人通过快递单号查看快递进度，请认真填写", 12, AppColor.textGrey)
                      ], width: 375 - 23 * 2)
                    ]));
              },
            )
          ])

          // Builder(builder: (builderContext) {
          //   return SingleChildScrollView(
          //     child: Column(
          //       children: [

          //         Container(
          //           padding: EdgeInsets.only(bottom: paddingSizeBottom(context)),
          //           width: 375.w,
          //           height: 80.w + paddingSizeBottom(context),
          //           color: Colors.white,
          //           child: Center(
          //             child: getSubmitBtn("确定", () {}),
          //           ),
          //         )
          //       ],
          //     ),
          //   );
          // }),
          ),
    );
  }
}
