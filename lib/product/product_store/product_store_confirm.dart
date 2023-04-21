import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:convert' as convert;

class ProductStoreConfirmBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductStoreConfirmController>(
        ProductStoreConfirmController(datas: Get.arguments));
  }
}

class ProductStoreConfirmController extends GetxController {
  final dynamic datas;
  ProductStoreConfirmController({this.datas});

  int levelType = 1;

  final _currentCount = 1.obs;
  set currentCount(v) => _currentCount.value = v;
  int get currentCount => _currentCount.value;
  // 商品备注
  final remarkInputCtrl = TextEditingController();

  final numInputCtrl = TextEditingController();
  final numNode = FocusNode();

  // 订单预览数据
  final _previewOrderData = Rx<Map>({});
  Map get previewOrderData => _previewOrderData.value;
  set previewOrderData(v) => _previewOrderData.value = v;

  // 商品数据
  final _productData = Rx<Map>({});
  Map get productData => _productData.value;
  set productData(v) => _productData.value = v;
//是否地址为空
  bool haveAdress = false;
// 支付方式列表
  List payTypeList = [];
  // 当前选择的支付方式
  final _currentPayTypeIndex = 0.obs;
  int get currentPayTypeIndex => _currentPayTypeIndex.value;
  set currentPayTypeIndex(v) => _currentPayTypeIndex.value = v;

  // 地址类型 0:邮寄地址 1:自提地址
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

  // 当前地址
  final _address = Rx<Map>({});
  Map get address => _address.value;
  set address(v) => _address.value = v;
  // 邮寄地址
  final _addressLocation = Rx<Map>({});
  Map get addressLocation => _addressLocation.value;
  set addressLocation(v) => _addressLocation.value = v;
  // 自提地址
  final _branchLocation = Rx<Map>({});
  Map get branchLocation => _branchLocation.value;
  set branchLocation(v) => _branchLocation.value = v;
// 从地址管理页面传递地址数据过来
  setAddress(Map data) {
    addressLocation = data;
    if (deliveryType == 0) {
      address = addressLocation;
    }
  }

