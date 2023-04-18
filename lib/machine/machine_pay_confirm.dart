import 'package:cxhighversion2/component/app_success_result.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/machine/machine_order_list.dart';
import 'package:cxhighversion2/machine/machine_pay_page.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MachinePayConfirmBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<MachinePayConfirmController>(
        MachinePayConfirmController(data: Get.arguments));
  }
}

class MachinePayConfirmController extends GetxController {
  final dynamic data;
  MachinePayConfirmController({this.data});

  List productList = [];

  Map payType = {};

  List playTypeList = [];

  final _buyTypeList = Rx<List>([]);
  List get buyTypeList => _buyTypeList.value;
  set buyTypeList(v) => _buyTypeList.value = v;

  final _buyTypeIdx = 0.obs;
  int get buyTypeIdx => _buyTypeIdx.value;
  set buyTypeIdx(v) => _buyTypeIdx.value = v;

  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;

  final _transIndex = 0.obs;
  int get transIndex => _transIndex.value;
  set transIndex(v) => _transIndex.value = v;

  int machineCount = 0;
  final _allPrice = 0.0.obs;
  double get allPrice => _allPrice.value;
  set allPrice(v) => _allPrice.value = v;

  @override
  void onInit() {
    if (data != null && data is Map) {
      productList = data["machines"] ?? [];
      for (var e in productList) {
        machineCount += (e["num"] ?? 1) as int;
        allPrice += ((e["nowPrice"] ?? 0.0) * (e["num"] ?? 1.0)) * 1.0;
      }
      payType = data["payType"] ?? {};
    }
    loadAddress();
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadOrder(payPwd);
      },
    );
    previewOrder();
    super.onInit();
  }

  loadAddress() {
    simpleRequest(
        url: Urls.userContactList,
        params: {},
        success: (success, json) {
          if (success) {
            List aList = json["data"] ?? [];
            if (aList.isNotEmpty) {
              if (aList.length == 1) {
                address = aList[0];
              } else {
                for (var item in aList) {
                  if (item["isDefault"] == 1) {
                    address = item;
                    break;
                  }
                }
              }
              update();
            }
            // if (deliveryType == 0) {
            //   address = addressLocation;
            // }
            // loadPreviewOrder();
          }
        },
        after: () {},
        useCache: true);
  }

  setAddress(Map data) {
    address = data;
  }

  late BottomPayPassword bottomPayPassword;

  submitAction() {
    Map buyType = buyTypeList[buyTypeIdx];
    if (buyType["u_Type"] == 1) {
      ShowToast.normal("很抱歉，目前暂不支持${buyType["name"] ?? ""}支付,请选择其他支付方式");
      return;
    }

    if (AppDefault().homeData["u_3rd_password"] == null ||
        AppDefault().homeData["u_3rd_password"].isEmpty) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    bottomPayPassword.show();
  }

  Map previewOrderData = {};

  previewOrder() {
    Map<String, dynamic> params = {};
    List orderContent = [];
    for (var e in productList) {
      orderContent.add({"id": e["levelGiftId"], "num": e["num"] ?? 1});
    }
    params["orderContent"] = orderContent;
    simpleRequest(
      url: Urls.previewOrder,
      params: params,
      success: (success, json) {
        if (success) {
          previewOrderData = json["data"] ?? {};
          allPrice = previewOrderData["pay_Amount"] ?? 0.0;
          buyTypeList = previewOrderData["pay_MethodList"] ?? [];
          for (var i = 0; i < buyTypeList.length; i++) {
            Map bType = buyTypeList[i];
            if ((bType["u_Type"] ?? 0) == 3 && ((bType["value"] ?? 0)) == 1) {
              buyTypeIdx = i;
              break;
            }
          }
        }
      },
      after: () {},
    );
  }

  loadOrder(String payPwd) {
    Map<String, dynamic> params = {
      "delivery_Method": transIndex + 1,
      "contactID": address["id"],
      "pay_MethodType": buyTypeList[buyTypeIdx]["u_Type"],
      "pay_Method": buyTypeList[buyTypeIdx]["value"],
      "purchase_Type": payType["id"] ?? 1,
      "version_Origin": AppDefault().versionOriginForPay(),
      "u_3nd_Pad": payPwd,
    };
    List orderContent = [];
    for (var e in productList) {
      orderContent.add({"id": e["levelGiftId"], "num": e["num"] ?? 1});
    }
    params["orderContent"] = orderContent;

    simpleRequest(
      url: Urls.userLevelGiftPay,
      params: params,
      success: (success, json) async {
        if (success) {
          // Map data = json["data"];
          // Map payData = payTypeList[currentPayTypeIndex];
          // Map orderInfo = data["orderInfo"];

          push(
              AppSuccessResult(
                title: "采购结果",
                contentTitle: "提交成功",
                buttonTitles: const ["查看订单", "继续采购"],
                backPressed: () {
                  popToUntil();
                },
                onPressed: (index) {
                  if (index == 0) {
                    popToUntil(
                        page: const MachineOrderList(),
                        binding: MachineOrderListBinding());
                  } else if (index == 1) {
                    popToUntil(
                        page: const MachinePayPage(),
                        binding: MachinePayPageBinding());
                  }
                },
              ),
              Global.navigatorKey.currentContext!);

          // if (payData["u_Type"] == 1) {
          //   if (payData["value"] == 1) {
          //     //支付宝
          //     if (data["aliData"] == null || data["aliData"].isEmpty) {
          //       ShowToast.normal("支付失败，请稍后再试");
          //       return;
          //     }
          //     Map aliData = await CustomAlipay().payAction(
          //       data["aliData"],
          //       payBack: () {
          //         Future.delayed(const Duration(seconds: 1), () {
          //           alipayH5payBack(
          //             url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
          //             params: params,
          //             orderType: isBag
          //                 ? StoreOrderType.storeOrderTypePackage
          //                 : StoreOrderType.storeOrderTypeProduct,
          //             type: isBag
          //                 ? OrderResultType.orderResultTypePackage
          //                 : OrderResultType.orderResultTypeProduct,
          //           );
          //         });
          //       },
          //     );
          //     if (!kIsWeb) {
          //       simpleRequest(
          //         url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
          //         params: params,
          //         success: (success, json) {
          //           if (success) {
          //             Map orderData = json["data"];
          //             if (aliData["resultStatus"] == "6001") {
          //               toPayResult(
          //                   orderType: isBag
          //                       ? StoreOrderType.storeOrderTypePackage
          //                       : StoreOrderType.storeOrderTypeProduct,
          //                   orderData: orderData,
          //                   toOrderDetail: true);
          //             } else if (aliData["resultStatus"] == "9000") {
          //               toPayResult(
          //                   type: isBag
          //                       ? OrderResultType.orderResultTypePackage
          //                       : OrderResultType.orderResultTypeProduct,
          //                   orderData: orderData);
          //             }
          //           }
          //         },
          //         after: () {},
          //       );
          //     }
          //   }
          // } else if (payData["u_Type"] == 2) {
          //   simpleRequest(
          //     url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
          //     params: params,
          //     success: (succ, json) {
          //       if (succ) {
          //         Map orderData = json["data"];
          //         toPayResult(
          //             type: isBag
          //                 ? OrderResultType.orderResultTypePackage
          //                 : OrderResultType.orderResultTypeProduct,
          //             orderData: orderData);
          //       }
          //     },
          //     after: () {},
          //   );
          // }
        }
      },
      after: () {},
    );
  }
}

