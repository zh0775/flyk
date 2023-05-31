import 'dart:async';

import 'package:cxhighversion2/component/bottom_paypassword.dart';
import 'package:cxhighversion2/component/custom_alipay.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_input.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/main.dart';
import 'package:cxhighversion2/mine/mine_address_manager.dart';
import 'package:cxhighversion2/product/product_store/product_store_list.dart';
import 'package:cxhighversion2/product/product_store/product_store_order_detail.dart';
import 'package:cxhighversion2/product/product_store/product_store_order_list.dart';
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

  cursorToEnd() {
    numInputCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: numInputCtrl.text.length));
  }

  final Map<String, Timer> _funcDebounce = {};
  // 防抖
  void debounce({
    int timeout = 500,
    Function? target,
  }) {
    String key = hashCode.toString();
    Timer? timer = _funcDebounce[key];
    timer?.cancel();
    timer = Timer(Duration(milliseconds: timeout), () {
      Timer? t = _funcDebounce.remove(key);
      t?.cancel();
      target?.call();
    });
    _funcDebounce[key] = timer;
  }

  int levelType = 1;

  final _currentCount = 1.obs;
  set currentCount(v) {
    if (_currentCount.value != v) {
      _currentCount.value = v;
      debounce(
          target: () {
            loadPreviewOrder();
          },
          timeout: 1000);
      numInputCtrl.text = "$currentCount";
      cursorToEnd();
    }
  }

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
    // Map<String, dynamic> params = {
    //   "delivery_Method": deliveryType + 1,
    //   "levelConfigId": productData["levelGiftId"],
    //   "num": currentCount,
    //   "contactID": address["id"] ?? 0,
    //   "pay_MethodType":
    //       int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
    //   "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}")
    // };
    List orderContent = [
      {"id": productData["levelGiftId"], "num": currentCount}
    ];

    simpleRequest(
      url: Urls.previewOrder,
      params: {"orderContent": orderContent},
      success: (success, json) {
        if (success) {
          previewOrderData = json["data"];
          update([confirmButtonBuildId]);
        }
      },
      after: () {},
    );
  }

  loadPayOrderDetail(Map orderInfo,
      {Function(Map orderData)? loadOrderDetailCallBack}) {
    simpleRequest(
      url: Urls.userLevelGiftOrderShow(orderInfo["id"]),
      params: {},
      success: (success, json) {
        if (success) {
          Map orderData = json["data"];
          if (loadOrderDetailCallBack != null) {
            loadOrderDetailCallBack(orderData);
          }
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
      "purchase_Type": 1,
      "pay_MethodType":
          int.parse("${payTypeList[currentPayTypeIndex]["u_Type"]}"),
      "pay_Method": int.parse("${payTypeList[currentPayTypeIndex]["value"]}"),
      "version_Origin": AppDefault().versionOriginForPay(),
      // "u_3nd_Pad": payPwd,
      "user_Remarks": remarkInputCtrl.text,
      "orderContent": [
        {"id": productData["levelGiftId"], "num": currentCount}
      ]
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
          String aliDataStr = data["aliData"] ?? "";
          if (payData["u_Type"] == 1) {
            if (payData["value"] == 1) {
              //支付宝
              if (aliDataStr.isEmpty) {
                ShowToast.normal("支付失败，请稍后再试");
                return;
              }
              Map aliData = await CustomAlipay().payAction(
                aliDataStr,
                payBack: () {
                  loadPayOrderDetail(
                    orderInfo,
                    loadOrderDetailCallBack: (orderData) {
                      push(
                          ProductStorePayResult(
                            success: (orderData["orderState"] ?? 0) != 0,
                            orderData: orderData,
                            levelType: levelType,
                            contentTitle: (orderData["orderState"] ?? 0) != 0
                                ? "支付订单金额为￥${priceFormat(previewOrderData["pay_Amount"] ?? 0)}"
                                : "",
                          ),
                          Global.navigatorKey.currentContext!);
                    },
                  );
                },
              );
              if (!kIsWeb) {
                loadPayOrderDetail(
                  orderInfo,
                  loadOrderDetailCallBack: (orderData) {
                    push(
                        ProductStorePayResult(
                          success: aliData["resultStatus"] == "9000",
                          orderData: orderData,
                          levelType: levelType,
                          contentTitle: aliData["resultStatus"] == "9000"
                              ? "支付订单金额为￥${priceFormat(previewOrderData["pay_Amount"] ?? 0)}"
                              : "",
                        ),
                        Global.navigatorKey.currentContext!);
                  },
                );
              }
            }
          } else if (payData["u_Type"] != 1) {
            loadPayOrderDetail(
              orderInfo,
              loadOrderDetailCallBack: (orderData) {
                push(
                    ProductStorePayResult(
                      success: success,
                      orderData: orderData,
                      levelType: levelType,
                      contentTitle: success
                          ? "支付订单金额为￥${priceFormat(previewOrderData["pay_Amount"] ?? 0)}"
                          : "",
                    ),
                    Global.navigatorKey.currentContext!);
              },
            );
          }
        } else {
          push(
              ProductStorePayResult(
                success: success,
                levelType: levelType,
                contentTitle: success
                    ? "支付订单金额为￥${priceFormat(previewOrderData["pay_Amount"] ?? 0)}"
                    : json["messages"] ?? "",
              ),
              Global.navigatorKey.currentContext!);
        }
      },
      after: () {},
    );
  }

  // 是否为现金商品
  bool isReal = true;

  // 支付密码组件
  late BottomPayPassword bottomPayPassword;

  int minCount = 1;

  numNodeListener() {
    if (!numNode.hasFocus) {
      if (numInputCtrl.text.isEmpty) {
        ShowToast.normal("最少购买$minCount件哦");
        numInputCtrl.text = "$minCount";
        cursorToEnd();
        return;
      }
      if (int.tryParse(numInputCtrl.text) == null) {
        ShowToast.normal("请输入正确的数量");
        numInputCtrl.text = "$minCount";
        cursorToEnd();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        cursorToEnd();
      });
    }
  }

  numInputListener() {
    int? tNum = int.tryParse(numInputCtrl.text);
    if (tNum != null) {
      _currentCount.value = tNum;
      debounce(
          target: () {
            loadPreviewOrder();
          },
          timeout: 1000);
    }
  }

  @override
  void onReady() {
    Future.delayed(const Duration(milliseconds: 300), () {
      loadAddress();
    });
    super.onReady();
  }

  @override
  void onInit() {
    numNode.addListener(numNodeListener);
    numInputCtrl.addListener(numInputListener);
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
    numInputCtrl.text = "$currentCount";

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
    numNode.removeListener(numNodeListener);
    numInputCtrl.removeListener(numInputListener);
    numNode.dispose();
    numInputCtrl.dispose();
    super.onClose();
  }
}

