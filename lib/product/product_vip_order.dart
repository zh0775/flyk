import 'dart:async';
import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:cxhighversion2/component/custom_button.dart';
import 'package:cxhighversion2/component/custom_network_image.dart';
import 'package:cxhighversion2/product/component/product_order_cell.dart';
import 'package:cxhighversion2/product/component/update_order_button.dart';
import 'package:cxhighversion2/product/product_confirm_order.dart';
import 'package:cxhighversion2/service/urls.dart';
import 'package:cxhighversion2/util/app_default.dart';
import 'package:cxhighversion2/util/toast.dart';
import 'package:cxhighversion2/util/tools.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProductVipOrderBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<ProductVipOrderController>(ProductVipOrderController());
  }
}

class ProductVipOrderController extends GetxController {
  bool isFirst = true;

  late StreamSubscription<bool> keyboardSubscription;

  String selectedBuildId = "ProductVipOrder_selectedBuildId";
  String productSelectedListId = "ProductVipOrder_productSelectedListId";
  String productSelectedListCellId =
      "ProductVipOrder_productSelectedListCellId";

  final _productDatas = Rx<List>([]);
  List get productDatas => _productDatas.value;
  set productDatas(v) => _productDatas.value = v;

  final _realProductDatas = Rx<List>([]);
  get realProductDatas => _realProductDatas.value;
  set realProductDatas(v) => _realProductDatas.value = v;
  String bottomUnit = "";

  List vipDatas = [];

  Map payType = {};
  Map productData = {};

  int productAllCount = 1;
  int productCurrentCount = 1;

  final _haveSelectProduct = true.obs;
  get haveSelectProduct => _haveSelectProduct.value;
  set haveSelectProduct(v) => _haveSelectProduct.value = v;

  List levelSelect = [];
  int selectType = 1;
  String warningStr = "";

  warningStrFormat() {
    if (productCurrentCount < productAllCount) {
      warningStr = "*提交订单需采购$productAllCount台";
    } else {
      warningStr = "";
    }
    update([confirmButtonBuildId]);
  }

  selectedProductAction(Map data, int index) {
    if (!data["selected"] && productCurrentCount >= productAllCount) {
      ShowToast.normal("超出采购数量范围，请减少已选购数量再添加产品");
      return;
    }
    if (selectType == 1) {
      ShowToast.normal("该礼包为固定设备，无法修改");
      return;
    } else if (selectType == 3) {
      if (data["minCount"] > 0) {
        ShowToast.normal("该设备需最少选择${data["minCount"]}台");
      }
      return;
    }
    data["selected"] = !data["selected"];
    if (data["selected"]) {
      data["count"] = 1;
    } else {
      data["count"] = 0;
    }

    bool haveSelected = false;
    productCurrentCount = 0;
    for (var item in productDatas) {
      productCurrentCount += (item["count"] as int);
      if (item["selected"]) {
        haveSelected = true;
      }
    }
    warningStrFormat();
    haveSelectProduct = haveSelected;
    update([selectedBuildId, productSelectedListId]);
  }