class MachinePayConfirm extends GetView<MachinePayConfirmController> {
  const MachinePayConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "确认采购单"),
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              gwb(375),
              ghb(16.5),
              addressView(),
              ghb(15),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.w),
                child: Container(
                  width: 345.w,
                  color: Colors.white,
                  child: Column(
                    children: [
                      ...List.generate(
                          controller.productList.length,
                          (index) => machineCell(
                              controller.productList[index], index)),
                      gline(315, 1),
                      infoCell("采购类型", t2: controller.payType["name"] ?? ""),
                      gline(315, 1),
                      GetX<MachinePayConfirmController>(
                        builder: (_) {
                          return infoCell("支付方式",
                              t2: controller.buyTypeList.isEmpty
                                  ? ""
                                  : controller.buyTypeList[
                                          controller.buyTypeIdx]["name"] ??
                                      "");
                        },
                      )
                    ],
                  ),
                ),
              ),
              ghb(15),
              Container(
                width: 345.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.w)),
                child: Column(
                  children: [
                    ghb(5),
                    infoCell("商品数量",
                        t2: "${controller.machineCount}", height: 40),
                    GetX<MachinePayConfirmController>(
                      builder: (_) {
                        return infoCell("合计",
                            height: 40,
                            rightWidget: getSimpleText(
                                "￥${priceFormat(controller.allPrice)}",
                                15,
                                const Color(0xFFF93635),
                                isBold: true));
                      },
                    ),
                    ghb(5),
                  ],
                ),
              ),
              ghb(26),
              getSubmitBtn("确认", () {
                if (controller.buyTypeList.isEmpty) {
                  ShowToast.normal("请等待，正在获取支付信息");
                  return;
                }
                showBuyTypeModel();
              }, width: 345, height: 45, color: AppColor.theme),
              ghb(20),
            ],
          )),
    );
  }

  Widget addressView() {
    return Container(
      width: 345.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8.w)),
      child: Column(
        children: [
          gwb(345),
          sbhRow([
            getSimpleText("配送方式", 14, AppColor.text3),
            centRow(List.generate(
                2,
                (index) => CustomButton(onPressed: () {
                      controller.transIndex = index;
                    }, child: GetX<MachinePayConfirmController>(
                      builder: (_) {
                        return centRow([
                          gwb(index == 0 ? 0 : 13),
                          ghb(
                            49.5,
                          ),
                          Image.asset(
                            assetsName(
                                "machine/checkbox_${controller.transIndex == index ? "selected" : "normal"}"),
                            width: 16.w,
                            fit: BoxFit.fitWidth,
                          ),
                          gwb(8),
                          getSimpleText(
                              index == 0 ? "快递配送" : "线下自提", 14, AppColor.text2,
                              textHeight: 1.3),
                        ]);
                      },
                    )))),
          ], width: 345 - 14.5 * 2, height: 49.5),
          GetX<MachinePayConfirmController>(
            builder: (_) {
              return controller.transIndex == 1
                  ? ghb(0)
                  : GetX<MachinePayConfirmController>(
                      builder: (_) {
                        return CustomButton(
                          onPressed: () {
                            push(
                                MineAddressManager(
                                  getCtrl: controller,
                                  addressType: AddressType.address,
                                ),
                                null,
                                binding: MineAddressManagerBinding());
                          },
                          child: centClm([
                            gline(315, 1),
                            sbRow([
                              centRow([
                                gwb(12),
                                Image.asset(
                                  assetsName("machine/icon_address"),
                                  width: 18.w,
                                  fit: BoxFit.fitWidth,
                                ),
                              ]),
                              SizedBox(
                                width: 234.5.w,
                                child: controller.address.isEmpty
                                    ? SizedBox(
                                        height: 81.5.w,
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: getSimpleText(
                                                "请选择收货地址", 12, AppColor.text3)))
                                    : centClm([
                                        ghb(12),
                                        getWidthText(
                                            "${controller.address["recipient"] ?? ""}   ${controller.address["recipientMobile"] ?? ""}",
                                            15,
                                            AppColor.text,
                                            234.5,
                                            1),
                                        ghb(6),
                                        getWidthText(
                                            "${controller.address["provinceName"]}${controller.address["cityName"]}${controller.address["areaName"]}${controller.address["address"]}",
                                            12,
                                            AppColor.text3,
                                            242,
                                            2),
                                        ghb(12),
                                      ]),
                              ),
                              Image.asset(
                                assetsName("statistics/icon_arrow_right_gray"),
                                width: 18.w,
                                fit: BoxFit.fitWidth,
                              ),
                            ], width: 345 - 11.5 * 2),
                            Image.asset(
                              assetsName("machine/address_bottom_line"),
                              width: 345.w,
                              height: 3.w,
                              fit: BoxFit.fill,
                            ),
                          ]),
                        );
                      },
                    );
            },
          )
        ],
      ),
    );
  }

  Widget infoCell(String title,
      {String? t2, Widget? rightWidget, double height = 59}) {
    return sbhRow([
      getSimpleText(title, 14, AppColor.text3),
      t2 != null ? getSimpleText(t2, 14, AppColor.text2) : rightWidget ?? gwb(0)
    ], width: 345 - 15 * 2, height: height);
  }

  Widget machineCell(Map data, int index) {
    return Align(
      child: Column(
        children: [
          index != 0 ? gline(315, 1) : ghb(0),
          SizedBox(
            width: 345.w,
            height: 120.w,
            child: Center(
              child: sbhRow([
                centRow([
                  CustomNetworkImage(
                    src: AppDefault().imageUrl + (data["levelGiftImg"] ?? ""),
                    width: 90.w,
                    height: 90.w,
                    fit: BoxFit.fill,
                  ),
                ]),
                Padding(
                  padding: EdgeInsets.only(right: 11.5.w),
                  child: sbClm([
                    centClm([
                      getWidthText("${data["levelName"] ?? ""}", 15,
                          AppColor.text, 200, 2,
                          isBold: true),
                      ghb(3),
                      getWidthText("型号：${data["levelDescribe"] ?? ""}", 12,
                          AppColor.text3, 180, 1),
                    ], crossAxisAlignment: CrossAxisAlignment.start),
                    sbRow([
                      getSimpleText("￥${priceFormat(data["nowPrice"] ?? 0)}",
                          15, const Color(0xFFF93635),
                          isBold: true),
                      getSimpleText(
                          "X${data["num"] ?? 1}", 12, AppColor.textGrey5)
                    ], width: 200),
                  ], height: 90, crossAxisAlignment: CrossAxisAlignment.start),
                ),
              ], height: 120 - 15 * 2, width: 345 - 15 * 2),
            ),
          ),
        ],
      ),
    );
  }

  showBuyTypeModel() {
    double cellHeight = 40;
    double infoHeight = 80;

    Get.bottomSheet(
      Container(
        width: 375.w,
        height: (54 +
                    infoHeight +
                    45 +
                    (cellHeight * controller.buyTypeList.length) +
                    10 +
                    30 +
                    20)
                .w +
            paddingSizeBottom(Global.navigatorKey.currentContext!),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
        child: Column(
          children: [
            gwb(375),
            sbhRow([
              gwb(42),
              getSimpleText("确认支付", 18, AppColor.text, isBold: true),
              CustomButton(
                onPressed: () {
                  Get.back();
                },
                child: SizedBox(
                  width: 42.w,
                  height: 48.w,
                  child: Center(
                    child: Image.asset(
                      assetsName("statistics/machine/btn_model_close"),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              )
            ], width: 375, height: 48),
            ghb(5),
            gline(375, 1),
            SizedBox(
              height: infoHeight.w,
              child: centClm([
                getSimpleText("总计费用", 14, AppColor.text2),
                ghb(6),
                getRichText(priceFormat(controller.allPrice), "元", 24,
                    AppColor.red, 14, AppColor.text2,
                    isBold: true, isBold2: true),
              ]),
            ),
            ghb(10),
            ...List.generate(controller.buyTypeList.length, (index) {
              Map buyData = controller.buyTypeList[index];
              return CustomButton(
                onPressed: () {
                  controller.buyTypeIdx = index;
                },
                child: sbhRow([
                  centRow([
                    CustomNetworkImage(
                      src: AppDefault().imageUrl + (buyData["img"] ?? ""),
                      width: 18.w,
                      fit: BoxFit.fitWidth,
                    ),
                    gwb(5),
                    getSimpleText(buyData["name"] ?? "", 15, AppColor.text2),
                  ]),
                  GetX<MachinePayConfirmController>(
                    builder: (_) {
                      return Image.asset(
                        assetsName(
                            "machine/checkbox_${controller.buyTypeIdx == index ? "selected" : "normal"}"),
                        width: 18.w,
                        fit: BoxFit.fitWidth,
                      );
                    },
                  )
                ], width: 345, height: cellHeight),
              );
            }),
            ghb(30),
            getSubmitBtn("确定", () {
              Get.back();
              controller.submitAction();
            }, color: AppColor.theme, width: 345, height: 45),
          ],
        ),
      ),
    );
  }
}