class ProductStoreConfirm extends GetView<ProductStoreConfirmController> {
  const ProductStoreConfirm({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, "确认订单"),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Image.asset(
                  assetsName("product_store/bg_confirm_view_top"),
                  width: 375.w,
                  height: 210.w,
                  fit: BoxFit.fill),
            ),
            Positioned.fill(
              bottom: 60.w + paddingSizeBottom(context),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // 快递地址
                    deliveryInfoView(context),
                    // 商品信息视图
                    productInfoView(),
                    // 订单预览数据视图
                    preOrderInfoView(),
                    // SizedBox(height: 75.w + paddingSizeBottom(context)),
                    ghb(15)
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60.w + paddingSizeBottom(context),
                child: CustomButton(
                  onPressed: () {
                    if (controller.previewOrderData.isEmpty) {
                      ShowToast.normal("正在获取数据，请稍等...");
                      return;
                    }
                    showPayChoose(context);
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 345.w,
                        height: 45.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.w),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFD573B),
                                  Color(0xFFFF3A3A)
                                ])),
                        child: getSimpleText("提交订单", 16, Colors.white),
                      ),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

// 订单预览数据视图
  Widget preOrderInfoView() {
    return GetBuilder<ProductStoreConfirmController>(
        id: controller.confirmButtonBuildId,
        builder: (_) {
          return Container(
            width: 345.w,
            padding: EdgeInsets.symmetric(vertical: 5.w),
            decoration: getDefaultWhiteDec(radius: 8),
            margin: EdgeInsets.only(top: 15.w),
            child: GetX<ProductStoreConfirmController>(builder: (_) {
              bool isReal = controller.levelType != 3;
              bool isBean = false;
              String beanName = "";
              // 如果是兑换商城，判断是否使用豆支付
              if (controller.levelType == 3) {
                List payTypes = convert.jsonDecode(
                    controller.productData["levelGiftPaymentMethod"]);
                if (payTypes.isNotEmpty &&
                    payTypes.length == 1 &&
                    (payTypes[0]["value"] ?? 0) == 5) {
                  isBean = true;
                }
                beanName = "";
                List wallets = AppDefault().homeData["u_Account"] ?? [];
                //获取豆名称
                for (var e in wallets) {
                  if ((e["a_No"] ?? 0) == 5) {
                    beanName = e["name"] ?? "";
                    break;
                  }
                }
              }
              return Column(
                children: [
                  ...List.generate(4, (index) {
                    return sbhRow([
                      getSimpleText(
                          index == 0
                              ? "商品金额"
                              : index == 1
                                  ? "运费"
                                  : index == 2
                                      ? "商品数量"
                                      : "合计",
                          14,
                          AppColor.textBlack),
                      index != 3
                          ? getSimpleText(
                              index == 0
                                  ? "${isReal ? "￥" : ""}${priceFormat((controller.productData["nowPrice"] ?? 0) * controller.currentCount)}${isReal ? "" : isBean ? beanName : "积分"}"
                                  : index == 1
                                      ? (controller.previewOrderData[
                                                      "pay_Freight"] ??
                                                  0) <=
                                              0
                                          ? "包邮"
                                          : "${isReal ? "￥" : ""}${priceFormat(controller.previewOrderData["pay_Freight"] ?? 0)}${isReal ? "" : isBean ? beanName : "积分"}"
                                      : "${controller.previewOrderData["num"] ?? 1}",
                              14,
                              AppColor.textBlack)
                          : getRichText(
                              isReal ? "￥" : "",
                              "${priceFormat(controller.previewOrderData["pay_Amount"] ?? 0)}${isReal ? "" : isBean ? beanName : "积分"}",
                              12,
                              const Color(0xFFFE4B3B),
                              18,
                              const Color(0xFFFE4B3B),
                              isBold2: true),
                    ], width: 315, height: 45);
                  })
                ],
              );
            }),
          );
        });
  }

  // 快递地址
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
                      // 是否默认地址
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
                                // 选择邮寄/自提
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
                          //前往地址管理页面
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
                            // 没有设置地址
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
          // 顶部切换标签
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

  // 商品信息视图
  Widget productInfoView() {
    bool isReal = controller.levelType != 3;
    bool isBean = false;
    String beanName = "";
    // 如果是兑换商城，判断是否使用豆支付
    if (controller.levelType == 3) {
      List payTypes =
          convert.jsonDecode(controller.productData["levelGiftPaymentMethod"]);
      if (payTypes.isNotEmpty &&
          payTypes.length == 1 &&
          (payTypes[0]["value"] ?? 0) == 5) {
        isBean = true;
      }
      beanName = "";
      List wallets = AppDefault().homeData["u_Account"] ?? [];
      //获取豆名称
      for (var e in wallets) {
        if ((e["a_No"] ?? 0) == 5) {
          beanName = e["name"] ?? "";
          break;
        }
      }
    }
    return Container(
      width: 345.w,
      decoration: getDefaultWhiteDec(radius: 8),
      margin: EdgeInsets.only(top: 15.w),
      child: Column(
        children: [
          ghb(15),
          sbRow([
            centRow([
              CustomNetworkImage(
                  src: AppDefault().imageUrl +
                      (controller.productData["levelGiftImg"] ?? ""),
                  width: 105.w,
                  height: 105.w,
                  fit: BoxFit.fill),
              gwb(12),
              sbClm([
                getWidthText(controller.productData["levelName"] ?? "", 15,
                    AppColor.textBlack, 315 - 105 - 12, 2,
                    isBold: true),
                getRichText(
                    isReal ? "￥" : "",
                    "${priceFormat(controller.productData["nowPrice"] ?? 0)}${isReal ? "" : isBean ? beanName : "积分"}",
                    12,
                    const Color(0xFFFE4B3B),
                    18,
                    const Color(0xFFFE4B3B),
                    isBold2: true),
              ], height: 105, crossAxisAlignment: CrossAxisAlignment.start),
            ])
          ], width: 345 - 15 * 2),
          sbhRow([
            getSimpleText("数量", 14, AppColor.textBlack),
            // 数量选择器
            Container(
                width: 91.w,
                height: 25.w,
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    border: Border.all(width: 0.5.w, color: AppColor.lineColor),
                    borderRadius: BorderRadius.circular(25.w / 2)),
                child: centRow(List.generate(
                    3,
                    (index) => index == 1
                        ? Container(
                            width: 40.w,
                            height: 21.w,
                            color: Colors.white,
                            child: CustomInput(
                              width: 40.w,
                              heigth: 21.w,
                              placeholder: "数量",
                              placeholderStyle: TextStyle(
                                  fontSize: 15.sp, color: AppColor.textGrey5),
                              style: TextStyle(
                                  fontSize: 15.sp, color: AppColor.textBlack),
                              textAlignVertical: TextAlignVertical.center,
                              textAlign: TextAlign.center,
                              focusNode: controller.numNode,
                              keyboardType: TextInputType.number,
                              textEditCtrl: controller.numInputCtrl,
                            ))
                        : CustomButton(
                            onPressed: () {
                              if (index == 0) {
                                if (controller.currentCount <= 1) {
                                  ShowToast.normal("最少购买一件");
                                  return;
                                }
                                controller.currentCount -= 1;
                              } else {
                                controller.currentCount += 1;
                              }
                            },
                            child: GetX<ProductStoreConfirmController>(
                                builder: (_) {
                              int myNum = controller.currentCount;
                              return SizedBox(
                                width: 25.w - 0.1.w,
                                height: 21.w,
                                child: Center(
                                  child: getSimpleText(
                                      index == 0 ? "⏤" : "+",
                                      index == 0 ? 9 : 12,
                                      index == 0 && myNum <= 1
                                          ? AppColor.textGrey5
                                          : AppColor.textBlack),
                                ),
                              );
                            }),
                          ))))
          ], width: 315, height: 54.5),
          gline(315, 0.5),
          ghb(15),
          sbhRow([getSimpleText("备注", 14, AppColor.textBlack)],
              width: 315, height: 30),
          Container(
            width: 315.w,
            height: 60.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(4.w)),
            child: CustomInput(
              width: 315.w - 10.w * 2,
              heigth: 60.w - 6.w * 2,
              placeholder: "请输入留言",
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.top,
              textEditCtrl: controller.remarkInputCtrl,
              style: TextStyle(fontSize: 14.sp, color: AppColor.textBlack),
              placeholderStyle:
                  TextStyle(fontSize: 14.sp, color: AppColor.assisText),
              maxLines: 100,
            ),
          ),
          ghb(18),
        ],
      ),
    );
  }

  // 底部model，需订单预览数据
  void showPayChoose(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modelBottomCtx) {
        return Container(
          width: 375.w,
          height: 53.5.w +
              98.5.w +
              controller.payTypeList.length * 45.w +
              60.w +
              15.w +
              paddingSizeBottom(context),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(6.w))),
          child: StatefulBuilder(builder: (context, setModalBottomState) {
            return Column(
              children: [
                sbhRow([
                  gwb(42),
                  getSimpleText("选择支付方式", 18, AppColor.textBlack, isBold: true),
                  CustomButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: SizedBox(
                      width: 42.w,
                      height: 53.w,
                      child: Center(
                          child: Image.asset(
                              assetsName(
                                  "statistics_page/btn_bottom_model_close"),
                              width: 18.w,
                              height: 18.w,
                              fit: BoxFit.fill)),
                    ),
                  )
                ], width: 375, height: 53),
                gline(375, 0.5),
                SizedBox(
                  height: 98.w,
                  child: Center(
                    child: centClm([
                      getSimpleText(
                        "应付金额(${controller.isReal ? "元" : controller.payTypeList[controller.currentPayTypeIndex]["name"] ?? ""})",
                        14,
                        AppColor.textGrey5,
                      ),
                      ghb(3),
                      Visibility(
                          visible: controller.previewOrderData != null &&
                              controller.previewOrderData.isNotEmpty,
                          child: GetBuilder<ProductStoreConfirmController>(
                            init: controller,
                            id: controller.confirmButtonBuildId,
                            initState: (_) {},
                            builder: (_) {
                              return getSimpleText(
                                  priceFormat(controller
                                          .previewOrderData["pay_Amount"] ??
                                      0),
                                  30,
                                  AppColor.textBlack,
                                  isBold: true);
                            },
                          )),
                    ]),
                  ),
                ),
                ...controller.payTypeList
                    .asMap()
                    .entries
                    .map((e) => GetX<ProductStoreConfirmController>(
                          builder: (_) {
                            return CustomButton(
                              onPressed: () {
                                controller.currentPayTypeIndex = e.key;
                                controller.loadPreviewOrder();
                              },
                              child: sbhRow([
                                centRow([
                                  Image.asset(
                                      assetsName(
                                          "statistics_page/icon_pay_${e.value["value"] == 1 ? "alipay" : e.value["value"] == 2 ? "wx" : "ye"}"),
                                      width: 24.w,
                                      height: 24.w,
                                      fit: BoxFit.fill),
                                  gwb(8),
                                  getSimpleText(
                                      e.value["name"], 14, AppColor.textBlack),
                                ]),
                                Image.asset(
                                  assetsName(
                                      "statistics_page/icon_selectpay_${controller.currentPayTypeIndex == e.key ? "selected" : "normal"}"),
                                  width: 21.w,
                                  height: 21.w,
                                  fit: BoxFit.fill,
                                )
                              ], width: 375 - 15 * 2, height: 45),
                            );
                          },
                        ))
                    .toList(),
                ghb(15),
                CustomButton(
                  onPressed: () {
                    Navigator.pop(modelBottomCtx, () {});
                  },
                  child: getSubmitBtn("确认支付", () {
                    Get.back();
                    controller.payAction();
                  },
                      width: 345,
                      height: 45,
                      fontSize: 15,
                      linearGradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFFD573B), Color(0xFFFF3A3A)])),
                )
              ],
            );
          }),
        );
      },
    );
  }
}