  productsCountChange(int count, int idx, {bool? isAdd}) {
    if (productDatas == null ||
        productDatas.isEmpty ||
        (productDatas.length - 1) < idx ||
        productDatas[idx].isEmpty) {
      return;
    }
    Map tmp = productDatas[idx];
    // if (productCurrentCount <= 1 && !isAdd) {
    //   ShowToast.normal("选中的产品数量不能小于一个");
    //   return;
    // }
    int maxCount = tmp["maxCount"] ?? 1000;
    int minCount = tmp["minCount"] ?? -1;

    warningStrFormat();
    if (isAdd != null) {
      if (selectType == 2 && !isAdd && count <= minCount) {
        ShowToast.normal("该礼包限制此设备最少${tmp["minCount"]}台");
        return;
      }

      if (selectType == 2 && isAdd && count >= maxCount) {
        ShowToast.normal("该礼包限制此设备最多${tmp["maxCount"]}台");
        return;
      }

      if (tmp["count"] <= 1 && !isAdd) {
        selectedProductAction(tmp, idx);
        return;
      }
      if (productCurrentCount >= productAllCount && isAdd) {
        ShowToast.normal("超出采购数量范围");
        return;
      }
      isAdd ? tmp["count"]++ : tmp["count"]--;
      isAdd ? productCurrentCount++ : productCurrentCount--;
    } else {
      if (selectType == 2 && count < minCount) {
        ShowToast.normal("该礼包限制此设备最少${tmp["minCount"]}台");
        buildCountSelectCell(idx);
        return;
      }
      if (selectType == 2 && count > maxCount) {
        ShowToast.normal("该礼包限制此设备最多${tmp["maxCount"]}台");
        buildCountSelectCell(idx);
        return;
      }
      if (tmp["count"] <= 1 && count == 0) {
        selectedProductAction(tmp, idx);
        buildCountSelectCell(idx);
        return;
      }
      int tmpCount = 0;
      for (var i = 0; i < productDatas.length; i++) {
        Map e = productDatas[i];
        if (i != idx) {
          tmpCount += (e["count"] as int);
        }
      }
      tmpCount += count;
      if (tmpCount > productAllCount) {
        ShowToast.normal("超出采购数量范围");
        buildCountSelectCell(idx);
        return;
      }
      tmp["count"] = count;
      productCurrentCount = tmpCount;
    }
    buildCountSelectCell(idx);
  }

  buildCountSelectCell(int idx) {
    String buildID = "${productSelectedListCellId}_$idx";
    warningStrFormat();
    update([buildID]);
  }

  final _showPrice = true.obs;
  get showPrice => _showPrice.value;
  set showPrice(v) => _showPrice.value = v;

  final _defaultPayIndex = 0.obs;
  int get defaultPayIndex => _defaultPayIndex.value;
  set defaultPayIndex(v) => _defaultPayIndex.value = v;
  List payList = [];
  String confirmButtonBuildId = "ProductVipOrder_confirmButtonBuildId";
  Map previewOrderData = {};

  loadPreviewOrder() {
    simpleRequest(
      url: Urls.previewOrder,
      params: {
        // "delivery_Method": deliveryType + 1,
        // "levelType": 1,
        "levelTeamId": productData["teamId"],
        "levelConfigId": payType["levelGiftId"],
        "num": 1,
        "contactID": 0,
        "pay_MethodType": int.parse("${payList[defaultPayIndex]["u_Type"]}"),
        "pay_Method": int.parse("${payList[defaultPayIndex]["value"]}"),
      },
      success: (success, json) {
        if (success) {
          previewOrderData = json["data"];
          update([confirmButtonBuildId]);
        }
      },
      after: () {},
    );
  }