  loadAddress() {
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
        after: () {},
        useCache: true);

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
  }

  String confirmButtonBuildId = "confirmButtonBuildId";

  // 提交购买
  payAction() {
    if (address.isEmpty) {
      ShowToast.normal("请选择您的收货地址");
      return;
    }
    Map homeData = AppDefault().homeData;
    if ((homeData["u_3rd_password"] == null ||
            homeData["u_3rd_password"].isEmpty) &&
        payTypeList[currentPayTypeIndex]["u_Type"] != 1) {
      showPayPwdWarn(
        haveClose: true,
        popToRoot: false,
        untilToRoot: false,
        setSuccess: () {},
      );
      return;
    }
    if (payTypeList[currentPayTypeIndex]["u_Type"] != 1) {
      bottomPayPassword.show();
    } else if (payTypeList[currentPayTypeIndex]["u_Type"] == 1) {
      loadOrder("");
    }
  }

  // 订单预览
  loadPreviewOrder() {
    if (payTypeList.isEmpty) {
      return;
    }
    Map<String, dynamic> params = {
      "delivery_Method": deliveryType + 1,
      "levelConfigId": productData["levelGiftId"],
      "num": currentCount,
      "contactID": address["id"] ?? 0,
      "pay_MethodType":
          int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
      "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}")
    };

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

  loadOrder(String payPwd) {
    Map<String, dynamic> params = {
      "delivery_Method": deliveryType + 1,
      "levelConfigId": productData["levelGiftId"],
      "num": currentCount,
      "contactID": address["id"],
      "pay_MethodType":
          int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
      "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}"),
      "version_Origin": AppDefault().versionOriginForPay(),
      // "u_3nd_Pad": payPwd,
      "user_Remarks": remarkInputCtrl.text,
    };

    if (payPwd.isNotEmpty) {
      params["u_3nd_Pad"] = payPwd;
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

  // 是否为现金商品
  bool isReal = true;

  // 支付密码组件
  late BottomPayPassword bottomPayPassword;

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 300), () {
      loadAddress();
    });
    super.onReady();
  }

  @override
  void onInit() {
    bottomPayPassword = BottomPayPassword.init(
      confirmClick: (payPwd) {
        loadOrder(payPwd);
      },
    );
    // 列表传过来的商品数据
    productData = (datas ?? {})["data"] ?? {};
    // 1:礼包 2:采购 3:兑换
    levelType = (datas ?? {})["levelType"] ?? 1;
    // 购买数量
    currentCount = (datas ?? {})["num"] ?? 1;

    dynamic tmpPayTypes =
        convert.jsonDecode(productData["levelGiftPaymentMethod"]);
    if (tmpPayTypes != null && tmpPayTypes is List && tmpPayTypes.isNotEmpty) {
      payTypeList = tmpPayTypes;
      isReal = (payTypeList[0]["u_Type"] == 1);
    }
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class ProductStoreConfirm extends GetView<ProductStoreConfirmController> {
  const ProductStoreConfirm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(context, "确认订单"),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Image.asset(assetsName("product_store/bg_confirm_view_top"),
                width: 375.w, height: 210.w, fit: BoxFit.fill),
          ),
          Positioned.fill(
            bottom: 60.w + paddingSizeBottom(context),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [deliveryInfoView(context), ghb(15)],
              ),
            ),
          ),
          Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60.w + paddingSizeBottom(context),
              child: CustomButton(
                onPressed: () {},
                child: Container(
                  width: 345.w,
                  height: 45.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.w),
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFD573B), Color(0xFFFF3A3A)])),
                  child: getSimpleText("提交订单", 16, Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  Widget deliveryInfoView(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 11.5.w),
      width: 345.w,
      height: 170.w,
      child: Stack(
        children: [
          Positioned.fill(
              top: 5.w,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.w),
                child: Container(
                  width: 345.w,
                  height: 165.w,
                  color: Colors.white,
                  child: sbClm([
                    GetX<ProductStoreConfirmController>(builder: (_) {
                      bool isDefalut =
                          ((controller.address["isDefault"] ?? 0) == 1) &&
                              controller.deliveryType == 0;
                      return Column(
                        children: [
                          Container(
                            width: 345.w,
                            height: 40.w,
                            color: const Color(0xFFFE413A).withOpacity(0.1),
                            child: sbhRow(
                                List.generate(2, (index) {
                                  return CustomButton(
                                    onPressed: () {
                                      controller.deliveryType = index;
                                    },
                                    child: SizedBox(
                                      width: 345.w / 2 - 0.1.w,
                                      height: 40.w,
                                      child: Center(
                                        child: getSimpleText(
                                            index == 0 ? "快递配送" : "网点自提",
                                            15,
                                            AppColor.textGrey),
                                      ),
                                    ),
                                  );
                                }),
                                width: 345 - 9.5 * 2),
                          ),
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
                            child: controller.address.isEmpty
                                ? sbhRow([
                                    getSimpleText(
                                        "请添加您的收货地址", 14, AppColor.textGrey),
                                    Image.asset(
                                      assetsName(
                                          "product_store/cell_arrow_right"),
                                      width: 18.w,
                                      fit: BoxFit.fitWidth,
                                    )
                                  ], width: 315, height: 55)
                                : centClm([
                                    ghb(28),
                                    sbRow([
                                      SizedBox(
                                        width: (345 - 9.5 * 2).w - 18.w,
                                        child: Text.rich(
                                          TextSpan(
                                              style: TextStyle(
                                                  fontSize: 15.sp,
                                                  color: Colors.black,
                                                  fontWeight:
                                                      AppDefault.fontBold,
                                                  height: 1.0),
                                              children: [
                                                WidgetSpan(child: gwb(9.5)),
                                                WidgetSpan(
                                                    child: controller
                                                                    .deliveryType ==
                                                                0 &&
                                                            isDefalut
                                                        ? Container(
                                                            width: 30.w,
                                                            // height: 16.w,
                                                            alignment: Alignment
                                                                .center,
                                                            margin:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        1.5.w),
                                                            decoration: BoxDecoration(
                                                                color: AppColor
                                                                    .theme,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            2.w)),
                                                            child:
                                                                getSimpleText(
                                                                    "默认",
                                                                    12,
                                                                    Colors
                                                                        .white),
                                                          )
                                                        : controller.deliveryType ==
                                                                1
                                                            ? Container(
                                                                width: 55.w,
                                                                // height: 16.w,
                                                                margin: EdgeInsets
                                                                    .only(
                                                                        bottom:
                                                                            1.5.w),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        width: 0.5
                                                                            .w,
                                                                        color: AppColor
                                                                            .theme),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            2.w)),
                                                                child: getSimpleText(
                                                                    "自提网点",
                                                                    12,
                                                                    AppColor
                                                                        .theme),
                                                              )
                                                            : gwb(0)),
                                                WidgetSpan(
                                                    child: gwb(
                                                        controller.deliveryType ==
                                                                    0 &&
                                                                !isDefalut
                                                            ? 0
                                                            : 10)),
                                                TextSpan(
                                                    text: controller.address[
                                                            "recipient"] ??
                                                        ""),
                                                WidgetSpan(child: gwb(8)),
                                                TextSpan(
                                                    text: controller.address[
                                                            "recipientMobile"] ??
                                                        ""),
                                              ]),
                                          maxLines: 2,
                                        ),
                                      ),
                                      Image.asset(
                                        assetsName(
                                            "product_store/cell_arrow_right"),
                                        width: 18.w,
                                        fit: BoxFit.fitWidth,
                                      )
                                    ], width: 345 - 9.5 * 2),
                                    ghb(15),
                                    getWidthText(
                                        "${controller.address["provinceName"] ?? ""}${controller.address["cityName"] ?? ""}${controller.address["areaName"] ?? ""}${controller.address["address"] ?? ""}",
                                        12,
                                        AppColor.textGrey,
                                        345 - 18.5 * 2,
                                        3)
                                  ]),
                          )
                        ],
                      );
                    }),
                    Image.asset(
                      assetsName("common/line2"),
                      width: 345.w,
                      height: 3.w,
                      fit: BoxFit.fill,
                    )
                  ], height: 165),
                ),
              )),
          GetX<ProductStoreConfirmController>(
            builder: (_) {
              return Positioned(
                  top: 0,
                  left: controller.deliveryType == 0 ? 0 : null,
                  right: controller.deliveryType == 1 ? 0 : null,
                  height: 46.w,
                  width: 182.w,
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                        left: controller.deliveryType == 0 ? 0 : 5.5.w,
                        right: controller.deliveryType == 1 ? 0 : 5.5.w),
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: AssetImage(assetsName(
                                "product_store/btn_address_${controller.deliveryType == 0 ? "left" : "right"}")))),
                    child: getSimpleText(
                        controller.deliveryType == 0 ? "快递配送" : "网点自提",
                        18,
                        AppColor.textBlack,
                        isBold: true),
                  ));
            },
          )
        ],
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
      child: GetX<ProductStoreConfirmController>(
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
}