class ProductStorePayResult extends StatelessWidget {
  final bool success;
  final String title;
  final String contentTitle;
  final String content;
  final Map orderData;
  final int levelType;
  const ProductStorePayResult(
      {super.key,
      this.success = true,
      this.title = "",
      this.contentTitle = "",
      this.content = "",
      this.levelType = 1,
      this.orderData = const {}});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getDefaultAppBar(
        context,
        title,
        backPressed: () {
          Get.until((route) => route is GetPageRoute
              ? route.binding is ProductStoreListBinding ||
                      route.binding is MainPageBinding
                  ? true
                  : false
              : false);
        },
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            gwb(375),
            ghb(61.5),
            Image.asset(
                assetsName(
                    "product_store/icon_pay_${success ? "success" : "fail"}"),
                width: 200.w,
                height: 200.w,
                fit: BoxFit.fill),
            ghb(9),
            getSimpleText(
                contentTitle.isEmpty
                    ? success
                        ? "支付成功"
                        : "支付失败"
                    : contentTitle,
                18,
                AppColor.textBlack,
                isBold: true,
                textHeight: 1.0),
            ghb(12),
            getSimpleText(
                content.isEmpty
                    ? success
                        ? ""
                        : "抱歉，订单支付失败，请重新支付"
                    : content,
                14,
                AppColor.textGrey5,
                textHeight: 1.0),
            ghb(50),
            getSubmitBtn(success ? "查看订单" : "重新支付", () {
              if (success) {
                Map arguments = {
                  "levelType": levelType,
                };
                if (orderData.isNotEmpty) {
                  arguments["data"] = orderData;
                }
                Get.offUntil(
                    GetPageRoute(
                        page: () => orderData.isEmpty
                            ? ProductStoreOrderList(
                                levelType: levelType,
                              )
                            : const ProductStoreOrderDetail(
                                data: {},
                              ),
                        binding: orderData.isEmpty
                            ? ProductStoreOrderListBinding()
                            : ProductStoreOrderDetailBinding(),
                        settings: RouteSettings(
                            name: orderData.isEmpty
                                ? "ProductStoreOrderList"
                                : "ProductStoreOrderDetail",
                            arguments: arguments)),
                    (route) => route is GetPageRoute
                        ? route.binding is ProductStoreListBinding ||
                                route.binding is MainPageBinding
                            ? true
                            : false
                        : false);
              } else {
                Get.back();
              }
            },
                width: 300,
                height: 45,
                fontSize: 15,
                linearGradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFD573B), Color(0xFFFF3A3A)])),
            ghb(15),
            CustomButton(
              onPressed: () {
                Get.until((route) => route is GetPageRoute
                    ? route.binding is ProductStoreListBinding ||
                            route.binding is MainPageBinding
                        ? true
                        : false
                    : false);
              },
              child: Container(
                width: 300.w,
                height: 45.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 0.5.w, color: AppColor.theme),
                    borderRadius: BorderRadius.circular(45.w / 2)),
                child: getSimpleText("返回商城首页", 15, AppColor.theme),
              ),
            )
          ],
        ),
      ),
    );
  }
}
