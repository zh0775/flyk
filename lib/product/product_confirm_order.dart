import 'dart:convert' as convert;

import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/mineStoreOrder/mine_store_order_list.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/product/component/product_order_cell.dart';
import 'package:cxhighversion2/product/component/update_order_button.dart';
import 'package:cxhighversion2/product/product_pay_result_page.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/EventBus.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/notify_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductConfirmOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductConfirmOrderController>(
        () => ProductConfirmOrderController());
  }
}

class ProductConfirmOrderController extends GetxController {
  bool isFirst = true;
  final _currentCount = 1.obs;
  get currentCount => _currentCount.value;
  set currentCount(v) {
    _currentCount.value = v;
    // update([confirmButtonBuildId]);
    loadPreviewOrder();
  }

  BottomPayPassword? bottomPayPassword;

  bool haveWarning = false;

  final _deliveryType = 0.obs;
  get deliveryType => _deliveryType.value;
  set deliveryType(v) {
    _deliveryType.value = v;
    if (deliveryType == 0) {
      address = addressLocation;
    } else if (v == 1) {
      address = branchLocation;
    }
  }

  final _productData = Rx<Map>({});
  Map get productData => _productData.value;
  set productData(v) => _productData.value = v;

  bool haveAdress = false;

  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;

  final _addressLocation = Rx<Map>({});
  Map get addressLocation => _addressLocation.value;
  set addressLocation(v) => _addressLocation.value = v;

  final _branchLocation = Rx<Map>({});
  Map get branchLocation => _branchLocation.value;
  set branchLocation(v) => _branchLocation.value = v;

  final _productDatas = Rx<List>([]);
  List get productDatas => _productDatas.value;
  set productDatas(v) => _productDatas.value = v;

  Map payType = {};

  final _showPrice = true.obs;
  get showPrice => _showPrice.value;
  set showPrice(v) => _showPrice.value = v;

  late bool isBag;
  bool isReal = false;
  String payName = "";

  List payTypeList = [];
  final _currentPayTypeIndex = 0.obs;
  int get currentPayTypeIndex => _currentPayTypeIndex.value;
  set currentPayTypeIndex(v) => _currentPayTypeIndex.value = v;