  dataInit(pType, pData) {
    if (!isFirst) {
      return;
    }
    isFirst = false;
    payType = pType;
    if (payType != null && payType.isNotEmpty) {
      payList = convert.jsonDecode(payType["levelGiftPaymentMethod"]);
      levelSelect = convert.jsonDecode(payType["levelSelectJson"]);
      selectType = payType["levelSelectType"];
    }
    productData = pData;
    productCurrentCount = 0;
    productDatas =
        payType["productList"] != null && payType["productList"].isNotEmpty
            ? (payType["productList"] as List).asMap().entries.map((e) {
                Map selectData = {};
                for (var item in levelSelect) {
                  if (item["terminalConfigId"] == e.value["id"]) {
                    selectData = item;
                    break;
                  }
                }
                Map tmp = {
                  ...e.value,
                  "selected": e.key == 0 ? true : false,
                  "count": e.key == 0 ? 1 : 0,
                };
                if (selectData.isNotEmpty) {
                  if (selectData["minCount"] != null) {
                    tmp["minCount"] = selectData["minCount"];
                  }
                  if (selectData["maxCount"] != null) {
                    tmp["maxCount"] = selectData["maxCount"];
                  }
                }
                if (selectType == 1) {
                  tmp["selected"] = true;
                  tmp["count"] = selectData["minCount"];
                  productCurrentCount += (tmp["count"] as int);
                } else if (selectType == 2) {
                  tmp["selected"] = (e.key == 0 ? true : false);
                  tmp["count"] = (e.key == 0 ? 1 : 0);
                  productCurrentCount = 1;
                } else if (selectType == 3) {
                  tmp["count"] = selectData["minCount"];
                  tmp["selected"] = (tmp["count"] > 0);
                  productCurrentCount += (tmp["count"] as int);
                }

                return tmp;
              }).toList()
            : [];

    productAllCount = productData["levelTotalNum"] ?? 1;
    warningStrFormat();
    realProductDatas = productDatas;
    for (var i = 0; i < productDatas.length; i++) {
      vipDatas
          .add({"count": i == 0 ? 1 : 0, "price": productDatas[i]["price"]});
    }
    loadPreviewOrder();
  }

  bool keybordVisible = false;
  @override
  void onInit() {
    super.onInit();
    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      keybordVisible = visible;
    });
  }
}

class ProductVipOrder extends GetView<ProductVipOrderController> {
  final String? title;
  final Map payType;
  final Map productData;