  dataInit(Map pData, List pList, Map pType, bool bag) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    productData = pData;
    productDatas = pList;
    isBag = bag;
    payType = pType;
    // if (payType != null && payType.isNotEmpty && !isBag) {
    //   showPrice = !(payType["u_Type"] == 2 && payType["value"] != "1");
    // }
    // if (!isBag) {
    showPrice = true;
    dynamic tmpPayTypes =
        convert.jsonDecode(productData["levelGiftPaymentMethod"]);
    if (tmpPayTypes != null && tmpPayTypes is List && tmpPayTypes.isNotEmpty) {
      payTypeList = tmpPayTypes;
      isReal = (payTypeList[0]["u_Type"] == 1);
    }
  }

  selectAddressLocation(Map data) {
    addressLocation = data;
    if (deliveryType == 0) {
      address = addressLocation;
    }
  }

  String confirmButtonBuildId = "ProductConfirmOrder_confirmButtonBuildId";

  selectBranchLocation(Map data) {
    branchLocation = data;
    if (deliveryType == 1) {
      address = branchLocation;
    }
  }

  final _previewOrderData = Rx<Map>({});
  Map get previewOrderData => _previewOrderData.value;
  set previewOrderData(v) => _previewOrderData.value = v;

  String payPwd = "";

  loadPreviewOrder() {
    if (payTypeList.isEmpty) {
      return;
    }
    Map<String, dynamic> params = {
      "delivery_Method": deliveryType + 1,
      // "levelConfigId": isBag ? payType["levelGiftId"] : productData["teamId"],
      "levelConfigId": productData["levelGiftId"],

      "num": currentCount,
      "contactID": address["id"] ?? 0,
      "pay_MethodType":
          int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
      "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}")
    };
    // if (isBag) params["levelTeamId"] = productData["teamId"];
    // params["levelTeamId"] = productData["teamId"];
    if (isBag && productDatas.isNotEmpty) {
      List orderContent = [];
      for (var item in productDatas) {
        orderContent.add({"id": item["id"], "num": item["count"]});
      }
      params["orderContent"] = orderContent;
    }

    simpleRequest(
      url: Urls.previewOrder,
      params: params,
      success: (success, json) {
        if (success) {
          previewOrderData = json["data"];
          update([confirmButtonBuildId]);
        }
      },
      after: () {},
    );
  }

  loadOrder() {
    Map<String, dynamic> params = {
      "delivery_Method": deliveryType + 1,
      // "levelConfigId": isBag ? payType["levelGiftId"] : productData["teamId"],
      "levelConfigId": productData["levelGiftId"],
      "num": currentCount,
      "contactID": address["id"],
      "pay_MethodType":
          int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
      "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}"),
      "version_Origin": AppDefault().versionOriginForPay(),
      "u_3nd_Pad": payPwd,
    };
    // if (payTypeList[currentPayTypeIndex]["u_Type"] == 2) {
    //   params["u_3nd_Pad"] = payPwd;
    // }
    // if (isBag) params["levelTeamId"] = productData["teamId"];
    // params["levelTeamId"] = productData["teamId"];
    if (isBag && productDatas.isNotEmpty) {
      List orderContent = [];
      for (var item in productDatas) {
        orderContent.add({"id": item["id"], "num": item["count"]});
      }
      params["orderContent"] = orderContent;
    }

    simpleRequest(
      url: Urls.userLevelGiftPay,
      params: params,
      success: (success, json) async {
        if (success) {
          Map data = json["data"];
          Map payData = payTypeList[currentPayTypeIndex];
          Map orderInfo = data["orderInfo"];

          if (payData["u_Type"] == 1) {
            if (payData["value"] == 1) {
              //支付宝
              if (data["aliData"] == null || data["aliData"].isEmpty) {
                ShowToast.normal("支付失败，请稍后再试");
                return;
              }
              Map aliData = await CustomAlipay().payAction(
                data["aliData"],
                payBack: () {
                  Future.delayed(const Duration(seconds: 1), () {
                    alipayH5payBack(
                      url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
                      params: params,
                    );
                  });
                },
              );
              if (!kIsWeb) {
                simpleRequest(
                  url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
                  params: params,
                  success: (success, json) {
                    if (success) {
                      Map orderData = json["data"];
                      if (aliData["resultStatus"] == "6001") {
                        toPayResult(orderData: orderData, toOrderDetail: true);
                      } else if (aliData["resultStatus"] == "9000") {
                        toPayResult(orderData: orderData);
                      }
                    }
                  },
                  after: () {},
                );
              }
            }
          } else if (payData["u_Type"] == 2) {
            simpleRequest(
              url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
              params: params,
              success: (succ, json) {
                if (succ) {
                  Map orderData = json["data"];
                  toPayResult(orderData: orderData);
                }
              },
              after: () {},
            );
          }

          // print(aliData);
          // Get.to(AppSuccessPage());
        }
      },
      after: () {},
    );
  }

  Map homeData = {};
  getHomeDataNotify(arg) {
    homeData = AppDefault().homeData;
  }

  @override
  void onInit() {
    homeData = AppDefault().homeData;
    bus.on(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (pwd) {
        payPwd = pwd;
        // Get.back();
        loadOrder();
      },
    );
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
            if (deliveryType == 0) {
              address = addressLocation;
            }
            loadPreviewOrder();
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
            if (deliveryType == 1) {
              address = branchLocation;
            }
          }
        },
        after: () {});

    super.onInit();
  }

  @override
  void onClose() {
    bus.off(HOME_DATA_UPDATE_NOTIFY, getHomeDataNotify);
    super.onClose();
  }
}

class ProductConfirmOrder extends GetView<ProductConfirmOrderController> {
  final String? warningStr;
  final Map productData;
  final List productDatas;
  final int? count;
  final double? price;
  final Function()? confirmAndUpdateOrder;
  final Map payType;
  final bool isBag;
  const ProductConfirmOrder(
      {Key? key,
      required this.productData,
      this.warningStr,
      this.count,
      this.price,
      this.isBag = false,
      this.productDatas = const [],
      this.payType = const {},
      this.confirmAndUpdateOrder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(productData, productDatas, payType, isBag);
    return Scaffold(
        appBar: getDefaultAppBar(context, "确认订单"),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: controller.haveWarning ? 155.w : 125.w,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ghb(20),
                      getSimpleText("选择收货方式", 15, AppColor.textBlack,
                          isBold: true),
                      ghb(20),
                      deliveryInfoView(context),
                      ghb(20),
                      GetX<ProductConfirmOrderController>(
                        init: controller,
                        builder: (_) {
                          return controller.productDatas != null &&
                                  controller.productDatas.isNotEmpty
                              ? centClm([
                                  getSimpleText("已选${isBag ? "设备" : "产品"}", 15,
                                      AppColor.textBlack,
                                      isBold: true),
                                  ghb(20),
                                  centClm((controller.productDatas as List)
                                      .asMap()
                                      .entries
                                      .map((e) {
                                    return e.value["selected"]
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                bottom: e.key !=
                                                        controller.productDatas
                                                                .length -
                                                            1
                                                    ? 15.w
                                                    : 0),
                                            child: ProductOrderCell(
                                              cellData: e.value,
                                              name: e.value["terminalName"],
                                              dec: e.value["terminalMod"],
                                              imgSrc: e.value["terminalImg"],
                                              index: e.key,
                                              haveCount: false,
                                              defaultCount: e.value["count"],
                                            ),
                                          )
                                        : const SizedBox();
                                  }).toList()),

                                  // ghb(20),
                                ], crossAxisAlignment: CrossAxisAlignment.start)
                              : const SizedBox();
                        },
                      ),
                      GetX<ProductConfirmOrderController>(
                        init: controller,
                        builder: (_) {
                          return ghb(
                              controller.productDatas.isNotEmpty ? 20 : 0);
                        },
                      ),
                      Visibility(
                        visible: !isBag,
                        child: getSimpleText(
                            "已选${isBag ? "礼包" : "产品"}", 15, AppColor.textBlack,
                            isBold: true),
                      ),
                      Visibility(
                        visible: !isBag,
                        child: ghb(20),
                      ),
                      Visibility(
                        visible: !isBag,
                        child: GetX<ProductConfirmOrderController>(
                          init: controller,
                          initState: (_) {},
                          builder: (_) {
                            return ProductOrderCell(
                              cellData: productData,
                              index: 0,
                              isReal: controller.isReal,
                              unit: controller.isReal
                                  ? "元"
                                  : controller.payTypeList.isEmpty
                                      ? ""
                                      : controller.payTypeList[controller
                                          .currentPayTypeIndex]["name"],
                              haveCount: isBag ? false : true,
                              name: productData["levelName"],
                              dec: productData["levelDescribe"],
                              imgSrc: productData["levelGiftImg"],
                              price: (controller.showPrice
                                  ? priceFormat(productData["nowPrice"])
                                  : null),
                              defaultCount: controller.currentCount,
                              changeCountAction: (count, idx, {isAdd}) {
                                if (isAdd != null) {
                                  if (!isBag) {
                                    if (count == 1 && !isAdd) {
                                      return;
                                    }
                                    isAdd
                                        ? controller.currentCount++
                                        : controller.currentCount--;
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                      ghb(15),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              height: controller.haveWarning ? 155.w : 125.w,
              bottom: 0,
              child: GetBuilder<ProductConfirmOrderController>(
                  init: controller,
                  id: controller.confirmButtonBuildId,
                  builder: (_) {
                    return UpdateOrderButton(
                      productData: productData,
                      count: controller.currentCount,
                      freight: controller.previewOrderData != null &&
                              controller.previewOrderData.isNotEmpty
                          ? controller.previewOrderData["pay_Freight"]
                          : -1,
                      unit: controller.isReal
                          ? "元"
                          : controller.payTypeList.isEmpty
                              ? ""
                              : controller.payTypeList[
                                      controller.currentPayTypeIndex]["name"] ??
                                  "",
                      yfUnit: controller.isReal
                          ? "元"
                          : controller.payTypeList.isEmpty
                              ? ""
                              : controller.payTypeList[
                                      controller.currentPayTypeIndex]["name"] ??
                                  "",
                      // price: isBag
                      //     ? (controller.previewOrderData != null &&
                      //             controller.previewOrderData.isNotEmpty
                      //         ? controller.previewOrderData["pay_Amount"]
                      //         : null)
                      //     : controller.currentCount *
                      //         controller.payType["nowPrice"],

                      price: controller.previewOrderData != null &&
                              controller.previewOrderData.isNotEmpty
                          ? controller.previewOrderData["pay_Amount"]
                          : null,
                      confirmAndUpdateOrder: () {
                        if (controller.payTypeList.isEmpty) {
                          ShowToast.normal("该商品暂无购买方式");
                          return;
                        }
                        controller.loadPreviewOrder();
                        showPayChoose(context);
                      },
                    );
                  }),
            ),
          ],
        ));
  }

  Widget deliveryInfoView(BuildContext context) {
    return Container(
      width: 345.w,
      // height: 200.w,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5.w)),
      child: Padding(
        padding: EdgeInsets.only(left: 9.w, bottom: 9.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [deliveryChooesButton(0), deliveryChooesButton(1)],
            ),
            gline(327, 0.5),
            Padding(
              padding: EdgeInsets.only(left: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomButton(
                    onPressed: () {
                      push(
                          MineAddressManager(
                            getCtrl: controller,
                            addressType: controller.deliveryType == 0
                                ? AddressType.address
                                : AddressType.branch,
                          ),
                          context,
                          binding: MineAddressManagerBinding());
                    },
                    child: SizedBox(
                      width: 300.w,
                      height: 50.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GetX<ProductConfirmOrderController>(
                            init: controller,
                            builder: (_) {
                              return getSimpleText(
                                  "${controller.deliveryType == 0 ? "收货人" : "网点"}信息",
                                  16,
                                  AppColor.textBlack,
                                  isBold: true);
                            },
                          ),
                          Icon(
                            Icons.play_arrow,
                            size: 13.w,
                            color: AppColor.textBlack,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ghb(5),
                  GetX<ProductConfirmOrderController>(
                    init: controller,
                    builder: (_) {
                      return getSimpleText(
                          controller.address.isEmpty
                              ? "默认地址为空"
                              : "${controller.address["recipient"] ?? ""}  ${controller.address["recipientMobile"] ?? ""}",
                          16,
                          controller.address.isEmpty
                              ? const Color(0xFFB3B3B3)
                              : AppColor.textBlack);
                    },
                  ),
                  ghb(6),
                  GetX<ProductConfirmOrderController>(
                    init: controller,
                    builder: (_) {
                      return getWidthText(
                          controller.address.isEmpty
                              ? "请添加您的收货地址"
                              : "${controller.address["provinceName"] ?? ""}${controller.address["cityName"] ?? ""}${controller.address["areaName"] ?? ""}${controller.address["address"] ?? ""}",
                          14,
                          controller.address.isEmpty
                              ? const Color(0xFFB3B3B3)
                              : AppColor.textGrey2,
                          292.5,
                          3);
                    },
                  ),
                  ghb(18),
                ],
              ),
            ),
            Image.asset(
              assetsName("common/line"),
              width: (345 - 10.5 * 2).w,
              height: 2.w,
              fit: BoxFit.fill,
            )
          ],
        ),
      ),
    );
  }

  Widget deliveryChooesButton(int idx) {
    return CustomButton(
      onPressed: () {
        if (controller.deliveryType != idx) {
          controller.deliveryType = idx;
        }
      },
      child: GetX<ProductConfirmOrderController>(
        init: controller,
        initState: (_) {},
        builder: (_) {
          return SizedBox(
            width: (300 / 2).w,
            height: 50.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getSimpleText(
                    idx == 0 ? "快递送货" : "网点自提", 16, AppColor.textBlack,
                    isBold: true),
                gwb(8),
                Icon(
                  Icons.check_circle,
                  size: 12.5.w,
                  color: idx == controller.deliveryType
                      ? const Color(0xFF3DC453)
                      : const Color(0xFFF0F0F0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void showPayChoose(BuildContext context) {
    double bottomHeight = controller.payTypeList.length * 51.w +
        56.5.w +
        50.5.w +
        100.w +
        29.w +
        paddingSizeBottom(context) +
        50.w +
        20.w;
    if (bottomHeight < 459.5.w) {
      bottomHeight = 459.5.w;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modelBottomCtx) {
        return StatefulBuilder(
          builder: (context, setModalBottomState) {
            return SizedBox(
              width: 375.w,
              height: bottomHeight,
              child: Stack(
                children: [
                  Positioned(
                      right: 24.w,
                      top: 0,
                      width: 37.w,
                      height: 56.5.w,
                      child: CustomButton(
                        onPressed: () {
                          // takeBackKeyboard(Global.navigatorKey.currentContext!);
                          // if (closeClick != null) {
                          //   closeClick!();
                          // }
                          Get.back();
                        },
                        child: Image.asset(
                          assetsName(
                            "common/btn_model_close",
                          ),
                          width: 37.w,
                          height: 56.5.w,
                          fit: BoxFit.fill,
                        ),
                      )),
                  Positioned(
                      top: 56.5.w,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(6.w))),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50.w,
                              child: Center(
                                child: getSimpleText(
                                    "支付", 16, AppColor.textBlack,
                                    isBold: true),
                              ),
                            ),
                            gline(375, 0.5),
                            SizedBox(
                              height: 100.w,
                              child: Center(
                                child: centClm([
                                  getSimpleText(
                                    "总计费用",
                                    14,
                                    AppColor.textBlack,
                                  ),
                                  ghb(10),
                                  Visibility(
                                      visible:
                                          controller.previewOrderData != null &&
                                              controller
                                                  .previewOrderData.isNotEmpty,
                                      child: GetBuilder<
                                          ProductConfirmOrderController>(
                                        init: controller,
                                        id: controller.confirmButtonBuildId,
                                        initState: (_) {},
                                        builder: (_) {
                                          return Text.rich(TextSpan(
                                              // text: "${controller.currentCount * productData["nowPrice"]}",
                                              text: priceFormat(
                                                  controller.previewOrderData[
                                                      "pay_Amount"]),
                                              style: TextStyle(
                                                  fontSize: 24.sp,
                                                  color:
                                                      const Color(0xFFF13030),
                                                  fontWeight:
                                                      AppDefault.fontBold),
                                              children: [
                                                TextSpan(
                                                    text: controller.isReal
                                                        ? "元"
                                                        : controller.payTypeList[
                                                                    controller
                                                                        .currentPayTypeIndex]
                                                                ["name"] ??
                                                            "",
                                                    style: TextStyle(
                                                        fontSize: 11.sp,
                                                        color:
                                                            AppColor.textBlack))
                                              ]));
                                        },
                                      )),
                                ]),
                              ),
                            ),
                            ...controller.payTypeList
                                .asMap()
                                .entries
                                .map((e) => GetX<ProductConfirmOrderController>(
                                      builder: (_) {
                                        return CustomButton(
                                          onPressed: () {
                                            controller.currentPayTypeIndex =
                                                e.key;
                                            controller.loadPreviewOrder();
                                          },
                                          child: sbhRow([
                                            centRow([
                                              Image.asset(
                                                  assetsName(
                                                      "pay/icon_pay_${e.value["value"] == 1 ? "alipay" : e.value["value"] == 2 ? "wx" : "ye"}"),
                                                  width: 20.w,
                                                  fit: BoxFit.fitWidth),
                                              gwb(12),
                                              getSimpleText(e.value["name"], 16,
                                                  AppColor.textBlack),
                                            ]),
                                            Image.asset(
                                              assetsName(
                                                  "pay/icon_selectpay_${controller.currentPayTypeIndex == e.key ? "selected" : "normal"}"),
                                              width: 19.5.w,
                                              fit: BoxFit.fitWidth,
                                            )
                                          ], width: 375 - 24 * 2, height: 51),
                                        );
                                      },
                                    ))
                                .toList()
                          ],
                        ),
                      )),
                  Positioned(
                      left: 15.w,
                      bottom: 29.w + paddingSizeBottom(context),
                      child: CustomButton(
                        onPressed: () {
                          Navigator.pop(modelBottomCtx, () {});
                          // push(
                          //     ProductConfirmOrder(
                          //       productData: widget.productData,
                          //     ),
                          //     context);
                        },
                        child: getSubmitBtn("确认支付", () {
                          Get.back();
                          if (controller.address == null ||
                              controller.address.isEmpty) {
                            ShowToast.normal("请选择您的收货地址");
                            return;
                          }

                          if ((controller.homeData["u_3rd_password"] == null ||
                                  controller
                                      .homeData["u_3rd_password"].isEmpty) &&
                              controller.payTypeList[controller
                                      .currentPayTypeIndex]["u_Type"] ==
                                  2) {
                            showPayPwdWarn(
                              haveClose: true,
                              popToRoot: false,
                              untilToRoot: false,
                              setSuccess: () {},
                            );
                            return;
                          }
                          if (controller.payTypeList[
                                  controller.currentPayTypeIndex]["u_Type"] ==
                              2) {
                            controller.bottomPayPassword!.show();
                          } else if (controller.payTypeList[
                                  controller.currentPayTypeIndex]["u_Type"] ==
                              1) {
                            controller.loadOrder();
                          }
                        }),
                      ))
                ],
              ),
            );
          },
        );
      },
    );
  }
}