  const ProductVipOrder({
    Key? key,
    this.title,
    required this.payType,
    required this.productData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.dataInit(payType, productData);
    return GestureDetector(
      onTap: () => takeBackKeyboard(context),
      child: Scaffold(
        appBar: getDefaultAppBar(context, title ?? ""),
        body: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: controller.warningStr.isNotEmpty ? 155.w : 125.w,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ghb(20),
                    ghb(controller.productDatas.isNotEmpty ? 20 : 0),
                    GetX<ProductVipOrderController>(
                      init: controller,
                      builder: (controller) {
                        return Visibility(
                          visible: controller.productDatas.isNotEmpty,
                          child: getSimpleText("选择其他产品", 15, AppColor.textBlack,
                              isBold: true),
                        );
                      },
                    ),
                    GetX<ProductVipOrderController>(
                        init: controller,
                        builder: (controller) {
                          return ghb(
                              controller.productDatas.isNotEmpty ? 20 : 0);
                        }),
                    GetX<ProductVipOrderController>(
                      init: controller,
                      initState: (_) {},
                      builder: (_) {
                        return Visibility(
                          visible: controller.productDatas.isNotEmpty,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.w),
                            width: 345.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.w),
                                color: Colors.white),
                            child: Center(
                              child: SizedBox(
                                width: 345.w,
                                child: Wrap(
                                    spacing: 13.w,
                                    runSpacing: 3.w,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.center,
                                    children: productSelectButton(context)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    GetX<ProductVipOrderController>(
                      init: controller,
                      builder: (controller) {
                        return ghb(controller.productDatas.isNotEmpty &&
                                controller.haveSelectProduct
                            ? 20
                            : 0);
                      },
                    ),
                    // GetX<ProductVipOrderController>(
                    //   init: controller,
                    //   builder: (_) {
                    //     return getSimpleText(
                    //         "已选${controller.productDatas.isNotEmpty ? "礼包" : "产品"}",
                    //         15,
                    //         AppColor.textBlack,
                    //         isBold: true);
                    //   },
                    // ),
                    GetBuilder<ProductVipOrderController>(
                      init: controller,
                      id: controller.productSelectedListId,
                      builder: (_) {
                        return controller.productDatas.isNotEmpty &&
                                controller.haveSelectProduct
                            ? centClm([
                                getSimpleText("选择设备", 15, AppColor.textBlack,
                                    isBold: true),
                                ghb(20),
                                centClm((controller.productDatas as List)
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return GetBuilder<ProductVipOrderController>(
                                    init: controller,
                                    id: "${controller.productSelectedListCellId}_${e.key}",
                                    builder: (_) {
                                      return e.value["selected"]
                                          ? Container(
                                              margin: EdgeInsets.only(
                                                  bottom: e.key !=
                                                          controller
                                                                  .productDatas
                                                                  .length -
                                                              1
                                                      ? 15.w
                                                      : 0),
                                              child: ProductOrderCell(
                                                cellData: e.value,
                                                name: e.value["terminalName"],
                                                dec: e.value["terminalMod"],
                                                imgSrc: e.value["terminalImg"],
                                                inputCount: true,
                                                index: e.key,
                                                haveCount:
                                                    controller.selectType == 1
                                                        ? false
                                                        : true,
                                                defaultCount: e.value["count"],
                                                changeCountAction: (count, idx,
                                                    {isAdd}) {
                                                  controller
                                                      .productsCountChange(
                                                          count, idx,
                                                          isAdd: isAdd);
                                                },
                                              ),
                                            )
                                          : const SizedBox();
                                    },
                                  );
                                }).toList()),

                                // ghb(20),
                              ], crossAxisAlignment: CrossAxisAlignment.start)
                            : ghb(0);
                      },
                    ),
                    ghb(20),
                    // getSimpleText("礼包产品", 15, AppColor.textBlack, isBold: true),
                    // ghb(20),
                    // ProductOrderCell(
                    //   cellData: productData,
                    //   name: payType["levelName"],
                    //   dec: payType["levelDescribe"],
                    //   imgSrc: payType["levelGiftImg"],
                    //   price: controller.showPrice
                    //       ? priceFormat(payType["nowPrice"])
                    //       : null,
                    //   index: 0,
                    //   maxCount: 1,
                    //   errText: "礼包产品一次最多购买一份",
                    //   // haveCount: controller.productDatas.isNotEmpty,
                    //   haveCount: false,
                    //   defaultCount: 1,
                    //   changeCountAction: (count, idx, isAdd) {
                    //     // setState(() {
                    //     //   isAdd ? currentCount++ : currentCount--;
                    //     // });

                    //     if (isAdd && count == 1) {
                    //       ShowToast.normal("礼包产品一次最多购买一份");
                    //     }
                    //   },
                    // ),
                    // ghb(25)
                  ],
                ),
              ),
            ),
          ),
          GetBuilder<ProductVipOrderController>(
            init: controller,
            id: controller.confirmButtonBuildId,
            initState: (_) {},
            builder: (_) {
              return Positioned(
                  left: 0,
                  right: 0,
                  height: controller.warningStr.isNotEmpty ? 155.w : 125.w,
                  bottom: 0,
                  child: UpdateOrderButton(
                    productData: controller.productData,
                    buttonTitle: "确认订单",
                    warningStr: controller.warningStr,
                    count: 0,
                    freight: controller.previewOrderData != null &&
                            controller.previewOrderData.isNotEmpty
                        ? controller.previewOrderData["pay_Freight"]
                        : null,
                    yfUnit: controller.previewOrderData.isNotEmpty
                        ? (controller.previewOrderData["pay_MethodType"] == 1
                            ? "元"
                            : "")
                        : "",
                    unit: controller.previewOrderData.isNotEmpty
                        ? (controller.previewOrderData["pay_MethodType"] == 1
                            ? "元"
                            : "")
                        : "",
                    price: controller.previewOrderData != null &&
                            controller.previewOrderData.isNotEmpty
                        ? controller.previewOrderData["pay_Amount"]
                        : null,
                    confirmAndUpdateOrder: () {
                      if (controller.keybordVisible) {
                        takeBackKeyboard(context);
                        return;
                      }
                      if (controller.productDatas.isNotEmpty &&
                          controller.productCurrentCount <
                              controller.productAllCount) {
                        ShowToast.normal(
                            "礼包产品选择数量不够${controller.productAllCount}台，请继续选择");
                        return;
                      }
                      if (!controller.haveSelectProduct) {
                        ShowToast.normal("请先至少选择一款产品");
                        return;
                      }
                      push(
                          ProductConfirmOrder(
                              productDatas: controller.productDatas,
                              productData: productData,
                              isBag: true,
                              payType: payType),
                          context,
                          binding: ProductConfirmOrderBinding());

                      // showPayChoose();
                    },
                  ));
            },
          ),
        ]),
      ),
    );
  }

  int getTotalCount() {
    int count = 0;
    for (var e in controller.vipDatas) {
      count += (e["count"] as int);
    }
    return count;
  }

  double getTotalPrice() {
    double price = 0;
    for (var e in controller.vipDatas) {
      price += e["count"] * e["price"];
    }
    return price;
  }

  List<ProductOrderCell> getSelectedProducts() {
    List<ProductOrderCell> widgets = [];
    for (var i = 0; i < controller.productDatas.length; i++) {
      Map data = controller.productDatas[i];
      // widgets.add(ProductOrderCell(
      //   index: i,
      //   defaultCount: 1,
      //   cellData: data,
      //   maxCount: 1,

      //   changeCountAction: (count, idx, isAdd) {},
      // ));
    }
    return widgets;
  }

  List<Widget> productSelectButton(BuildContext context) {
    List<Widget> widgets = [];
    // for (var i = 0; i < 100; i++) {
    for (var i = 0; i < controller.productDatas.length; i++) {
      Map data = controller.productDatas[i];
      widgets.add(CustomButton(
        onPressed: () {
          controller.selectedProductAction(data, i);
        },
        child: SizedBox(
            width: 100.w,
            height: 68.w +
                8 +
                calculateTextHeight(data["terminalName"] ?? "", 12,
                    FontWeight.normal, 90.w, 1, context,
                    color: AppColor.textBlack) +
                calculateTextHeight(data["terminalMod"] ?? "", 10,
                    FontWeight.normal, 90.w, 1, context,
                    color: AppColor.textBlack),
            child: Stack(
              children: [
                Positioned.fill(
                    child: Column(
                  children: [
                    ghb(12),
                    CustomNetworkImage(
                      src: AppDefault().imageUrl + data["terminalImg"],
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.fill,
                    ),
                    // SizedBox(
                    //   width: 40.w,
                    //   height: 40.w,
                    //   child: Image.asset(
                    //     data["img"],
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                    ghb(8),
                    getWidthText(data["terminalName"] ?? "", 12,
                        AppColor.textBlack, 90, 1,
                        textAlign: TextAlign.center,
                        alignment: Alignment.center),
                    ghb(8),
                    getWidthText(
                        data["terminalMod"] ?? "", 10, AppColor.textGrey, 90, 1,
                        textAlign: TextAlign.center,
                        alignment: Alignment.center)
                  ],
                )),
                Positioned(
                    right: 0,
                    top: 0,
                    child: GetBuilder<ProductVipOrderController>(
                      init: controller,
                      id: controller.selectedBuildId,
                      initState: (_) {},
                      builder: (_) {
                        return data["selected"]
                            ? Transform.scale(
                                scale: 1.3,
                                child: Icon(
                                  Icons.check_box,
                                  size: 15.w,
                                  color: const Color(0xFF3782FF),
                                ),
                              )
                            : Container(
                                width: 15.w,
                                height: 15.w,
                                decoration: BoxDecoration(
                                    color: data["selected"]
                                        ? const Color(0xFF3782FF)
                                        : Colors.transparent,
                                    border: Border.all(
                                        width: 1.w,
                                        color: data["selected"]
                                            ? Colors.transparent
                                            : const Color(0xFFE0E0E0))),
                              );
                      },
                    ))
              ],
            )),
      ));
    }
    return widgets;
  }
}
